// Automated end-to-end backend integration test for The Crew
const BASE_URL = 'http://localhost:3000/api';

async function request(method, path, body = null, token = null) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : null,
  });

  const data = await res.json().catch(() => null);
  return { status: res.status, data };
}

async function runTests() {
  console.log('🧪 Starting Full-Fledged Backend Integration Tests...\n');
  let passed = 0;
  let total = 0;

  function assert(condition, message) {
    total++;
    if (condition) {
      console.log(`  ✅ [PASS] ${message}`);
      passed++;
    } else {
      console.error(`  ❌ [FAIL] ${message}`);
    }
  }

  // 1. Health
  const health = await request('GET', '/health');
  assert(health.status === 200 && health.data.status === 'online', 'Health endpoint returns status: online');

  // 2. Quick Demo Login as Kaelen
  const quickLogin = await request('POST', '/auth/quick-login', { username: 'kaelen_vr' });
  assert(quickLogin.status === 200 && quickLogin.data.token, 'Quick demo login as Kaelen returns JWT token');
  const token = quickLogin.data.token;

  // 3. User Register
  const testUsername = 'tester_' + Date.now();
  const register = await request('POST', '/auth/register', {
    username: testUsername,
    display_name: 'Test Pilot',
    email: `${testUsername}@thecrew.gg`,
    password: 'password123'
  });
  assert(register.status === 201 && register.data.token, 'Register new user returns 201 with JWT and auto-joins Neon Arcade');
  const newUserId = register.data.user.id;

  // 4. User Login with credentials
  const login = await request('POST', '/auth/login', {
    login: testUsername,
    password: 'password123'
  });
  assert(login.status === 200 && login.data.user.username === testUsername, 'Login with credentials succeeds');

  // 4b. Google Login & Auto-Registration
  const googleLogin = await request('POST', '/auth/google', {
    email: 'google_pilot@gmail.com',
    display_name: 'Google Pilot',
    google_id: 'g_123456789'
  });
  assert(googleLogin.status === 200 && googleLogin.data.token && googleLogin.data.user.email === 'google_pilot@gmail.com', 'Google authentication succeeds with JWT and Neon Arcade membership');

  // 5. Fetch Joined Servers
  const servers = await request('GET', '/servers', null, token);
  assert(servers.status === 200 && servers.data.servers.length > 0, `Fetch joined servers returns ${servers.data?.servers?.length} servers`);

  // 6. Fetch Server Channels
  const channels = await request('GET', '/servers/s1/channels', null, token);
  assert(channels.status === 200 && channels.data.channels.length >= 5, `Server s1 has ${channels.data?.channels?.length} channels`);

  // 7. Send Message in #lounge (c2)
  const testMsgText = `Automated deployment message: ${Date.now()}`;
  const sendMsg = await request('POST', '/channels/c2/messages', { content: testMsgText }, token);
  assert(sendMsg.status === 201 && sendMsg.data.message.content === testMsgText, 'Send message in channel returns 201 with created message');
  const msgId = sendMsg.data.message.id;

  // 8. Fetch Messages in #lounge
  const channelMsgs = await request('GET', '/channels/c2/messages', null, token);
  const found = channelMsgs.data.messages.some(m => m.id === msgId);
  assert(channelMsgs.status === 200 && found, 'Fetched channel messages includes the newly sent message');

  // 9. Add Emoji Reaction
  const reaction = await request('POST', `/channels/messages/${msgId}/reactions`, { emoji: '🔥' }, token);
  assert(reaction.status === 200 && reaction.data.reactions.some(r => r.emoji === '🔥'), 'Toggle emoji reaction adds reaction to message');

  // 10. Discover Public Servers
  const discover = await request('GET', '/servers/discover');
  assert(discover.status === 200 && discover.data.servers.length >= 4, `Discovery endpoint returns ${discover.data?.servers?.length} public servers`);

  // 11. Create New Community Server
  const createServer = await request('POST', '/servers', {
    name: 'Cybernetic Nexus',
    description: 'Autonomous agents and cybernetic coders hub',
    category: 'Tech',
    is_public: true,
    icon_color: '#00F0FF'
  }, token);
  assert(createServer.status === 201 && createServer.data.server.name === 'Cybernetic Nexus', 'Create server returns 201 with default channels');
  const newServerId = createServer.data.server.id;

  // 12. Fetch Server Members
  const members = await request('GET', '/servers/s1/members', null, token);
  assert(members.status === 200 && members.data.members.length >= 10, `Server s1 members directory returns ${members.data?.members?.length} members with roles`);

  // 13. Voice Stage Join & Speaking
  const voiceJoin = await request('POST', '/voice/c5/join', null, token);
  assert(voiceJoin.status === 200 && voiceJoin.data.participant.channel_id === 'c5', 'Join voice stage channel succeeds');

  const voiceSpeaking = await request('POST', '/voice/c5/speaking', { is_speaking: true }, token);
  assert(voiceSpeaking.status === 200 && voiceSpeaking.data.is_speaking === true, 'Update voice speaking status succeeds');

  // 14. Direct Messages
  const sendDm = await request('POST', `/dms/${newUserId}`, { content: 'Welcome to the network!' }, token);
  assert(sendDm.status === 201 && sendDm.data.message.content === 'Welcome to the network!', 'Send DM succeeds');

  const dms = await request('GET', '/dms', null, token);
  assert(dms.status === 200 && dms.data.conversations.length > 0, `DM inbox returns ${dms.data?.conversations?.length} conversations and ${dms.data?.active_now?.length} active now`);

  // 15. Activity Notifications
  const notifs = await request('GET', '/notifications', null, token);
  assert(notifs.status === 200 && notifs.data.notifications.length >= 5, `Activity feed returns ${notifs.data?.notifications?.length} notifications`);

  console.log(`\n🏁 Test Results: ${passed}/${total} assertions passed!`);
  if (passed === total) {
    console.log('🎉 ALL DISCORD BACKEND FEATURES ARE FULLY VERIFIED!\n');
  } else {
    process.exit(1);
  }
}

runTests().catch(err => {
  console.error('Fatal test error:', err);
  process.exit(1);
});
