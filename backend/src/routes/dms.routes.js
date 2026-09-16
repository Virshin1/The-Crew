import express from 'express';
import db from '../db.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

// Get DM inbox conversations and active now users
router.get('/', authenticateToken, (req, res) => {
  const currentUserId = req.user.id;

  // Active now users (users who are online, excluding self)
  const activeNow = db.prepare(`
    SELECT id, username, display_name, avatar_url, status, custom_status
    FROM users
    WHERE id != ? AND status != 'offline'
    LIMIT 10
  `).all(currentUserId);

  // All users we've chatted with or can chat with
  const conversations = db.prepare(`
    SELECT
      u.id as partner_id,
      u.display_name,
      u.username,
      u.avatar_url,
      u.status,
      u.custom_status,
      dm.content as last_message,
      dm.created_at as last_message_time,
      (SELECT COUNT(*) FROM direct_messages WHERE sender_id = u.id AND receiver_id = ? AND is_read = 0) as unread_count
    FROM (
      SELECT
        CASE WHEN sender_id = ? THEN receiver_id ELSE sender_id END as other_id,
        MAX(created_at) as latest_time
      FROM direct_messages
      WHERE sender_id = ? OR receiver_id = ?
      GROUP BY other_id
    ) recent
    JOIN users u ON u.id = recent.other_id
    JOIN direct_messages dm ON (
      (dm.sender_id = ? AND dm.receiver_id = u.id) OR
      (dm.sender_id = u.id AND dm.receiver_id = ?)
    ) AND dm.created_at = recent.latest_time
    ORDER BY recent.latest_time DESC
  `).all(currentUserId, currentUserId, currentUserId, currentUserId, currentUserId, currentUserId);

  res.json({ active_now: activeNow, conversations });
});

// Get messages in a DM thread with partner
router.get('/:userId', authenticateToken, (req, res) => {
  const currentUserId = req.user.id;
  const partnerId = req.params.userId;

  // Mark unread messages as read
  db.prepare(`
    UPDATE direct_messages
    SET is_read = 1
    WHERE sender_id = ? AND receiver_id = ?
  `).run(partnerId, currentUserId);

  const messages = db.prepare(`
    SELECT dm.*, u.display_name as sender_name, u.avatar_url as sender_avatar
    FROM direct_messages dm
    JOIN users u ON dm.sender_id = u.id
    WHERE (dm.sender_id = ? AND dm.receiver_id = ?)
       OR (dm.sender_id = ? AND dm.receiver_id = ?)
    ORDER BY dm.created_at ASC
  `).all(currentUserId, partnerId, partnerId, currentUserId);

  const partner = db.prepare('SELECT id, username, display_name, avatar_url, status, custom_status, bio FROM users WHERE id = ?').get(partnerId);

  res.json({ partner, messages });
});

// Send a DM
router.post('/:userId', authenticateToken, (req, res) => {
  const currentUserId = req.user.id;
  const partnerId = req.params.userId;
  const { content } = req.body;

  if (!content || content.trim() === '') {
    return res.status(400).json({ error: 'Message content cannot be empty.' });
  }

  const dmId = 'dm_' + Date.now().toString(36) + Math.random().toString(36).substr(2, 4);

  db.prepare(`
    INSERT INTO direct_messages (id, sender_id, receiver_id, content, is_read)
    VALUES (?, ?, ?, ?, 0)
  `).run(dmId, currentUserId, partnerId, content);

  const newDm = db.prepare(`
    SELECT dm.*, u.display_name as sender_name, u.avatar_url as sender_avatar
    FROM direct_messages dm
    JOIN users u ON dm.sender_id = u.id
    WHERE dm.id = ?
  `).get(dmId);

  const io = req.app.get('io');
  if (io) {
    io.to('user_' + partnerId).emit('dm:new', newDm);
    io.to('user_' + currentUserId).emit('dm:new', newDm);
  }

  res.status(201).json({ message: newDm });
});

export default router;
