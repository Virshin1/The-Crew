import express from 'express';
import db from '../db.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

// Get all notifications
router.get('/', authenticateToken, (req, res) => {
  const { type } = req.query; // all, mention, reaction, system, friend

  let query = `
    SELECT n.*, u.username as actor_username, u.display_name as actor_display_name, u.avatar_url as actor_avatar
    FROM notifications n
    LEFT JOIN users u ON n.actor_id = u.id
    WHERE n.user_id = ?
  `;
  const params = [req.user.id];

  if (type && type.toLowerCase() !== 'all') {
    query += ` AND n.type = ?`;
    params.push(type.toLowerCase());
  }

  query += ` ORDER BY n.created_at DESC`;

  const notifications = db.prepare(query).all(...params);
  res.json({ notifications });
});

// Mark all notifications as read
router.post('/read-all', authenticateToken, (req, res) => {
  db.prepare('UPDATE notifications SET is_read = 1 WHERE user_id = ?').run(req.user.id);
  res.json({ message: 'All notifications marked as read' });
});

// Mark single notification read
router.post('/:id/read', authenticateToken, (req, res) => {
  db.prepare('UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?').run(req.params.id, req.user.id);
  res.json({ message: 'Notification marked as read' });
});

export default router;
