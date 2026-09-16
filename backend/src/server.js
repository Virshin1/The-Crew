import http from 'http';
import express from 'express';
import cors from 'cors';
import { Server } from 'socket.io';
import { PORT, DB_DRIVER } from './config.js';
import { seedDB } from './seed.js';
import { setupSocketHandler } from './sockets/socketHandler.js';
import { initFirebase, isFirebaseReady } from './firebase.js';

import authRoutes from './routes/auth.routes.js';
import serversRoutes from './routes/servers.routes.js';
import channelsRoutes from './routes/channels.routes.js';
import dmsRoutes from './routes/dms.routes.js';
import notificationsRoutes from './routes/notifications.routes.js';
import voiceRoutes from './routes/voice.routes.js';

const app = express();
const server = http.createServer(app);

// Initialize Socket.io
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE']
  }
});

app.set('io', io);

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/servers', serversRoutes);
app.use('/api/channels', channelsRoutes);
app.use('/api/dms', dmsRoutes);
app.use('/api/notifications', notificationsRoutes);
app.use('/api/voice', voiceRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'online',
    platform: 'The Crew Backend',
    database: DB_DRIVER,
    firebase_ready: isFirebaseReady(),
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Setup sockets
setupSocketHandler(io);

// Auto-seed database if using SQLite
if (DB_DRIVER === 'sqlite') {
  seedDB();
} else if (DB_DRIVER === 'firestore') {
  initFirebase();
}

// Start server
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 The Crew backend running at http://localhost:${PORT}`);
  console.log(`💾 Active Database Driver: ${DB_DRIVER.toUpperCase()}`);
  console.log(`📡 WebSocket endpoint ready at ws://localhost:${PORT}`);
});


export { app, server, io };
