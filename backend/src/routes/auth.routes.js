import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import db from '../db.js';
import { JWT_SECRET } from '../config.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

function generateToken(user) {
  return jwt.sign(
    { id: user.id, username: user.username, email: user.email },
    JWT_SECRET,
    { expiresIn: '30d' }
  );
}

// Register
router.post('/register', (req, res) => {
  const { username, display_name, email, password, interests } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ error: 'Username, email and password are required.' });
  }

  const existing = db.prepare('SELECT id FROM users WHERE username = ? OR email = ?').get(username.toLowerCase(), email.toLowerCase());
  if (existing) {
    return res.status(400).json({ error: 'Username or email already in use.' });
  }

  const id = 'u_' + Date.now().toString(36) + Math.random().toString(36).substr(2, 5);
  const passwordHash = bcrypt.hashSync(password, 10);
  const displayName = display_name || username;

  db.prepare(`
    INSERT INTO users (id, username, display_name, email, password_hash, interests, status, custom_status)
    VALUES (?, ?, ?, ?, ?, ?, 'online', 'Ready to squad up')
  `).run(id, username.toLowerCase(), displayName, email.toLowerCase(), passwordHash, interests || 'Gaming,Tech');

  // Automatically join Neon Arcade (s1) so new user has channels immediately
  const memberId = 'sm_' + id;
  db.prepare(`
    INSERT OR IGNORE INTO server_members (id, server_id, user_id, role, activity)
    VALUES (?, 's1', ?, 'MEMBER', 'Joined the crew!')
  `).run(memberId, id);

  const newUser = db.prepare('SELECT id, username, display_name, email, avatar_url, bio, status, custom_status, interests, created_at FROM users WHERE id = ?').get(id);
  const token = generateToken(newUser);

  res.status(201).json({
    message: 'User registered successfully',
    user: newUser,
    token
  });
});

// Login
router.post('/login', (req, res) => {
  const { login, password } = req.body; // login can be email or username

  if (!login || !password) {
    return res.status(400).json({ error: 'Email/username and password are required.' });
  }

  const user = db.prepare(`
    SELECT * FROM users
    WHERE LOWER(email) = LOWER(?) OR LOWER(username) = LOWER(?)
  `).get(login, login);

  if (!user) {
    return res.status(400).json({ error: 'Invalid credentials. User not found.' });
  }

  const isValid = bcrypt.compareSync(password, user.password_hash);
  if (!isValid) {
    return res.status(400).json({ error: 'Invalid credentials. Incorrect password.' });
  }

  const userSafe = {
    id: user.id,
    username: user.username,
    display_name: user.display_name,
    email: user.email,
    avatar_url: user.avatar_url,
    bio: user.bio,
    status: user.status,
    custom_status: user.custom_status,
    interests: user.interests,
    created_at: user.created_at
  };

  const token = generateToken(userSafe);
  res.json({
    message: 'Login successful',
    user: userSafe,
    token
  });
});

// Quick Demo Login (for rapid testing as Kaelen or Nyx)
router.post('/quick-login', (req, res) => {
  const { username } = req.body;
  const targetUsername = username || 'kaelen_vr';

  const user = db.prepare('SELECT * FROM users WHERE LOWER(username) = LOWER(?)').get(targetUsername);
  if (!user) {
    return res.status(404).json({ error: 'Demo user not found.' });
  }

  const userSafe = {
    id: user.id,
    username: user.username,
    display_name: user.display_name,
    email: user.email,
    avatar_url: user.avatar_url,
    bio: user.bio,
    status: user.status,
    custom_status: user.custom_status,
    interests: user.interests,
    created_at: user.created_at
  };

  const token = generateToken(userSafe);
  res.json({
    message: 'Quick login successful',
    user: userSafe,
    token
  });
});

// Get Current User Profile
router.get('/me', authenticateToken, (req, res) => {
  res.json({ user: req.user });
});

// Update Profile
router.put('/profile', authenticateToken, (req, res) => {
  const { display_name, bio, status, custom_status, avatar_url } = req.body;

  db.prepare(`
    UPDATE users
    SET display_name = COALESCE(?, display_name),
        bio = COALESCE(?, bio),
        status = COALESCE(?, status),
        custom_status = COALESCE(?, custom_status),
        avatar_url = COALESCE(?, avatar_url)
    WHERE id = ?
  `).run(display_name, bio, status, custom_status, avatar_url, req.user.id);

  const updatedUser = db.prepare('SELECT id, username, display_name, email, avatar_url, bio, status, custom_status, interests, created_at FROM users WHERE id = ?').get(req.user.id);
  res.json({ message: 'Profile updated successfully', user: updatedUser });
});

// Google Sign-In / OAuth Login & Registration
router.post('/google', (req, res) => {
  const { email, display_name, photo_url, google_id } = req.body;

  if (!email) {
    return res.status(400).json({ error: 'Google email is required.' });
  }

  const normalizedEmail = email.toLowerCase().trim();

  // Check if user exists by email
  let user = db.prepare('SELECT * FROM users WHERE LOWER(email) = ?').get(normalizedEmail);

  if (!user) {
    // Generate unique username from email
    const baseUsername = normalizedEmail.split('@')[0].replace(/[^a-zA-Z0-9_]/g, '') || 'crew_pilot';
    let username = baseUsername;
    let counter = 1;
    while (db.prepare('SELECT id FROM users WHERE LOWER(username) = ?').get(username.toLowerCase())) {
      username = `${baseUsername}_${counter++}`;
    }

    const id = 'u_g_' + Date.now().toString(36) + Math.random().toString(36).substr(2, 4);
    const displayName = display_name || username;
    const avatarUrl = photo_url || null;
    const dummyPasswordHash = bcrypt.hashSync(`google_${google_id || Date.now()}`, 10);

    db.prepare(`
      INSERT INTO users (id, username, display_name, email, password_hash, avatar_url, interests, status, custom_status)
      VALUES (?, ?, ?, ?, ?, ?, 'Gaming,Tech', 'online', 'Connected via Google')
    `).run(id, username.toLowerCase(), displayName, normalizedEmail, dummyPasswordHash, avatarUrl);

    // Auto-join server s1 (Neon Arcade)
    db.prepare(`
      INSERT OR IGNORE INTO server_members (id, server_id, user_id, role, activity)
      VALUES (?, 's1', ?, 'MEMBER', 'Joined via Google!')
    `).run(`sm_${id}`, id);

    user = db.prepare('SELECT id, username, display_name, email, avatar_url, bio, status, custom_status, interests, created_at FROM users WHERE id = ?').get(id);
  }

  const userSafe = {
    id: user.id,
    username: user.username,
    display_name: user.display_name,
    email: user.email,
    avatar_url: user.avatar_url,
    bio: user.bio,
    status: user.status,
    custom_status: user.custom_status,
    interests: user.interests,
    created_at: user.created_at
  };

  const token = generateToken(userSafe);

  res.json({
    message: 'Google login successful',
    user: userSafe,
    token
  });
});

export default router;

