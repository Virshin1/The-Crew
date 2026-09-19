import puppeteer from 'puppeteer-core';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const screenshotsDir = path.resolve(__dirname, '../docs/screenshots');
const outputPdfPath = path.resolve(__dirname, '../docs/The_Crew_Mobile_App_Architecture_and_UI_Specification.pdf');

function getBase64(filename) {
  const filePath = path.join(screenshotsDir, filename);
  if (!fs.existsSync(filePath)) {
    console.warn(`File not found: ${filePath}`);
    return '';
  }
  const data = fs.readFileSync(filePath);
  return `data:image/png;base64,${data.toString('base64')}`;
}

const screensData = [
  {
    id: '01',
    name: 'Splash & Protocol Initialization',
    file: '01_splash.png',
    route: '/splash',
    access: 'Public / Boot Entrypoint',
    category: 'Lifecycle & Initialization',
    summary: 'The initial application gateway that boots the Flutter runtime, verifies backend service health, and restores persistent authentication credentials from local storage.',
    components: [
      'Top network telemetry bar displaying active protocol version (v2.4) and live latency ping (18ms).',
      'Centered geometric chat bubble brand logo with subtle state feedback.',
      'Core system identity statement: "Where gaming, soundscapes, and aesthetic spaces connect."',
      'Node synchronization progress bar indicating runtime bootstrap status (100%).',
      'Primary CTA button "Get Started / Log In" alongside direct secondary access buttons.'
    ],
    technical: {
      providers: 'AuthProvider (restoreSession)',
      endpoints: 'GET /api/health (status ping & latency telemetry)',
      storage: 'SharedPreferences (auth_token, auth_user)',
      sockets: 'Initiates WebSocket handshake if valid JWT found in cache',
      tables: 'users (session validation)'
    },
    ux: 'Automatically queries local device storage. If a valid JWT session exists, the app transitions seamlessly to the main server hub without requiring user intervention. If first-time launch, presents authentication choices.'
  },
  {
    id: '02',
    name: 'Welcome & Onboarding Portal',
    file: '02_welcome.png',
    route: '/welcome',
    access: 'Public / Welcome Flow',
    category: 'Brand & Architecture Introduction',
    summary: 'The primary user onboarding screen introducing users to The Crew’s spatial audio, 4K screen streaming, and aesthetic glass room capabilities.',
    components: [
      'Interactive "Nightclub Mode Live" pill with real-time listener counter badge (42k Tuning In).',
      'High-contrast headline typography: "Hang out with your crew in style".',
      'Feature showcase cards detailing Spatial Audio (360° lounge acoustics), 4K Zero-latency Streaming, and Aesthetic Glass Rooms.',
      'Active voice lobby badge featuring stacked avatar circles (DJ, VR, +8) and graphic equalizer icon.',
      'Full-width primary action "CREATE ACCOUNT" button and secondary outlined "Log In" button.'
    ],
    technical: {
      providers: 'NavigationService, AuthProvider',
      endpoints: 'Static local feature definitions with dynamic telemetry pills',
      storage: 'None required (stateless presentation)',
      sockets: 'Passive connection listener',
      tables: 'N/A'
    },
    ux: 'Presents an intuitive overview of platform capabilities with immediate routing triggers for both new account registration and existing user login.'
  },
  {
    id: '03',
    name: 'Authentication & Quick Demo Login',
    file: '03_login.png',
    route: '/login',
    access: 'Public / Authentication Form',
    category: 'Security & Access Control',
    summary: 'Secure login screen supporting traditional password authentication, device persistence, social OAuth, and an instant one-click developer quick-login dock.',
    components: [
      'Standardized form input fields for Username/Email and Password with toggleable visibility.',
      'Remember this device toggle switch with animated state persistence.',
      'One-Click Demo Login dock featuring instant persona switches: "Kaelen (Owner)" and "Nyx (VIP)".',
      'Google Sign-In integration and third-party authentication shortcuts (Discord, Passkey).',
      'Top navigation bar with back arrow and branding logo.'
    ],
    technical: {
      providers: 'AuthProvider (login, quickLogin, googleLogin)',
      endpoints: 'POST /api/auth/login, POST /api/auth/quick-login, POST /api/auth/google',
      storage: 'SharedPreferences: stores JWT token & user model',
      sockets: 'Authenticates socket connection with JWT Bearer handshake',
      tables: 'users (credential check & bcrypt hash comparison)'
    },
    ux: 'Facilitates fast evaluation and credentialed access. The one-click demo pills bypass manual typing for rapid feature inspection while retaining full server-side JWT verification.'
  },
  {
    id: '04',
    name: 'Account Registration & Personalization',
    file: '04_create_account.png',
    route: '/create-account',
    access: 'Public / User Registration',
    category: 'User Provisioning',
    summary: 'Account creation flow enabling new members to register unique usernames, custom display handles, email verification, and select gaming interest tags.',
    components: [
      'Multi-step user profile inputs: Display Name, Unique Handle (@username), Email, and Password.',
      'Dynamic input validation indicators providing real-time feedback on handle availability.',
      'Interactive interest chips (Gaming, Tech, Music, Anime, Esports) stored in user profile.',
      'Terms of Service and Community Guidelines consent checkbox.',
      'High-contrast "COMPLETE REGISTRATION" button.'
    ],
    technical: {
      providers: 'AuthProvider (register)',
      endpoints: 'POST /api/auth/register',
      storage: 'Saves issued JWT token upon successful creation',
      sockets: 'Emits presence:updated event to announce new user join',
      tables: 'users (inserts new user record with default status and bio)'
    },
    ux: 'Validates input fields synchronously on the client and server. Upon successful account creation, it immediately initializes the authenticated session.'
  },
  {
    id: '05',
    name: 'Servers Hub & Live Channel Chat',
    file: '05_servers_chat.png',
    route: '/servers',
    access: 'Authenticated (Shell Tab 0)',
    category: 'Core Messaging & Channels',
    summary: 'The central hub of The Crew featuring a multi-server vertical navigation rail, channel switcher, active voice stage banner, live rich chat messages, and emoji reactions.',
    components: [
      'Left vertical server navigation rail with colored server badges, active indicator pill, and "+" add server button.',
      'Top channel switcher showing current server ("Neon Arcade LVL 3") and horizontal text channels (#welcome, #lounge).',
      'Persistent voice stage banner showing live participants (K, N, +4) with single-tap join.',
      'Rich message cards showing user avatar, role badges (OWNER, VIP), timestamps, media attachments, and emoji reactions.',
      'Bottom message input bar with attachment button, emoji picker trigger, and send button, positioned safely above bottom navigation.'
    ],
    technical: {
      providers: 'ServerProvider, ChatProvider, AuthProvider',
      endpoints: 'GET /api/servers, GET /api/servers/:id/channels, GET /api/channels/:id/messages, POST /api/channels/:id/messages, POST /api/channels/messages/:id/reactions',
      storage: 'Caches active server and active channel IDs',
      sockets: 'channel:join, channel:leave, message:new, reaction:updated, typing:start/stop',
      tables: 'servers, server_members, channels, messages, reactions, users'
    },
    ux: 'Instantaneous switching between servers and channels without reloads. Real-time message streaming with sub-second WebSocket dispatch.'
  },
  {
    id: '06',
    name: 'Spatial Voice Channel & Live Stage',
    file: '06_voice_channel.png',
    route: '/servers/voice',
    access: 'Authenticated (Modal / Full Route)',
    category: 'Audio & Live Stage',
    summary: 'Low-latency spatial audio stage featuring high-bitrate Opus stream status, live screen sharing previews, participant audio state tracking, and quick controls.',
    components: [
      'Channel status card: "Chill Beats & Gaming", RTC Node (Frankfurt • 18ms), 384kbps Opus audio badge.',
      'Live stream preview card with live status indicator and host broadcast text.',
      'Participant grid showing who is speaking, muted, or streaming.',
      'Bottom floating audio action dock: Microphone toggle (mute/unmute), Deafen toggle, Participants sheet, and Disconnect button.',
      'Top navigation bar with back navigation and participant count.'
    ],
    technical: {
      providers: 'VoiceProvider, ServerProvider',
      endpoints: 'GET /api/voice/:channelId, POST /api/voice/:channelId/join, POST /api/voice/:channelId/leave, POST /api/voice/:channelId/toggle-mute, POST /api/voice/:channelId/speaking',
      storage: 'Active voice session state stored in VoiceProvider',
      sockets: 'voice:join, voice:leave, voice:joined, voice:left, voice:mute_updated, voice:speaking_updated',
      tables: 'voice_participants, channels, users'
    },
    ux: 'Provides clear visual cues for audio state transitions. Microphone mute and deafen toggles provide immediate tactile and visual feedback.'
  },
  {
    id: '07',
    name: 'Server Member Directory & Hierarchy',
    file: '07_member_list.png',
    route: '/servers/members',
    access: 'Authenticated (Server Drawer)',
    category: 'Directory & Permissions',
    summary: 'Hierarchical server member directory categorizing community members by permission level with live status dots, custom game activity, and profile triggers.',
    components: [
      'Top app bar showing server name ("Neon Arcade"), Members title, and "19 ONLINE" badge.',
      'Role-based grouping sections: OWNER (1), ADMINS (1), VIP (4), MEMBERS (13).',
      'Member cards displaying display name, role pill, live status indicator, and current activity status.',
      'Tap-to-profile gesture detector allowing direct messaging or role inspection.',
      'Smooth vertical scrolling with sliver-based performance optimization.'
    ],
    technical: {
      providers: 'ServerProvider (members list)',
      endpoints: 'GET /api/servers/:serverId/members',
      storage: 'Server member cache',
      sockets: 'presence:updated (live status synchronization)',
      tables: 'server_members, users'
    },
    ux: 'Gives server owners and members an organized hierarchy of current community members, distinguishing leadership from regular members.'
  },
  {
    id: '08',
    name: 'Direct Messages Inbox & Active Squad',
    file: '08_dm_inbox.png',
    route: '/messages',
    access: 'Authenticated (Shell Tab 1)',
    category: 'Direct Messaging',
    summary: 'Private messaging hub featuring a top horizontal "Active Now" squad story rail, search bar, and conversation cards with unread notification pills.',
    components: [
      'Top app bar with Messages title, manual refresh action, and user avatar shortcut.',
      'Integrated search field for filtering direct conversations and squad members.',
      'Horizontal "ACTIVE NOW" stories rail with user avatar, name, and online status dot.',
      'Conversation list showing partner name, snippet of latest message, timestamp, and unread count badge.',
      'One-tap navigation into dedicated 1-on-1 private chat threads.'
    ],
    technical: {
      providers: 'DmProvider, AuthProvider',
      endpoints: 'GET /api/dms (fetches active_now users & recent conversations)',
      storage: 'Recent DM conversations cache',
      sockets: 'dm:new (updates inbox snippet and bumps unread count in real-time)',
      tables: 'direct_messages, users'
    },
    ux: 'Adopts mobile-native conversation listing patterns. The top rail provides one-tap reach to online friends, while the list below orders active threads chronologically.'
  },
  {
    id: '09',
    name: '1-on-1 Direct Message Conversation',
    file: '09_dm_chat.png',
    route: '/messages/chat/:userId',
    access: 'Authenticated (Nested Route)',
    category: 'Private Chat Thread',
    summary: 'Full-screen private direct chat interface between two users, supporting real-time messaging, delivery status indicators, and partner profile inspection.',
    components: [
      'Custom app bar featuring partner avatar with online dot, partner name ("Nyx"), status ("Editing clips"), voice call button, and info button.',
      'Asymmetric chat bubbles: Right-aligned bubbles for the authenticated user; Left-aligned bubbles for the chat partner.',
      'Delivery timestamp and double-check read status markers.',
      'Bottom message composition bar with attachment trigger, text field ("Message @Nyx..."), and send button.',
      'Full back-navigation support with GoRouter integration.'
    ],
    technical: {
      providers: 'DmProvider (loadDmThread, sendDm)',
      endpoints: 'GET /api/dms/:userId, POST /api/dms/:userId',
      storage: 'Caches active thread message history',
      sockets: 'dm:new (listens on personal room user_<id> for instant message reception)',
      tables: 'direct_messages (updates is_read=1 on thread open)'
    },
    ux: 'Private, secure chat thread that automatically marks unread messages as read upon viewing and receives incoming messages without requiring page reloads.'
  },
  {
    id: '10',
    name: 'Community Discovery & Exploration',
    file: '10_community_discovery.png',
    route: '/discover',
    access: 'Authenticated (Shell Tab 2)',
    category: 'Public Discovery',
    summary: 'Public server discovery portal allowing users to explore featured gaming guilds, music hubs, and art communities with rich category filtering and search.',
    components: [
      'Top search bar: "Find servers, hubs & soundscapes..." with real-time query debounce.',
      'Category filter chips: Featured, Gaming, Anime & Art, Music, Tech.',
      'Trending Communities header displaying total available hubs count ("10 HUBS").',
      'Rich community cards with server icon, level badge (LVL 3), member metrics ("19 Online • 21 Members"), description, and tags.',
      'Action button on cards: "Joined" indicator for joined communities or "Join Server" for new communities.'
    ],
    technical: {
      providers: 'ServerProvider (fetchDiscoverServers, joinServer)',
      endpoints: 'GET /api/servers/discover?category=...&search=..., POST /api/servers/:id/join',
      storage: 'Caches discovery results and category states',
      sockets: 'Passive socket state',
      tables: 'servers, server_members, users'
    },
    ux: 'Enables exploration of public hubs with intuitive category chips and instant join actions that immediately reflect in the user\'s server rail.'
  },
  {
    id: '11',
    name: 'Community Creation & Setup',
    file: '11_create_community.png',
    route: '/discover/create',
    access: 'Authenticated (Modal / Route)',
    category: 'Server Provisioning',
    summary: 'Server provisioning wizard allowing community creators to launch custom hubs, select branding colors, configure privacy settings, and auto-provision channels.',
    components: [
      'Server Name and Description input fields with helpful placeholder examples.',
      'Interactive Icon Color Palette picker (Neon Violet, Cyber Mint, Electric Pink, Sunset Orange, Bright Cyan).',
      'Category selection dropdown (Gaming, Music, Art, Tech, Cozy).',
      'Public vs. Private Community toggle switch with explanatory privacy caption.',
      'Large "CREATE COMMUNITY" action button that provisions default channels (#welcome, #lounge, #media-share, Lounge Voice).'
    ],
    technical: {
      providers: 'ServerProvider (createServer)',
      endpoints: 'POST /api/servers',
      storage: 'Adds new server to joinedServers list',
      sockets: 'Emits server:created event to update member client rails',
      tables: 'servers (insert), server_members (inserts creator as OWNER), channels (provisions 4 default channels)'
    },
    ux: 'Simplifies server initialization into a single screen, automatically creating essential channel templates and assigning admin roles.'
  },
  {
    id: '12',
    name: 'Activity Feed & Real-time Notifications',
    file: '12_notifications.png',
    route: '/activity',
    access: 'Authenticated (Shell Tab 3)',
    category: 'Alerts & Telemetry',
    summary: 'Centralized activity feed organizing mentions, message reactions, friend requests, and system announcements into categorized filter tabs.',
    components: [
      'Top app bar with Activity title, "Mark All as Read" double-check icon, and user avatar.',
      'Filter tabs: All, Mentions, Reactions, System.',
      'Detailed notification cards with category icons (@ mention, reaction, friend, system).',
      'Dynamic time elapsed indicators (2m, 15m, 1h, 1d) and unread indicator dot.',
      'One-tap dismissal and automatic read status persistence.'
    ],
    technical: {
      providers: 'NotificationProvider',
      endpoints: 'GET /api/notifications?type=..., POST /api/notifications/:id/read, POST /api/notifications/read-all',
      storage: 'Caches notifications list and unread badge count',
      sockets: 'Listens for incoming mention and reaction alerts',
      tables: 'notifications, users'
    },
    ux: 'Keeps users informed on mentions, reactions, and community events with categorized filters to prevent notification fatigue.'
  },
  {
    id: '13',
    name: 'User Profile & Identity Dashboard',
    file: '13_user_profile.png',
    route: '/profile',
    access: 'Authenticated (Shell Tab 4)',
    category: 'User Identity & Stats',
    summary: 'Rich user identity dashboard showcasing user avatar, status pill selector, custom bio, earned achievement badges, and a drawer of joined servers.',
    components: [
      'Top banner header with profile gear settings shortcut and app logo.',
      'Centered elevated circular avatar with initial or profile picture.',
      'Username and handle: "Kaelen @kaelen_vr", "Member of The Crew Network".',
      'Status dropdown selector (ONLINE, IDLE, DND, INVISIBLE).',
      'Custom bio card: "Raid commander. Neon fanatic. Sector 9 champion."',
      'Achievement badges: Verified, Crew Core, Night Owl, Booster.',
      'Quick action buttons: Edit Profile, DMs, Settings, and Joined Servers drawer (8 servers).'
    ],
    technical: {
      providers: 'AuthProvider, ServerProvider',
      endpoints: 'GET /api/auth/me, PUT /api/auth/profile, GET /api/servers',
      storage: 'Syncs profile changes to SharedPreferences',
      sockets: 'presence:updated broadcast to all connected clients',
      tables: 'users, server_members, servers'
    },
    ux: 'Serves as the personal identity hub where members manage their public status, bio, and review community memberships.'
  },
  {
    id: '14',
    name: 'Settings & Security Preferences',
    file: '14_settings.png',
    route: '/profile/settings',
    access: 'Authenticated (Nested Route)',
    category: 'Configuration & Security',
    summary: 'Comprehensive settings panel managing account security, two-factor authentication, active device sessions, appearance shortcuts, and notification toggles.',
    components: [
      'Top user mini-card with avatar, display name, handle, and online indicator.',
      'Account Security section: Edit Profile, Password & Security (2FA, recovery codes), Active Sessions (Connected to The Crew Backend).',
      'Appearance section: Customize Theme, Chat Display layout, Dark Mode selector.',
      'Notification switches: Push Notifications (toggle), Email Notifications (toggle), Sound Effects (toggle).',
      'Log Out action button with session cleanup.'
    ],
    technical: {
      providers: 'AuthProvider, NavigationService',
      endpoints: 'GET /api/auth/me, POST /api/auth/logout',
      storage: 'Clears stored token and session data on logout',
      sockets: 'Disconnects active socket session on logout',
      tables: 'users (session invalidation)'
    },
    ux: 'Standardized preference panel with clear categorized grouping, intuitive switches, and instant preference persistence.'
  },
  {
    id: '15',
    name: 'Appearance & Custom Theme Engine',
    file: '15_customize_theme.png',
    route: '/profile/theme',
    access: 'Authenticated (Nested Route)',
    category: 'Theming & Customization',
    summary: 'Interactive appearance customizer allowing users to select color palettes, adjust UI density, and tune dynamic glow effects in real-time.',
    components: [
      'Top header: "Customize Appearance - Tailor colors, density, and glow effects to match your setup vibe."',
      'Theme Palette cards: Cyber Emerald (Matrix slate & mint), Midnight Tokyo (Deep indigo slate), Pure OLED (Pitch black & stark).',
      'Interface Density segment control: Compact, Default, Spacious.',
      'Glow Effects Intensity slider (0% to 100%, currently tuned to 85% Hyper-Glow).',
      'Prominent "Apply Changes" action button that updates theme tokens across the app.'
    ],
    technical: {
      providers: 'Theme service / AppTheme provider',
      endpoints: 'PUT /api/auth/profile (persists custom theme preference)',
      storage: 'Saves themeMode and accentColor to SharedPreferences',
      sockets: 'Local state trigger',
      tables: 'users (theme_preference)'
    },
    ux: 'Enables users to customize their visual interface to their personal viewing environment (low-light gaming, OLED battery saving, or compact productivity).'
  }
];

function generateHtml() {
  const screensHtml = screensData.map((s, idx) => {
    const b64 = getBase64(s.file);
    const pageNumber = idx + 6;
    return `
    <div class="page screen-page">
      <div class="header-rule">
        <span class="hr-title">THE CREW • PROJECT SPECIFICATION REPORT</span>
        <span class="hr-meta">CONTRIBUTORS: PRANAV KALE & R VIRSHIN</span>
      </div>

      <div class="screen-title-block">
        <div class="screen-counter">SECTION 3.${idx + 1} • SCREEN SPECIFICATION</div>
        <div class="screen-name-row">
          <h2 class="screen-name">${s.name}</h2>
          <span class="code-badge">${s.route}</span>
        </div>
      </div>

      <div class="screen-grid">
        <!-- Phone Mockup Container -->
        <div class="mockup-container">
          <div class="phone-frame">
            <div class="phone-notch"></div>
            <div class="phone-screen-area">
              ${b64 ? `<img src="${b64}" alt="${s.name}" class="screen-image" />` : `<div class="missing-img">Screen Image Unavailable</div>`}
            </div>
            <div class="phone-chin-bar"></div>
          </div>
          <div class="mockup-caption">
            <strong>Figure ${idx + 1}:</strong> Mobile viewport (${s.name}, 390 × 844 pt).
          </div>
        </div>

        <!-- Specifications Breakdown -->
        <div class="spec-column">
          <div class="section-box">
            <div class="box-heading">1. FUNCTIONAL SCOPE & USER INTENT</div>
            <p class="body-p">${s.summary}</p>
          </div>

          <div class="section-box">
            <div class="box-heading">2. UI COMPONENTS & VISUAL ANATOMY</div>
            <ul class="clean-list">
              ${s.components.map(c => `
                <li>
                  <span class="list-bullet">•</span>
                  <span class="list-text">${c}</span>
                </li>
              `).join('')}
            </ul>
          </div>

          <div class="section-box">
            <div class="box-heading">3. TECHNICAL & ARCHITECTURAL MAPPING</div>
            <table class="spec-table">
              <tr>
                <td class="st-label">Route & Guard:</td>
                <td class="st-val"><code>${s.route}</code> (${s.access})</td>
              </tr>
              <tr>
                <td class="st-label">State Providers:</td>
                <td class="st-val"><code>${s.technical.providers}</code></td>
              </tr>
              <tr>
                <td class="st-label">REST API Calls:</td>
                <td class="st-val"><code>${s.technical.endpoints}</code></td>
              </tr>
              <tr>
                <td class="st-label">Socket.IO Events:</td>
                <td class="st-val"><code>${s.technical.sockets}</code></td>
              </tr>
              <tr>
                <td class="st-label">Database Tables:</td>
                <td class="st-val"><code>${s.technical.tables}</code></td>
              </tr>
            </table>
          </div>

          <div class="section-box">
            <div class="box-heading">4. USER INTERACTION FLOW & STATE VALIDATION</div>
            <p class="body-p" style="color: #4B5563;">${s.ux}</p>
          </div>
        </div>
      </div>

      <div class="footer-rule">
        <span>The Crew • Capstone Project Submission & System Specification</span>
        <span>Page ${pageNumber} of 22</span>
      </div>
    </div>
    `;
  }).join('\n');

  return `
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>The Crew - Project Submission & Architecture Specification</title>
<style>
  @page {
    size: A4 portrait;
    margin: 12mm 14mm 14mm 14mm;
  }

  * {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }

  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    background: #FFFFFF;
    color: #111827;
    line-height: 1.45;
    font-size: 10pt;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }

  .page {
    page-break-after: always;
    height: 100vh;
    max-height: 100vh;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    position: relative;
    overflow: hidden;
    background: #FFFFFF;
  }

  /* HEADERS & FOOTERS */
  .header-rule {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #111827;
    padding-bottom: 6px;
    margin-bottom: 12px;
    font-size: 8pt;
    font-weight: 700;
    letter-spacing: 0.5px;
    color: #374151;
    text-transform: uppercase;
  }

  .footer-rule {
    border-top: 1px solid #D1D5DB;
    padding-top: 6px;
    display: flex;
    justify-content: space-between;
    font-size: 8pt;
    color: #6B7280;
    margin-top: auto;
  }

  /* COVER PAGE (ACADEMIC / PROFESSIONAL REPORT FORMAT) */
  .cover-page {
    padding: 30px 24px;
    background: #FFFFFF;
    border: 2px solid #111827;
  }

  .cover-top {
    border-bottom: 2px solid #111827;
    padding-bottom: 16px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .cover-institution {
    font-size: 10pt;
    font-weight: 800;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    color: #111827;
  }

  .cover-doc-type {
    font-size: 9pt;
    font-weight: 600;
    color: #4B5563;
    letter-spacing: 0.8px;
    text-transform: uppercase;
  }

  .cover-mid {
    margin: 40px 0;
  }

  .cover-kicker {
    font-size: 11pt;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 2px;
    color: #4B5563;
    margin-bottom: 10px;
  }

  .cover-title {
    font-size: 42pt;
    line-height: 1.05;
    font-weight: 900;
    color: #000000;
    letter-spacing: -1.5px;
    margin-bottom: 16px;
  }

  .cover-subtitle {
    font-size: 14pt;
    line-height: 1.45;
    color: #374151;
    max-width: 640px;
    margin-bottom: 30px;
  }

  .cover-divider {
    width: 100%;
    height: 1px;
    background: #111827;
    margin: 24px 0;
  }

  /* CONTRIBUTORS SECTION ON COVER */
  .cover-contributors-card {
    border: 1.5px solid #111827;
    padding: 16px 20px;
    margin-bottom: 26px;
    background: #FAFAFA;
  }

  .cc-title {
    font-size: 9pt;
    font-weight: 800;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    color: #111827;
    margin-bottom: 12px;
  }

  .cc-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
  }

  .cc-box {
    border-left: 3px solid #111827;
    padding-left: 12px;
  }

  .cc-name {
    font-size: 14pt;
    font-weight: 800;
    color: #000000;
    margin-bottom: 3px;
  }

  .cc-role {
    font-size: 9pt;
    color: #4B5563;
    line-height: 1.35;
  }

  .meta-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 9pt;
    margin-top: 10px;
  }

  .meta-table td {
    padding: 4px 0;
  }

  .meta-key {
    width: 160px;
    font-weight: 700;
    color: #111827;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .meta-value {
    color: #374151;
  }

  /* REPORT CONTENT PAGES */
  .doc-page {
    padding: 8px 4px;
  }

  .page-title-block {
    margin-bottom: 14px;
    border-bottom: 1px solid #111827;
    padding-bottom: 6px;
  }

  .page-section-num {
    font-size: 8pt;
    font-weight: 800;
    letter-spacing: 1px;
    color: #6B7280;
    text-transform: uppercase;
    margin-bottom: 2px;
  }

  .page-main-title {
    font-size: 17pt;
    font-weight: 800;
    color: #000000;
    letter-spacing: -0.3px;
  }

  .text-box {
    border: 1px solid #D1D5DB;
    padding: 12px 14px;
    margin-bottom: 12px;
    background: #FAFAFA;
  }

  .tb-title {
    font-size: 10pt;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    color: #000000;
    margin-bottom: 6px;
    border-bottom: 1px solid #E5E7EB;
    padding-bottom: 4px;
  }

  .tb-p {
    font-size: 9.5pt;
    color: #374151;
    line-height: 1.45;
    margin-bottom: 6px;
  }

  .grid-2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
    margin-bottom: 12px;
  }

  /* TABLES */
  .academic-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 8.5pt;
    margin: 8px 0;
  }

  .academic-table th {
    background: #F3F4F6;
    color: #000000;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    padding: 6px 8px;
    border: 1px solid #9CA3AF;
    text-align: left;
  }

  .academic-table td {
    padding: 5px 8px;
    border: 1px solid #D1D5DB;
    color: #1F2937;
    vertical-align: top;
  }

  .academic-table tr:nth-child(even) {
    background: #FAFAFA;
  }

  .code-cell {
    font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
    font-size: 8pt;
    color: #111827;
  }

  /* SCREEN PAGES */
  .screen-page {
    padding: 8px 4px;
  }

  .screen-title-block {
    margin-bottom: 10px;
    border-bottom: 1px solid #111827;
    padding-bottom: 6px;
  }

  .screen-counter {
    font-size: 8pt;
    font-weight: 800;
    color: #4B5563;
    letter-spacing: 1px;
    text-transform: uppercase;
  }

  .screen-name-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .screen-name {
    font-size: 16pt;
    font-weight: 800;
    color: #000000;
  }

  .code-badge {
    font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
    font-size: 9pt;
    font-weight: 600;
    border: 1px solid #111827;
    padding: 2px 8px;
    background: #F3F4F6;
    color: #111827;
  }

  .screen-grid {
    display: grid;
    grid-template-columns: 240px 1fr;
    gap: 16px;
    align-items: start;
    flex-grow: 1;
  }

  /* MINIMALIST PHONE MOCKUP */
  .mockup-container {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .phone-frame {
    width: 240px;
    height: 520px; /* Exact 390x844 aspect ratio */
    border: 5px solid #111827;
    border-radius: 34px;
    background: #000000;
    position: relative;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.15);
    overflow: hidden;
  }

  .phone-notch {
    position: absolute;
    top: 5px;
    left: 50%;
    transform: translateX(-50%);
    width: 50px;
    height: 11px;
    background: #000000;
    border-radius: 6px;
    z-index: 10;
  }

  .phone-screen-area {
    width: 100%;
    height: 100%;
    overflow: hidden;
    background: #0B0E14;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .screen-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
  }

  .phone-chin-bar {
    position: absolute;
    bottom: 5px;
    left: 50%;
    transform: translateX(-50%);
    width: 60px;
    height: 3px;
    background: rgba(255, 255, 255, 0.4);
    border-radius: 2px;
    z-index: 10;
  }

  .mockup-caption {
    margin-top: 6px;
    font-size: 8pt;
    color: #6B7280;
    text-align: center;
  }

  /* DETAILS COLUMN */
  .spec-column {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .section-box {
    border: 1px solid #D1D5DB;
    padding: 8px 10px;
    background: #FFFFFF;
  }

  .box-heading {
    font-size: 8.5pt;
    font-weight: 800;
    color: #000000;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    margin-bottom: 4px;
    border-bottom: 1px solid #E5E7EB;
    padding-bottom: 2px;
  }

  .body-p {
    font-size: 9pt;
    color: #374151;
    line-height: 1.4;
  }

  .clean-list {
    list-style: none;
    padding-left: 0;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .clean-list li {
    display: flex;
    align-items: flex-start;
    gap: 6px;
    font-size: 8.5pt;
    color: #374151;
    line-height: 1.35;
  }

  .list-bullet {
    color: #111827;
    font-weight: 900;
    font-size: 10pt;
    line-height: 10pt;
  }

  .list-text {
    flex-grow: 1;
  }

  .spec-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 8.5pt;
  }

  .spec-table tr {
    border-bottom: 1px solid #F3F4F6;
  }

  .spec-table tr:last-child {
    border-bottom: none;
  }

  .spec-table td {
    padding: 3px 0;
    vertical-align: top;
  }

  .st-label {
    width: 100px;
    font-weight: 700;
    color: #111827;
  }

  .st-val {
    color: #374151;
  }

  .st-val code {
    font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
    font-size: 8pt;
    background: #F3F4F6;
    padding: 1px 4px;
    border: 1px solid #E5E7EB;
    color: #111827;
  }

  .method-tag {
    font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
    font-size: 7.5pt;
    font-weight: bold;
    padding: 1px 4px;
    border: 1px solid #111827;
    background: #F3F4F6;
    color: #111827;
  }
</style>
</head>
<body>

  <!-- PAGE 1: FORMAL ACADEMIC COVER PAGE -->
  <div class="page cover-page">
    <div class="cover-top">
      <div class="cover-institution">PROJECT SUBMISSION REPORT</div>
      <div class="cover-doc-type">TECHNICAL SPECIFICATION & DESIGN MANUAL</div>
    </div>

    <div class="cover-mid">
      <div class="cover-kicker">CAPSTONE PROJECT ARCHITECTURE DOCUMENT</div>
      <h1 class="cover-title">THE CREW</h1>
      <p class="cover-subtitle">
        Design, Architecture, and Mobile Implementation of a Real-Time Gaming Community and Spatial Communication Platform.
      </p>

      <div class="cover-divider"></div>

      <!-- CONTRIBUTORS CARD -->
      <div class="cover-contributors-card">
        <div class="cc-title">PROJECT CONTRIBUTORS</div>
        <div class="cc-grid">
          <div class="cc-box">
            <div class="cc-name">Pranav Kale</div>
            <div class="cc-role">Backend Architecture, Database Design & Real-Time Protocol Engineering</div>
          </div>
          <div class="cc-box">
            <div class="cc-name">R Virshin</div>
            <div class="cc-role">Mobile Client Engineering, State Architecture & Mobile UI/UX Design</div>
          </div>
        </div>
      </div>

      <table class="meta-table">
        <tr>
          <td class="meta-key">Project Title:</td>
          <td class="meta-value">The Crew (Gaming Community & Communication Platform)</td>
        </tr>
        <tr>
          <td class="meta-key">Technologies:</td>
          <td class="meta-value">Flutter 3.x, Dart 3.x, Node.js, Express, Socket.IO, SQLite (WAL)</td>
        </tr>
        <tr>
          <td class="meta-key">Target Viewport:</td>
          <td class="meta-value">Mobile Smartphone (390 × 844 pt @ 2x DPR / 780 × 1688 px)</td>
        </tr>
        <tr>
          <td class="meta-key">Document Version:</td>
          <td class="meta-value">1.0.0 (Final Submission)</td>
        </tr>
        <tr>
          <td class="meta-key">Date of Submission:</td>
          <td class="meta-value">September 2026</td>
        </tr>
      </table>
    </div>

    <div class="footer-rule">
      <span>The Crew • Project Submission Report</span>
      <span>Page 1 of 22</span>
    </div>
  </div>

  <!-- PAGE 2: ABSTRACT & DECLARATION -->
  <div class="page doc-page">
    <div class="header-rule">
      <span class="hr-title">THE CREW • PROJECT SPECIFICATION REPORT</span>
      <span class="hr-meta">CONTRIBUTORS: PRANAV KALE & R VIRSHIN</span>
    </div>

    <div class="page-title-block">
      <div class="page-section-num">SECTION 1.0</div>
      <h1 class="page-main-title">Project Abstract & Declaration of Originality</h1>
    </div>

    <div class="text-box">
      <div class="tb-title">1.1 Project Abstract</div>
      <p class="tb-p">
        Digital gaming squads, competitive esports teams, and modern creative communities rely heavily on real-time communication systems that provide immediate responsiveness, low-latency audio signaling, and organized text spaces. Legacy communication clients often suffer from platform bloat, intrusive tracking, slow startup times, and complex navigation structures that diminish mobile usability.
      </p>
      <p class="tb-p">
        <strong>The Crew</strong> is engineered from first principles as an integrated cross-platform mobile client and real-time backend service. Built using Flutter and Dart on the client side, backed by an Express and Socket.IO microservice architecture with an embedded high-performance SQLite engine, the system delivers sub-second message delivery, immediate emoji reactions, live presence heartbeats, and private direct messaging in a clean, ergonomic mobile viewport.
      </p>
    </div>

    <div class="grid-2">
      <div class="text-box">
        <div class="tb-title">1.2 Key Project Objectives</div>
        <p class="tb-p">• <strong>Mobile Ergonomics:</strong> Deliver a native-grade 390×844 pt smartphone experience with responsive layouts.</p>
        <p class="tb-p">• <strong>Event-Driven State:</strong> Establish bidirectional WebSocket channels for immediate message delivery and presence.</p>
        <p class="tb-p">• <strong>Zero-Configuration Startup:</strong> Embed an autonomous SQLite WAL database engine with automatic schema migrations.</p>
        <p class="tb-p">• <strong>Granular Security:</strong> Enforce bcrypt password hashing (10 salt rounds) and signed JSON Web Tokens (JWT).</p>
      </div>

      <div class="text-box">
        <div class="tb-title">1.3 Declaration of Originality</div>
        <p class="tb-p">
          We hereby declare that this project titled <strong>"The Crew: Real-Time Gaming Community & Spatial Communication Platform"</strong> is an original work designed, implemented, and submitted by:
        </p>
        <div style="background: #FFFFFF; border: 1px solid #D1D5DB; padding: 8px 10px; margin: 6px 0;">
          <p style="font-weight: 700; color: #000000; font-size: 9pt;">• Pranav Kale</p>
          <p style="font-size: 8pt; color: #4B5563; margin-bottom: 4px;">Backend Architecture, Database Design & Socket Protocols</p>
          <p style="font-weight: 700; color: #000000; font-size: 9pt;">• R Virshin</p>
          <p style="font-size: 8pt; color: #4B5563;">Mobile Application Engineering, UI/UX & State Architecture</p>
        </div>
      </div>
    </div>

    <div class="text-box">
      <div class="tb-title">1.4 Engineering Deliverables & Milestones</div>
      <table class="academic-table">
        <thead>
          <tr>
            <th style="width: 120px;">Milestone</th>
            <th style="width: 140px;">Deliverable</th>
            <th>Verification Criteria</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>Client Application</strong></td>
            <td>Flutter 3.x Mobile App</td>
            <td>15 screens, GoRouter shell navigation, Provider state management, 0 linter issues.</td>
          </tr>
          <tr>
            <td><strong>API Gateway</strong></td>
            <td>Express REST Engine</td>
            <td>18+ endpoints covering Auth, Servers, Channels, Messages, DMs, Voice, and Notifications.</td>
          </tr>
          <tr>
            <td><strong>Real-Time Pipeline</strong></td>
            <td>Socket.IO Event Cluster</td>
            <td>Sub-second dispatch for live chat, typing indicators, reactions, and audio states.</td>
          </tr>
          <tr>
            <td><strong>Data Persistence</strong></td>
            <td>SQLite (WAL Mode)</td>
            <td>9 relational tables with foreign keys and cascade delete rules, auto-seeded on boot.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="footer-rule">
      <span>The Crew • Capstone Project Submission & System Specification</span>
      <span>Page 2 of 22</span>
    </div>
  </div>

  <!-- PAGE 3: HIGH-LEVEL SYSTEM ARCHITECTURE -->
  <div class="page doc-page">
    <div class="header-rule">
      <span class="hr-title">THE CREW • PROJECT SPECIFICATION REPORT</span>
      <span class="hr-meta">CONTRIBUTORS: PRANAV KALE & R VIRSHIN</span>
    </div>

    <div class="page-title-block">
      <div class="page-section-num">SECTION 2.0</div>
      <h1 class="page-main-title">High-Level System Architecture</h1>
    </div>

    <div class="grid-2">
      <div class="text-box">
        <div class="tb-title">2.1 System Architecture Overview</div>
        <p class="tb-p">
          The system follows a decoupled 3-tier architecture designed for scalability, maintainability, and low-latency interaction:
        </p>
        <p class="tb-p">
          1. <strong>Presentation Tier (Mobile Client):</strong> Written in Dart using Flutter. Handles all rendering, gesture interpretation, and localized state caching. Communicates via REST for transactional state changes and WebSockets for real-time synchronization.
        </p>
        <p class="tb-p">
          2. <strong>Application Tier (API Gateway & Real-Time Server):</strong> Built with Node.js, Express, and Socket.IO. Manages authentication, business logic validation, route protection, and socket room membership.
        </p>
        <p class="tb-p">
          3. <strong>Data Tier (Persistence):</strong> Structured relational storage powered by SQLite using <code>better-sqlite3</code>. Write-Ahead Logging (WAL) is enabled to support concurrent read operations alongside write transactions.
        </p>
      </div>

      <div class="text-box">
        <div class="tb-title">2.2 Network Topology & Event Flow</div>
        <p class="tb-p">
          Socket connections are authenticated at connection time using Bearer JWT tokens. Upon handshake, sockets join granular rooms:
        </p>
        <p class="tb-p">• <code>user_&lt;id&gt;</code>: Private room for direct messages and direct mentions.</p>
        <p class="tb-p">• <code>channel_&lt;id&gt;</code>: Text channel room for chat messages, reactions, and typing states.</p>
        <p class="tb-p">• <code>voice_&lt;id&gt;</code>: Voice room for participant joined, left, speaking, and mute events.</p>
        <p class="tb-p">
          This room-based segmentation avoids broadcast overhead across non-participating clients, ensuring low resource usage.
        </p>
      </div>
    </div>

    <div class="text-box">
      <div class="tb-title">2.3 Three-Tier Component Diagram</div>
      <table class="academic-table">
        <thead>
          <tr>
            <th style="width: 140px;">Architecture Tier</th>
            <th style="width: 180px;">Core Technologies</th>
            <th>Primary Responsibilities</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>Tier 1: Client Layer</strong></td>
            <td>Flutter 3.x, Dart 3.x, GoRouter, Provider, SharedPreferences</td>
            <td>UI rendering, user input handling, offline session restoration, socket message consumption, dynamic theme engine.</td>
          </tr>
          <tr>
            <td><strong>Tier 2: Service Layer</strong></td>
            <td>Node.js 25, Express.js, Socket.IO 4.x, bcryptjs, jsonwebtoken</td>
            <td>HTTP API endpoints, JWT token issuance and verification, WebSocket event broadcast, room lifecycle management.</td>
          </tr>
          <tr>
            <td><strong>Tier 3: Database Layer</strong></td>
            <td>SQLite 3 (WAL Mode), better-sqlite3 engine</td>
            <td>Relational data persistence, foreign key enforcement, transaction management, auto-seeding engine on startup.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="footer-rule">
      <span>The Crew • Capstone Project Submission & System Specification</span>
      <span>Page 3 of 22</span>
    </div>
  </div>

  <!-- PAGE 4: DOCUMENT SITEMAP & SPECIFICATIONS INDEX -->
  <div class="page doc-page">
    <div class="header-rule">
      <span class="hr-title">THE CREW • PROJECT SPECIFICATION REPORT</span>
      <span class="hr-meta">CONTRIBUTORS: PRANAV KALE & R VIRSHIN</span>
    </div>

    <div class="page-title-block">
      <div class="page-section-num">SECTION 3.0</div>
      <h1 class="page-main-title">Screen Catalog & Specification Index</h1>
    </div>

    <div class="text-box">
      <div class="tb-title">3.0 Complete 15-Screen Mobile Catalog</div>
      <table class="academic-table">
        <thead>
          <tr>
            <th style="width: 35px;">#</th>
            <th style="width: 160px;">Screen Title</th>
            <th style="width: 140px;">Route Path</th>
            <th style="width: 120px;">Category</th>
            <th>Architectural Purpose</th>
          </tr>
        </thead>
        <tbody>
          ${screensData.map(s => `
          <tr>
            <td><strong>${s.id}</strong></td>
            <td><strong>${s.name}</strong></td>
            <td class="code-cell">${s.route}</td>
            <td>${s.category}</td>
            <td>${s.summary.substring(0, 85)}...</td>
          </tr>
          `).join('')}
        </tbody>
      </table>
    </div>

    <div class="grid-2">
      <div class="text-box">
        <div class="tb-title">Mobile Device Standard</div>
        <p class="tb-p"><strong>Logical Dimensions:</strong> 390 × 844 pt (iPhone 14/15/16 baseline)</p>
        <p class="tb-p"><strong>Physical Resolution:</strong> 780 × 1688 px @ 2.0x Device Pixel Ratio</p>
        <p class="tb-p"><strong>Input Modality:</strong> Capacitive touch gestures, kinetic scroll</p>
      </div>

      <div class="text-box">
        <div class="tb-title">Design System Baseline</div>
        <p class="tb-p"><strong>Typography:</strong> Inter (sans-serif) across 8 scale steps</p>
        <p class="tb-p"><strong>Surfaces:</strong> High-contrast OLED dark tokens (0x0B0E14)</p>
        <p class="tb-p"><strong>Accents:</strong> Emerald Mint (0x00FFB2) and Neon Violet (0x9D4EDD)</p>
      </div>
    </div>

    <div class="footer-rule">
      <span>The Crew • Capstone Project Submission & System Specification</span>
      <span>Page 4 of 22</span>
    </div>
  </div>

  <!-- PAGE 5: STATE MANAGEMENT & ROUTING SPECIFICATION -->
  <div class="page doc-page">
    <div class="header-rule">
      <span class="hr-title">THE CREW • PROJECT SPECIFICATION REPORT</span>
      <span class="hr-meta">CONTRIBUTORS: PRANAV KALE & R VIRSHIN</span>
    </div>

    <div class="page-title-block">
      <div class="page-section-num">SECTION 3.0 (CONT.)</div>
      <h1 class="page-main-title">Client State Management & Routing Architecture</h1>
    </div>

    <div class="grid-2">
      <div class="text-box">
        <div class="tb-title">3.0.1 Indexed Shell Routing (GoRouter)</div>
        <p class="tb-p">
          Navigation is structured using <code>GoRouter</code> and <code>StatefulShellRoute.indexedStack</code>. This architecture ensures that each primary navigation branch maintains its independent navigation state and scroll offset in memory when switching tabs.
        </p>
        <p class="tb-p">
          Full-screen modal routes (such as <code>/messages/chat/:userId</code> and <code>/servers/voice</code>) target <code>_rootNavigatorKey</code>, allowing them to render cleanly above the bottom navigation bar without layout jumps.
        </p>
      </div>

      <div class="text-box">
        <div class="tb-title">3.0.2 Domain State Providers</div>
        <p class="tb-p">
          State is managed using the Provider package across 6 decoupled domain notifiers:
        </p>
        <p class="tb-p">• <strong>AuthProvider:</strong> Token persistence, user profile, login, and registration.</p>
        <p class="tb-p">• <strong>ServerProvider:</strong> Server memberships, channel listings, and member roles.</p>
        <p class="tb-p">• <strong>ChatProvider:</strong> Active channel message stream and emoji reaction state.</p>
        <p class="tb-p">• <strong>DmProvider:</strong> Direct message conversations and active squad members.</p>
        <p class="tb-p">• <strong>VoiceProvider:</strong> Voice channel participant states, mute, and speaking flags.</p>
      </div>
    </div>

    <div class="text-box">
      <div class="tb-title">3.0.3 Shell Route Hierarchy Specification</div>
      <table class="academic-table">
        <thead>
          <tr>
            <th style="width: 75px;">Branch</th>
            <th style="width: 120px;">Root Route</th>
            <th style="width: 180px;">Sub-Routes</th>
            <th>Assigned Screen Widgets</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>Branch 0</strong></td>
            <td class="code-cell">/servers</td>
            <td class="code-cell">/members, /voice</td>
            <td><code>MainChatScreen</code>, <code>MemberListScreen</code>, <code>VoiceChannelScreen</code></td>
          </tr>
          <tr>
            <td><strong>Branch 1</strong></td>
            <td class="code-cell">/messages</td>
            <td class="code-cell">/chat/:userId</td>
            <td><code>DmInboxScreen</code>, <code>DmChatScreen</code></td>
          </tr>
          <tr>
            <td><strong>Branch 2</strong></td>
            <td class="code-cell">/discover</td>
            <td class="code-cell">/create</td>
            <td><code>CommunityDiscoveryScreen</code>, <code>CreateCommunityScreen</code></td>
          </tr>
          <tr>
            <td><strong>Branch 3</strong></td>
            <td class="code-cell">/activity</td>
            <td class="code-cell">—</td>
            <td><code>NotificationsScreen</code></td>
          </tr>
          <tr>
            <td><strong>Branch 4</strong></td>
            <td class="code-cell">/profile</td>
            <td class="code-cell">/settings, /theme</td>
            <td><code>UserProfileScreen</code>, <code>SettingsScreen</code>, <code>CustomizeThemeScreen</code></td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="footer-rule">
      <span>The Crew • Capstone Project Submission & System Specification</span>
      <span>Page 5 of 22</span>
    </div>
  </div>

  <!-- PAGES 6 TO 20: 15 SCREEN SPECIFICATIONS -->
  ${screensHtml}

  <!-- PAGE 21: REST API & SOCKET SPECIFICATIONS -->
  <div class="page doc-page">
    <div class="header-rule">
      <span class="hr-title">THE CREW • PROJECT SPECIFICATION REPORT</span>
      <span class="hr-meta">CONTRIBUTORS: PRANAV KALE & R VIRSHIN</span>
    </div>

    <div class="page-title-block">
      <div class="page-section-num">SECTION 4.0</div>
      <h1 class="page-main-title">REST API & Real-Time Protocol Specification</h1>
    </div>

    <div class="text-box">
      <div class="tb-title">4.1 REST API Endpoint Reference</div>
      <table class="academic-table">
        <thead>
          <tr>
            <th style="width: 45px;">Method</th>
            <th style="width: 180px;">Endpoint</th>
            <th style="width: 85px;">Guard</th>
            <th>Description & Payload</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><span class="method-tag">POST</span></td>
            <td class="code-cell">/api/auth/register</td>
            <td>Public</td>
            <td>Registers new account (username, display_name, email, password). Returns JWT & user profile.</td>
          </tr>
          <tr>
            <td><span class="method-tag">POST</span></td>
            <td class="code-cell">/api/auth/login</td>
            <td>Public</td>
            <td>Authenticates user credentials. Issues signed Bearer JWT token.</td>
          </tr>
          <tr>
            <td><span class="method-tag">POST</span></td>
            <td class="code-cell">/api/auth/quick-login</td>
            <td>Public</td>
            <td>One-click developer login for demo personas (dev -> Kaelen, vip -> Nyx).</td>
          </tr>
          <tr>
            <td><span class="method-tag">GET</span></td>
            <td class="code-cell">/api/servers</td>
            <td>Bearer JWT</td>
            <td>Lists all servers joined by the authenticated user with member counts and user roles.</td>
          </tr>
          <tr>
            <td><span class="method-tag">GET</span></td>
            <td class="code-cell">/api/servers/discover</td>
            <td>Public</td>
            <td>Queries public servers with optional category and search filter query parameters.</td>
          </tr>
          <tr>
            <td><span class="method-tag">POST</span></td>
            <td class="code-cell">/api/servers</td>
            <td>Bearer JWT</td>
            <td>Creates a new server, assigns creator as OWNER, and provisions 4 default channels.</td>
          </tr>
          <tr>
            <td><span class="method-tag">GET</span></td>
            <td class="code-cell">/api/channels/:id/messages</td>
            <td>Bearer JWT</td>
            <td>Returns ordered channel message history with sender metadata and reaction aggregates.</td>
          </tr>
          <tr>
            <td><span class="method-tag">POST</span></td>
            <td class="code-cell">/api/channels/:id/messages</td>
            <td>Bearer JWT</td>
            <td>Posts text/media message. Immediately broadcasts <code>message:new</code> to channel room.</td>
          </tr>
          <tr>
            <td><span class="method-tag">POST</span></td>
            <td class="code-cell">/api/channels/messages/:id/reactions</td>
            <td>Bearer JWT</td>
            <td>Toggles emoji reaction for the user on message. Broadcasts <code>reaction:updated</code>.</td>
          </tr>
          <tr>
            <td><span class="method-tag">GET</span></td>
            <td class="code-cell">/api/dms</td>
            <td>Bearer JWT</td>
            <td>Fetches online squad users and direct conversation threads with unread counters.</td>
          </tr>
          <tr>
            <td><span class="method-tag">GET</span></td>
            <td class="code-cell">/api/dms/:userId</td>
            <td>Bearer JWT</td>
            <td>Retrieves private 1-on-1 direct messages and marks unread messages as read.</td>
          </tr>
          <tr>
            <td><span class="method-tag">POST</span></td>
            <td class="code-cell">/api/dms/:userId</td>
            <td>Bearer JWT</td>
            <td>Sends direct message and delivers <code>dm:new</code> event to recipient and sender rooms.</td>
          </tr>
          <tr>
            <td><span class="method-tag">GET</span></td>
            <td class="code-cell">/api/voice/:channelId</td>
            <td>Bearer JWT</td>
            <td>Retrieves active participants in a voice channel with speaking and mute flags.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="text-box">
      <div class="tb-title">4.2 WebSocket Event Dictionary (Socket.IO)</div>
      <table class="academic-table">
        <thead>
          <tr>
            <th style="width: 140px;">Event Name</th>
            <th style="width: 80px;">Direction</th>
            <th style="width: 130px;">Room Target</th>
            <th>Payload & Functional Behavior</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td class="code-cell">channel:join</td>
            <td>Client -> Server</td>
            <td class="code-cell">channel_&lt;id&gt;</td>
            <td>Subscribes client socket to live message and reaction updates in a text channel.</td>
          </tr>
          <tr>
            <td class="code-cell">message:new</td>
            <td>Server -> Client</td>
            <td class="code-cell">channel_&lt;id&gt;</td>
            <td>Pushes newly authored message object directly into active chat list.</td>
          </tr>
          <tr>
            <td class="code-cell">reaction:updated</td>
            <td>Server -> Client</td>
            <td class="code-cell">channel_&lt;id&gt;</td>
            <td>Pushes updated emoji counts and reacting user IDs for reactive UI badge re-render.</td>
          </tr>
          <tr>
            <td class="code-cell">dm:new</td>
            <td>Server -> Client</td>
            <td class="code-cell">user_&lt;partnerId&gt;</td>
            <td>Dispatches direct message payload instantly to recipient's private user room.</td>
          </tr>
          <tr>
            <td class="code-cell">voice:speaking_updated</td>
            <td>Server -> Client</td>
            <td class="code-cell">voice_&lt;channelId&gt;</td>
            <td>Broadcasts participant is_speaking boolean state for dynamic microphone indicator.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="footer-rule">
      <span>The Crew • Capstone Project Submission & System Specification</span>
      <span>Page 21 of 22</span>
    </div>
  </div>

  <!-- PAGE 22: DATABASE SCHEMA & VERIFICATION SIGN-OFF -->
  <div class="page doc-page">
    <div class="header-rule">
      <span class="hr-title">THE CREW • PROJECT SPECIFICATION REPORT</span>
      <span class="hr-meta">CONTRIBUTORS: PRANAV KALE & R VIRSHIN</span>
    </div>

    <div class="page-title-block">
      <div class="page-section-num">SECTION 5.0</div>
      <h1 class="page-main-title">Database Schema & Verification Sign-Off</h1>
    </div>

    <div class="text-box">
      <div class="tb-title">5.1 SQLite Relational Schema (WAL Mode Enabled)</div>
      <table class="academic-table">
        <thead>
          <tr>
            <th style="width: 100px;">Table</th>
            <th style="width: 110px;">Primary Key</th>
            <th style="width: 130px;">Foreign Keys</th>
            <th>Core Columns & Constraints</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td class="code-cell">users</td>
            <td class="code-cell">id TEXT</td>
            <td>—</td>
            <td>username (UNIQUE), display_name, email (UNIQUE), password_hash, avatar_url, bio, status, custom_status.</td>
          </tr>
          <tr>
            <td class="code-cell">servers</td>
            <td class="code-cell">id TEXT</td>
            <td class="code-cell">owner_id -> users</td>
            <td>name, description, icon_color, category, is_public, level, created_at.</td>
          </tr>
          <tr>
            <td class="code-cell">server_members</td>
            <td class="code-cell">id TEXT</td>
            <td class="code-cell">server_id, user_id</td>
            <td>role (OWNER, ADMIN, VIP, MEMBER), activity, joined_at. UNIQUE(server_id, user_id).</td>
          </tr>
          <tr>
            <td class="code-cell">channels</td>
            <td class="code-cell">id TEXT</td>
            <td class="code-cell">server_id -> servers</td>
            <td>name, type ('text' | 'voice'), topic, position, created_at.</td>
          </tr>
          <tr>
            <td class="code-cell">messages</td>
            <td class="code-cell">id TEXT</td>
            <td class="code-cell">channel_id, sender_id</td>
            <td>content, has_media, media_url, media_title, media_duration, created_at.</td>
          </tr>
          <tr>
            <td class="code-cell">reactions</td>
            <td class="code-cell">id TEXT</td>
            <td class="code-cell">message_id, user_id</td>
            <td>emoji, created_at. UNIQUE(message_id, user_id, emoji).</td>
          </tr>
          <tr>
            <td class="code-cell">direct_messages</td>
            <td class="code-cell">id TEXT</td>
            <td class="code-cell">sender_id, receiver_id</td>
            <td>content, is_read, created_at.</td>
          </tr>
          <tr>
            <td class="code-cell">notifications</td>
            <td class="code-cell">id TEXT</td>
            <td class="code-cell">user_id -> users</td>
            <td>actor_id, type ('mention' | 'reaction' | 'friend' | 'system'), title, body, time_display, is_read.</td>
          </tr>
          <tr>
            <td class="code-cell">voice_participants</td>
            <td class="code-cell">(channel_id, user_id)</td>
            <td class="code-cell">channel_id, user_id</td>
            <td>is_speaking, is_muted, is_streaming, status_text, joined_at.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="grid-2">
      <div class="text-box">
        <div class="tb-title">5.2 Security & Integrity Audit</div>
        <p class="tb-p">• <strong>Password Security:</strong> Hashed using bcrypt with 10 salt rounds.</p>
        <p class="tb-p">• <strong>Token Security:</strong> HMAC-SHA256 signed JSON Web Tokens (JWT).</p>
        <p class="tb-p">• <strong>Foreign Keys:</strong> Enforced via <code>PRAGMA foreign_keys = ON</code> with cascading deletes.</p>
        <p class="tb-p">• <strong>Configuration:</strong> Environment variables secured and excluded via <code>.gitignore</code>.</p>
      </div>

      <div class="text-box">
        <div class="tb-title">5.3 Quality Assurance & Verification</div>
        <p class="tb-p">• <strong>Dart Analysis:</strong> <code>flutter analyze</code> passed with 0 issues / 0 warnings.</p>
        <p class="tb-p">• <strong>Integration Suite:</strong> Automated test suite validated all 18 endpoints.</p>
        <p class="tb-p">• <strong>Viewport Ergonomics:</strong> Certified for standard 390×844 mobile viewport.</p>
        <p class="tb-p">• <strong>Latency Baseline:</strong> Local WebSocket dispatch latency &lt; 18ms.</p>
      </div>
    </div>

    <!-- ACADEMIC SIGN-OFF CARD -->
    <div class="text-box" style="background: #FAFAFA; border: 1.5px solid #111827; margin-top: 4px;">
      <div class="tb-title" style="border-bottom: none; margin-bottom: 2px;">5.4 PROJECT EVALUATION SIGN-OFF</div>
      <div style="display: flex; justify-content: space-between; align-items: flex-end; padding-top: 4px;">
        <div style="font-size: 8.5pt; color: #4B5563; max-width: 420px; line-height: 1.35;">
          This technical documentation confirms the complete development, architectural compliance, and functional verification of <strong>The Crew</strong>. Submitted for academic capstone project evaluation.
        </div>
        <div style="text-align: right;">
          <div style="font-weight: 800; font-size: 9.5pt; color: #000000;">PRANAV KALE & R VIRSHIN</div>
          <div style="font-size: 8pt; color: #6B7280; text-transform: uppercase;">PROJECT DEVELOPERS & AUTHORS</div>
        </div>
      </div>
    </div>

    <div class="footer-rule">
      <span>The Crew • Capstone Project Submission & System Specification</span>
      <span>Page 22 of 22</span>
    </div>
  </div>

</body>
</html>
  `;
}

async function buildPdf() {
  console.log('Generating clean Black & White Academic Project Submission PDF...');
  const html = generateHtml();
  const htmlPath = path.resolve(__dirname, 'spec_document.html');
  fs.writeFileSync(htmlPath, html);
  console.log(`Saved clean HTML at: ${htmlPath}`);

  console.log('Launching headless Chrome via Puppeteer...');
  const browser = await puppeteer.launch({
    executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    headless: true,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--font-render-hinting=none'
    ]
  });

  const page = await browser.newPage();
  console.log('Loading document HTML...');
  await page.goto(`file://${htmlPath}`, { waitUntil: 'networkidle0' });

  console.log('Rendering clean Black & White A4 PDF...');
  await page.pdf({
    path: outputPdfPath,
    format: 'A4',
    printBackground: true,
    margin: {
      top: '12mm',
      bottom: '12mm',
      left: '14mm',
      right: '14mm'
    }
  });

  await browser.close();
  const stats = fs.statSync(outputPdfPath);
  console.log(`🎉 SUCCESS! Clean B&W PDF generated at: ${outputPdfPath}`);
  console.log(`📊 PDF File Size: ${(stats.size / 1024 / 1024).toFixed(2)} MB`);
}

buildPdf().catch(err => {
  console.error('Error generating PDF:', err);
  process.exit(1);
});
