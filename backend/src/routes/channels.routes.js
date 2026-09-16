import express from 'express';
import db from '../db.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

// Helper to get formatted messages with sender and reactions
export function getChannelMessages(channelId) {
  const channel = db.prepare('SELECT server_id FROM channels WHERE id = ?').get(channelId);
  const serverId = channel ? channel.server_id : null;

  const messages = db.prepare(`
    SELECT
      m.*,
      u.username,
      u.display_name,
      u.avatar_url,
      u.status,
      (SELECT sm.role FROM server_members sm WHERE sm.server_id = ? AND sm.user_id = m.sender_id) as sender_role
    FROM messages m
    JOIN users u ON m.sender_id = u.id
    WHERE m.channel_id = ?
    ORDER BY m.created_at ASC
  `).all(serverId, channelId);

  // Attach reactions
  const getReactions = db.prepare(`
    SELECT emoji, COUNT(*) as count, GROUP_CONCAT(user_id) as user_ids
    FROM reactions
    WHERE message_id = ?
    GROUP BY emoji
  `);

  return messages.map(m => {
    const rx = getReactions.all(m.id);
    return {
      ...m,
      has_media: Boolean(m.has_media),
      reactions: rx.map(r => ({
        emoji: r.emoji,
        count: r.count,
        users: r.user_ids ? r.user_ids.split(',') : []
      }))
    };
  });
}

// Get messages for a channel
router.get('/:id/messages', authenticateToken, (req, res) => {
  try {
    const messages = getChannelMessages(req.params.id);
    res.json({ messages });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Post a message in a channel
router.post('/:id/messages', authenticateToken, (req, res) => {
  const { content, has_media, media_url, media_title, media_duration } = req.body;

  if ((!content || content.trim() === '') && !has_media) {
    return res.status(400).json({ error: 'Message content cannot be empty.' });
  }

  const messageId = 'm_' + Date.now().toString(36) + Math.random().toString(36).substr(2, 4);

  db.prepare(`
    INSERT INTO messages (id, channel_id, sender_id, content, has_media, media_url, media_title, media_duration)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    messageId,
    req.params.id,
    req.user.id,
    content || '',
    has_media ? 1 : 0,
    media_url || null,
    media_title || null,
    media_duration || null
  );

  const messages = getChannelMessages(req.params.id);
  const newMessage = messages.find(m => m.id === messageId);

  // Broadcast through socket if io is attached to app
  const io = req.app.get('io');
  if (io) {
    io.to('channel_' + req.params.id).emit('message:new', newMessage);
  }

  res.status(201).json({ message: newMessage });
});

// Toggle a reaction on a message
router.post('/messages/:messageId/reactions', authenticateToken, (req, res) => {
  const { emoji } = req.body;
  if (!emoji) {
    return res.status(400).json({ error: 'Emoji is required.' });
  }

  const message = db.prepare('SELECT channel_id FROM messages WHERE id = ?').get(req.params.messageId);
  if (!message) {
    return res.status(404).json({ error: 'Message not found.' });
  }

  const existing = db.prepare('SELECT id FROM reactions WHERE message_id = ? AND user_id = ? AND emoji = ?').get(req.params.messageId, req.user.id, emoji);

  if (existing) {
    db.prepare('DELETE FROM reactions WHERE id = ?').run(existing.id);
  } else {
    db.prepare(`
      INSERT INTO reactions (id, message_id, user_id, emoji)
      VALUES (?, ?, ?, ?)
    `).run('r_' + Date.now().toString(36), req.params.messageId, req.user.id, emoji);
  }

  // Fetch updated reactions for this message
  const rx = db.prepare(`
    SELECT emoji, COUNT(*) as count, GROUP_CONCAT(user_id) as user_ids
    FROM reactions
    WHERE message_id = ?
    GROUP BY emoji
  `).all(req.params.messageId);

  const updatedReactions = rx.map(r => ({
    emoji: r.emoji,
    count: r.count,
    users: r.user_ids ? r.user_ids.split(',') : []
  }));

  const io = req.app.get('io');
  if (io) {
    io.to('channel_' + message.channel_id).emit('reaction:updated', {
      message_id: req.params.messageId,
      reactions: updatedReactions
    });
  }

  res.json({ message_id: req.params.messageId, reactions: updatedReactions });
});

export default router;
