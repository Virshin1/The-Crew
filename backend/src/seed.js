import bcrypt from 'bcryptjs';
import db, { initDB } from './db.js';

export function seedDB() {
  initDB();

  const userCount = db.prepare('SELECT COUNT(*) as count FROM users').get().count;
  if (userCount > 0) {
    console.log('Database already has data. Skipping seed.');
    return;
  }

  console.log('🌱 Seeding Discord-like database for The Crew...');

  const passwordHash = bcrypt.hashSync('password123', 10);

  // Insert Users
  const insertUser = db.prepare(`
    INSERT INTO users (id, username, display_name, email, password_hash, avatar_url, bio, status, custom_status, interests)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const users = [
    { id: 'u1', username: 'kaelen_vr', display_name: 'Kaelen', email: 'kaelen@thecrew.gg', avatar_url: null, bio: 'Raid commander. Neon fanatic. Sector 9 champion.', status: 'online', custom_status: 'Playing Sector 9' },
    { id: 'u2', username: 'nyx_9', display_name: 'Nyx', email: 'nyx@thecrew.gg', avatar_url: null, bio: 'VFX artist and clutch master. Streaming daily.', status: 'online', custom_status: 'Editing clips' },
    { id: 'u3', username: 'zero_x', display_name: 'Zero_X', email: 'zero@thecrew.gg', avatar_url: null, bio: 'Ranked grinder. Tactical specialist.', status: 'online', custom_status: 'In voice lobby' },
    { id: 'u4', username: 'mira_lofi', display_name: 'Mira_Lofi', email: 'mira@thecrew.gg', avatar_url: null, bio: 'Resident DJ. 24/7 lo-fi and synth beats.', status: 'online', custom_status: 'DJing in Chill Beats' },
    { id: 'u5', username: 'neon_pulse', display_name: 'NeonPulse', email: 'neon@thecrew.gg', avatar_url: null, bio: 'Community admin & livestreamer.', status: 'online', custom_status: 'Streaming to 42 viewers' },
    { id: 'u6', username: 'aurora_vfx', display_name: 'AuroraVFX', email: 'aurora@thecrew.gg', avatar_url: null, bio: 'Shader wizard and 3D animator.', status: 'idle', custom_status: 'AFK — Back in 10' },
    { id: 'u7', username: 'pixel_forge', display_name: 'PixelForge', email: 'pixel@thecrew.gg', avatar_url: null, bio: 'Tournament organizer. Pixel art lover.', status: 'online', custom_status: 'Brackets live' },
    { id: 'u8', username: 'glitch_wave', display_name: 'GlitchWave', email: 'glitch@thecrew.gg', avatar_url: null, bio: 'Sound designer & synthwave producer.', status: 'offline', custom_status: 'In Voice: Chill Beats' },
    { id: 'u9', username: 'crypto_fox', display_name: 'CryptoFox', email: 'fox@thecrew.gg', avatar_url: null, bio: 'Lurking in the shadows...', status: 'online', custom_status: 'Lurking...' },
    { id: 'u10', username: 'vapor_drift', display_name: 'VaporDrift', email: 'vapor@thecrew.gg', avatar_url: null, bio: 'Retro wave aesthetician.', status: 'online', custom_status: 'Vibing' },
    { id: 'u11', username: 'skyline_hex', display_name: 'SkylineHex', email: 'skyline@thecrew.gg', avatar_url: null, bio: 'Apex predator in matchmaking.', status: 'online', custom_status: 'Playing ranked' },
    { id: 'u12', username: 'dark_nova', display_name: 'DarkNova', email: 'nova@thecrew.gg', avatar_url: null, bio: 'Night owl gamer.', status: 'offline', custom_status: 'Last seen 2h ago' },
  ];

  for (const u of users) {
    insertUser.run(u.id, u.username, u.display_name, u.email, passwordHash, u.avatar_url, u.bio, u.status, u.custom_status, 'Gaming,Tech');
  }

  // Insert Servers
  const insertServer = db.prepare(`
    INSERT INTO servers (id, name, description, icon_url, icon_color, owner_id, category, is_public, level)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const servers = [
    { id: 's1', name: 'Neon Arcade', description: 'The cutting-edge hub for cybernetics, net-runners, modders, and tech enthusiasts. Daily voice...', icon_color: '#9D4EDD', owner_id: 'u1', category: 'Gaming', is_public: 1, level: 'LVL 3' },
    { id: 's2', name: 'Synthwave Beats', description: 'Lo-fi, synthwave, retrograde producers, and late-night highway cruising storms and live streaming sets...', icon_color: '#00F0FF', owner_id: 'u4', category: 'Music', is_public: 1, level: 'LVL 2' },
    { id: 's3', name: 'Pixel Artists Guild', description: 'Weekly art jams, palette challenges, admiration, critique and daily pixel-meditations boards.', icon_color: '#FF007F', owner_id: 'u7', category: 'Anime & Art', is_public: 1, level: 'LVL 1' },
    { id: 's4', name: 'Neon Lounge', description: 'Low-stimulus chill chat, late night philosophical discussions, ambient radio and vaporwave aesthetics.', icon_color: '#FF6B35', owner_id: 'u1', category: 'Cozy', is_public: 1, level: 'LVL 1' },
    { id: 's5', name: 'Cyberpunk 2099', description: 'The premiere cyber-district for futuristic builds, neural net shaders, and hardware overclocking.', icon_color: '#00F0FF', owner_id: 'u2', category: 'Tech', is_public: 1, level: 'LVL 3' }
  ];

  for (const s of servers) {
    insertServer.run(s.id, s.name, s.description, null, s.icon_color, s.owner_id, s.category, s.is_public, s.level);
  }

  // Insert Server Members for Neon Arcade
  const insertMember = db.prepare(`
    INSERT INTO server_members (id, server_id, user_id, role, activity)
    VALUES (?, ?, ?, ?, ?)
  `);

  const membersNeon = [
    { id: 'sm1', server_id: 's1', user_id: 'u1', role: 'OWNER', activity: 'Playing Sector 9' },
    { id: 'sm2', server_id: 's1', user_id: 'u5', role: 'ADMIN', activity: 'Streaming to 42 viewers' },
    { id: 'sm3', server_id: 's1', user_id: 'u8', role: 'ADMIN', activity: 'In Voice: Chill Beats' },
    { id: 'sm4', server_id: 's1', user_id: 'u2', role: 'VIP', activity: 'Editing clips' },
    { id: 'sm5', server_id: 's1', user_id: 'u4', role: 'VIP', activity: 'DJing in Chill Beats' },
    { id: 'sm6', server_id: 's1', user_id: 'u6', role: 'VIP', activity: 'AFK — Back in 10' },
    { id: 'sm7', server_id: 's1', user_id: 'u7', role: 'VIP', activity: 'Tournament brackets live' },
    { id: 'sm8', server_id: 's1', user_id: 'u3', role: 'MEMBER', activity: 'In voice lobby' },
    { id: 'sm9', server_id: 's1', user_id: 'u9', role: 'MEMBER', activity: 'Lurking...' },
    { id: 'sm10', server_id: 's1', user_id: 'u10', role: 'MEMBER', activity: 'Vibing' },
    { id: 'sm11', server_id: 's1', user_id: 'u11', role: 'MEMBER', activity: 'Playing ranked' },
    { id: 'sm12', server_id: 's1', user_id: 'u12', role: 'MEMBER', activity: 'Last seen 2h ago' },
  ];

  for (const m of membersNeon) {
    insertMember.run(m.id, m.server_id, m.user_id, m.role, m.activity);
  }

  // Also add user u1 to other servers
  insertMember.run('sm_s2_u1', 's2', 'u1', 'MEMBER', 'Listening to Synthwave');
  insertMember.run('sm_s3_u1', 's3', 'u1', 'MEMBER', 'Viewing Artworks');
  insertMember.run('sm_s4_u1', 's4', 'u1', 'OWNER', 'Hosting Lounge');

  // Insert Channels for Neon Arcade
  const insertChannel = db.prepare(`
    INSERT INTO channels (id, server_id, name, type, topic, position)
    VALUES (?, ?, ?, ?, ?, ?)
  `);

  const channelsNeon = [
    { id: 'c1', server_id: 's1', name: 'welcome', type: 'text', topic: 'Welcome rules and introduction', position: 0 },
    { id: 'c2', server_id: 's1', name: 'lounge', type: 'text', topic: 'General chill lounge for the crew', position: 1 },
    { id: 'c3', server_id: 's1', name: 'gaming-clips', type: 'text', topic: 'Post your best clips and clutch plays', position: 2 },
    { id: 'c4', server_id: 's1', name: 'bot-beats', type: 'text', topic: 'Music commands and playlist requests', position: 3 },
    { id: 'c5', server_id: 's1', name: 'Chill Beats [Voice]', type: 'voice', topic: 'Spatial audio stage - Synthwave Radio 24/7', position: 4 },
  ];

  for (const c of channelsNeon) {
    insertChannel.run(c.id, c.server_id, c.name, c.type, c.topic, c.position);
  }

  // Insert Messages in #lounge
  const insertMessage = db.prepare(`
    INSERT INTO messages (id, channel_id, sender_id, content, has_media, media_url, media_title, media_duration, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const messages = [
    {
      id: 'm1',
      channel_id: 'c2',
      sender_id: 'u1',
      content: 'Midnight raid lobby is live! Grab the stream key or join the voice deck before we hit the ranked queue.',
      has_media: 0,
      media_url: null,
      media_title: null,
      media_duration: null,
      created_at: '2026-09-15 09:41:00'
    },
    {
      id: 'm2',
      channel_id: 'c2',
      sender_id: 'u2',
      content: 'Just hit this ridiculous clutch on Sector 9! Peep the replay timestamp at 0:42 🎮✨',
      has_media: 1,
      media_url: 'assets/sector9_clutch.mp4',
      media_title: 'Sector9_Clutch.mp4',
      media_duration: '01:14',
      created_at: '2026-09-15 09:43:00'
    },
    {
      id: 'm3',
      channel_id: 'c2',
      sender_id: 'u3',
      content: 'Yo @Kaelen check voice lobby, squad is ready to deploy!',
      has_media: 0,
      media_url: null,
      media_title: null,
      media_duration: null,
      created_at: '2026-09-15 09:44:00'
    }
  ];

  for (const msg of messages) {
    insertMessage.run(msg.id, msg.channel_id, msg.sender_id, msg.content, msg.has_media, msg.media_url, msg.media_title, msg.media_duration, msg.created_at);
  }

  // Insert Reactions
  const insertReaction = db.prepare(`
    INSERT INTO reactions (id, message_id, user_id, emoji)
    VALUES (?, ?, ?, ?)
  `);

  insertReaction.run('r1', 'm1', 'u2', '🔥');
  insertReaction.run('r2', 'm1', 'u3', '🔥');
  insertReaction.run('r3', 'm1', 'u4', '💜');
  insertReaction.run('r4', 'm1', 'u5', '🚀');
  insertReaction.run('r5', 'm2', 'u1', '🤯');
  insertReaction.run('r6', 'm2', 'u3', '👑');

  // Insert Voice Participants in c5
  const insertVoice = db.prepare(`
    INSERT INTO voice_participants (channel_id, user_id, is_speaking, is_muted, is_streaming, status_text)
    VALUES (?, ?, ?, ?, ?, ?)
  `);

  insertVoice.run('c5', 'u1', 1, 0, 1, 'Speaking...');
  insertVoice.run('c5', 'u4', 0, 0, 0, 'DJ Co-Host');
  insertVoice.run('c5', 'u3', 0, 0, 0, 'Listening');
  insertVoice.run('c5', 'u5', 0, 0, 1, 'Streaming');
  insertVoice.run('c5', 'u6', 0, 1, 0, 'Muted');
  insertVoice.run('c5', 'u7', 0, 0, 0, 'Idle');

  // Insert Direct Messages between u1 and other friends
  const insertDM = db.prepare(`
    INSERT INTO direct_messages (id, sender_id, receiver_id, content, is_read, created_at)
    VALUES (?, ?, ?, ?, ?, ?)
  `);

  const dms = [
    { id: 'dm1', sender_id: 'u2', receiver_id: 'u1', content: 'Shared a clip from Sector 9 🎮', is_read: 0, created_at: '2026-09-15 09:42:00' },
    { id: 'dm2', sender_id: 'u1', receiver_id: 'u1', content: 'Ready for the midnight raid?', is_read: 1, created_at: '2026-09-15 09:29:00' },
    { id: 'dm3', sender_id: 'u4', receiver_id: 'u1', content: 'New beat tape dropping at midnight 🎵', is_read: 1, created_at: '2026-09-15 08:44:00' },
    { id: 'dm4', sender_id: 'u3', receiver_id: 'u1', content: 'Squad deployment confirmed ✅', is_read: 1, created_at: '2026-09-15 07:44:00' },
    { id: 'dm5', sender_id: 'u6', receiver_id: 'u1', content: 'Check the new shader pack I made', is_read: 1, created_at: '2026-09-15 06:44:00' },
    { id: 'dm6', sender_id: 'u7', receiver_id: 'u1', content: 'Tournament brackets are up!', is_read: 0, created_at: '2026-09-15 04:44:00' },
    { id: 'dm7', sender_id: 'u8', receiver_id: 'u1', content: 'voicechat later?', is_read: 1, created_at: '2026-09-14 09:44:00' },
  ];

  for (const d of dms) {
    insertDM.run(d.id, d.sender_id, d.receiver_id, d.content, d.is_read, d.created_at);
  }

  // Insert Notifications for u1
  const insertNotification = db.prepare(`
    INSERT INTO notifications (id, user_id, actor_id, type, title, body, time_display, is_read)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const notifs = [
    { id: 'n1', user_id: 'u1', actor_id: 'u1', type: 'mention', title: 'Kaelen mentioned you', body: '#lounge in Neon Arcade', time_display: '2m', is_read: 0 },
    { id: 'n2', user_id: 'u1', actor_id: 'u2', type: 'reaction', title: 'Nyx reacted 🤯 to your clip', body: 'Sector 9 gameplay', time_display: '15m', is_read: 0 },
    { id: 'n3', user_id: 'u1', actor_id: 'u4', type: 'friend', title: 'Mira_Lofi sent you a friend request', body: 'Mutual servers: 3', time_display: '1h', is_read: 1 },
    { id: 'n4', user_id: 'u1', actor_id: 'u1', type: 'voice', title: 'Chill Beats voice channel is live', body: '6 members connected', time_display: '2h', is_read: 1 },
    { id: 'n5', user_id: 'u1', actor_id: null, type: 'system', title: 'You earned the "Night Owl" badge', body: 'Active after midnight for 7 days', time_display: '1d', is_read: 1 },
    { id: 'n6', user_id: 'u1', actor_id: null, type: 'system', title: 'System: Maintenance complete', body: 'All voice nodes operational', time_display: '1d', is_read: 1 },
    { id: 'n7', user_id: 'u1', actor_id: 'u7', type: 'server', title: 'Pixel Artists Guild invited you', body: 'Join the weekly art jam', time_display: '1d', is_read: 1 },
  ];

  for (const n of notifs) {
    insertNotification.run(n.id, n.user_id, n.actor_id, n.type, n.title, n.body, n.time_display, n.is_read);
  }

  console.log('✅ Seeding completed successfully!');
}

if (process.argv[1].endsWith('seed.js')) {
  seedDB();
}
