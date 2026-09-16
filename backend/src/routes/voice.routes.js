import express from 'express';
import db from '../db.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

// Get active participants in a voice channel
router.get('/:channelId', authenticateToken, (req, res) => {
  const participants = db.prepare(`
    SELECT
      vp.channel_id,
      vp.user_id,
      vp.is_speaking,
      vp.is_muted,
      vp.is_streaming,
      vp.status_text,
      vp.joined_at,
      u.username,
      u.display_name,
      u.avatar_url
    FROM voice_participants vp
    JOIN users u ON vp.user_id = u.id
    WHERE vp.channel_id = ?
    ORDER BY vp.is_speaking DESC, u.display_name ASC
  `).all(req.params.channelId);

  res.json({ participants });
});

// Join voice channel
router.post('/:channelId/join', authenticateToken, (req, res) => {
  const channelId = req.params.channelId;
  const userId = req.user.id;

  db.prepare(`
    INSERT INTO voice_participants (channel_id, user_id, is_speaking, is_muted, is_streaming, status_text)
    VALUES (?, ?, 0, 0, 0, 'Listening')
    ON CONFLICT(channel_id, user_id) DO UPDATE SET
      is_speaking = 0,
      joined_at = CURRENT_TIMESTAMP
  `).run(channelId, userId);

  const participant = db.prepare(`
    SELECT vp.*, u.username, u.display_name, u.avatar_url
    FROM voice_participants vp
    JOIN users u ON vp.user_id = u.id
    WHERE vp.channel_id = ? AND vp.user_id = ?
  `).get(channelId, userId);

  const io = req.app.get('io');
  if (io) {
    io.to('voice_' + channelId).emit('voice:joined', participant);
  }

  res.json({ participant });
});

// Leave voice channel
router.post('/:channelId/leave', authenticateToken, (req, res) => {
  const channelId = req.params.channelId;
  const userId = req.user.id;

  db.prepare('DELETE FROM voice_participants WHERE channel_id = ? AND user_id = ?').run(channelId, userId);

  const io = req.app.get('io');
  if (io) {
    io.to('voice_' + channelId).emit('voice:left', { channelId, userId });
  }

  res.json({ message: 'Left voice channel' });
});

// Toggle mute
router.post('/:channelId/toggle-mute', authenticateToken, (req, res) => {
  const channelId = req.params.channelId;
  const userId = req.user.id;

  const current = db.prepare('SELECT is_muted FROM voice_participants WHERE channel_id = ? AND user_id = ?').get(channelId, userId);
  const newMute = current && current.is_muted ? 0 : 1;

  db.prepare(`
    UPDATE voice_participants
    SET is_muted = ?,
        status_text = CASE WHEN ? = 1 THEN 'Muted' ELSE 'Listening' END
    WHERE channel_id = ? AND user_id = ?
  `).run(newMute, newMute, channelId, userId);

  const io = req.app.get('io');
  if (io) {
    io.to('voice_' + channelId).emit('voice:mute_updated', { channelId, userId, is_muted: Boolean(newMute) });
  }

  res.json({ is_muted: Boolean(newMute) });
});

// Update speaking state
router.post('/:channelId/speaking', authenticateToken, (req, res) => {
  const channelId = req.params.channelId;
  const userId = req.user.id;
  const { is_speaking } = req.body;

  db.prepare(`
    UPDATE voice_participants
    SET is_speaking = ?,
        status_text = CASE WHEN ? = 1 THEN 'Speaking...' ELSE 'Listening' END
    WHERE channel_id = ? AND user_id = ?
  `).run(is_speaking ? 1 : 0, is_speaking ? 1 : 0, channelId, userId);

  const io = req.app.get('io');
  if (io) {
    io.to('voice_' + channelId).emit('voice:speaking_updated', { channelId, userId, is_speaking: Boolean(is_speaking) });
  }

  res.json({ is_speaking: Boolean(is_speaking) });
});

export default router;
