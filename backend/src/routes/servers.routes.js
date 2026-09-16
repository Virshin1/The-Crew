import express from 'express';
import db from '../db.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

// List servers the current user has joined
router.get('/', authenticateToken, (req, res) => {
  const servers = db.prepare(`
    SELECT s.*, sm.role as my_role
    FROM servers s
    JOIN server_members sm ON s.id = sm.server_id
    WHERE sm.user_id = ?
    ORDER BY sm.joined_at ASC
  `).all(req.user.id);

  res.json({ servers });
});

// Discover public servers (with search & category filter)
router.get('/discover', (req, res) => {
  const { category, search } = req.query;

  let query = `
    SELECT s.*,
      (SELECT COUNT(*) FROM server_members sm WHERE sm.server_id = s.id) as member_count,
      (SELECT COUNT(*) FROM server_members sm JOIN users u ON sm.user_id = u.id WHERE sm.server_id = s.id AND u.status != 'offline') as online_count
    FROM servers s
    WHERE s.is_public = 1
  `;
  const params = [];

  if (category && category !== 'Featured' && category !== 'All') {
    query += ` AND s.category = ?`;
    params.push(category);
  }

  if (search && search.trim() !== '') {
    query += ` AND (s.name LIKE ? OR s.description LIKE ?)`;
    params.push(`%${search.trim()}%`, `%${search.trim()}%`);
  }

  query += ` ORDER BY member_count DESC`;

  const servers = db.prepare(query).all(...params);
  res.json({ servers });
});

// Create a new server
router.post('/', authenticateToken, (req, res) => {
  const { name, description, category, is_public, icon_color } = req.body;

  if (!name || name.trim() === '') {
    return res.status(400).json({ error: 'Server name is required.' });
  }

  const serverId = 's_' + Date.now().toString(36);
  const color = icon_color || '#9D4EDD';

  db.prepare(`
    INSERT INTO servers (id, name, description, icon_color, owner_id, category, is_public, level)
    VALUES (?, ?, ?, ?, ?, ?, ?, 'LVL 1')
  `).run(serverId, name, description || '', color, req.user.id, category || 'Gaming', is_public !== false ? 1 : 0);

  // Add creator as OWNER
  db.prepare(`
    INSERT INTO server_members (id, server_id, user_id, role, activity)
    VALUES (?, ?, ?, 'OWNER', 'Administering server')
  `).run('sm_' + Date.now().toString(36), serverId, req.user.id);

  // Create default channels
  const defaultChannels = [
    { name: 'welcome', type: 'text', topic: 'Welcome to ' + name },
    { name: 'lounge', type: 'text', topic: 'General chill chat' },
    { name: 'media-share', type: 'text', topic: 'Share artwork, music and clips' },
    { name: 'Lounge Voice', type: 'voice', topic: 'Voice chat stage' }
  ];

  const insertChannel = db.prepare(`
    INSERT INTO channels (id, server_id, name, type, topic, position)
    VALUES (?, ?, ?, ?, ?, ?)
  `);

  defaultChannels.forEach((c, idx) => {
    insertChannel.run('c_' + serverId + '_' + idx, serverId, c.name, c.type, c.topic, idx);
  });

  const createdServer = db.prepare('SELECT * FROM servers WHERE id = ?').get(serverId);
  res.status(201).json({ message: 'Server created successfully', server: createdServer });
});

// Get server details
router.get('/:id', authenticateToken, (req, res) => {
  const server = db.prepare('SELECT * FROM servers WHERE id = ?').get(req.params.id);
  if (!server) {
    return res.status(404).json({ error: 'Server not found.' });
  }
  res.json({ server });
});

// Join server
router.post('/:id/join', authenticateToken, (req, res) => {
  const server = db.prepare('SELECT * FROM servers WHERE id = ?').get(req.params.id);
  if (!server) {
    return res.status(404).json({ error: 'Server not found.' });
  }

  const existing = db.prepare('SELECT id FROM server_members WHERE server_id = ? AND user_id = ?').get(req.params.id, req.user.id);
  if (existing) {
    return res.status(400).json({ message: 'Already a member of this server.' });
  }

  db.prepare(`
    INSERT INTO server_members (id, server_id, user_id, role, activity)
    VALUES (?, ?, ?, 'MEMBER', 'Exploring channels')
  `).run('sm_' + Date.now().toString(36), req.params.id, req.user.id);

  res.json({ message: 'Successfully joined server!', serverId: req.params.id });
});

// Leave server
router.post('/:id/leave', authenticateToken, (req, res) => {
  db.prepare('DELETE FROM server_members WHERE server_id = ? AND user_id = ?').run(req.params.id, req.user.id);
  res.json({ message: 'Left server successfully.' });
});

// Get channels of a server
router.get('/:id/channels', authenticateToken, (req, res) => {
  const channels = db.prepare(`
    SELECT * FROM channels
    WHERE server_id = ?
    ORDER BY position ASC, name ASC
  `).all(req.params.id);

  res.json({ channels });
});

// Create a new channel
router.post('/:id/channels', authenticateToken, (req, res) => {
  const { name, type, topic } = req.body;
  if (!name) {
    return res.status(400).json({ error: 'Channel name is required.' });
  }

  const channelId = 'c_' + Date.now().toString(36);
  db.prepare(`
    INSERT INTO channels (id, server_id, name, type, topic, position)
    VALUES (?, ?, ?, ?, ?, (SELECT COUNT(*) FROM channels WHERE server_id = ?))
  `).run(channelId, req.params.id, name.toLowerCase().replace(/\s+/g, '-'), type || 'text', topic || '', req.params.id);

  const channel = db.prepare('SELECT * FROM channels WHERE id = ?').get(channelId);
  res.status(201).json({ channel });
});

// Get members of a server
router.get('/:id/members', authenticateToken, (req, res) => {
  const members = db.prepare(`
    SELECT
      sm.id as member_id,
      sm.role,
      sm.activity,
      sm.joined_at,
      u.id as user_id,
      u.username,
      u.display_name,
      u.avatar_url,
      u.status,
      u.custom_status
    FROM server_members sm
    JOIN users u ON sm.user_id = u.id
    WHERE sm.server_id = ?
    ORDER BY
      CASE sm.role
        WHEN 'OWNER' THEN 1
        WHEN 'ADMIN' THEN 2
        WHEN 'VIP' THEN 3
        ELSE 4
      END ASC,
      u.display_name ASC
  `).all(req.params.id);

  res.json({ members });
});

export default router;
