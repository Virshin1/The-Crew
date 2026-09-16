import jwt from 'jsonwebtoken';
import { JWT_SECRET } from '../config.js';
import db from '../db.js';

export function setupSocketHandler(io) {
  // Middleware to authenticate socket connections
  io.use((socket, next) => {
    const token = socket.handshake.auth?.token || socket.handshake.headers?.authorization?.split(' ')[1];
    if (!token) {
      // Allow unauthenticated connection as guest or reject
      return next();
    }

    try {
      const decoded = jwt.verify(token, JWT_SECRET);
      socket.userId = decoded.id;
      next();
    } catch (err) {
      console.warn('Socket token verification failed:', err.message);
      next();
    }
  });

  io.on('connection', (socket) => {
    const userId = socket.userId;
    console.log(`⚡ Socket connected: ${socket.id} (User: ${userId || 'guest'})`);

    if (userId) {
      socket.join('user_' + userId);
      // Mark user online
      db.prepare("UPDATE users SET status = 'online' WHERE id = ?").run(userId);
      io.emit('presence:updated', { userId, status: 'online' });
    }

    // Join channel room for live chat messages
    socket.on('channel:join', ({ channelId }) => {
      if (channelId) {
        socket.join('channel_' + channelId);
        console.log(`User ${userId} joined room channel_${channelId}`);
      }
    });

    socket.on('channel:leave', ({ channelId }) => {
      if (channelId) {
        socket.leave('channel_' + channelId);
        console.log(`User ${userId} left room channel_${channelId}`);
      }
    });

    // Typing indicators
    socket.on('typing:start', ({ channelId, username }) => {
      if (channelId) {
        socket.to('channel_' + channelId).emit('typing:started', { channelId, username, userId });
      }
    });

    socket.on('typing:stop', ({ channelId, username }) => {
      if (channelId) {
        socket.to('channel_' + channelId).emit('typing:stopped', { channelId, username, userId });
      }
    });

    // Voice channel room subscription
    socket.on('voice:join', ({ channelId }) => {
      if (channelId) {
        socket.join('voice_' + channelId);
      }
    });

    socket.on('voice:leave', ({ channelId }) => {
      if (channelId) {
        socket.leave('voice_' + channelId);
      }
    });

    socket.on('disconnect', () => {
      console.log(`🔌 Socket disconnected: ${socket.id}`);
      if (userId) {
        // Optional: debounce or mark offline if no other sockets open
      }
    });
  });
}
