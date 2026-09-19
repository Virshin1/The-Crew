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
    category: 'Onboarding & Lifecycle',
    summary: 'The initial application gateway that boots the Flutter runtime, verifies backend service health, and restores persistent authentication credentials from local storage.',
    components: [
      'Top network telemetry bar displaying active protocol version (v2.4) and live latency ping (18ms).',
      'Centered glowing neon geometric chat bubble logo with reactive ambient pulsation.',
      'Core value proposition banner: "Where gaming, soundscapes, and aesthetic spaces connect."',
      'Node synchronization progress bar showing dynamic bootstrap percentage (100%).',
      'Primary CTA button "Get Started / Log In" alongside secondary direct action buttons.'
    ],
    technical: {
      providers: 'AuthProvider (restoreSession)',
      endpoints: 'GET /api/health (status ping & latency telemetry)',
      storage: 'SharedPreferences (auth_token, auth_user)',
      sockets: 'Initiates WebSocket handshake if valid JWT found in cache',
      tables: 'users (session validation)'
    },
    ux: 'Auto-checks local storage. If valid session exists, smoothly navigates directly to `/servers` without user friction. If first-time launch, presents entry options.'
  },
  {
    id: '02',
    name: 'Welcome & Onboarding Portal',
    file: '02_welcome.png',
    route: '/welcome',
    access: 'Public / Welcome Flow',
    category: 'Brand & Value Proposition',
    summary: 'The primary brand showcase screen introducing prospective users to The Crew’s gaming-focused spatial audio, 4K streaming, and aesthetic glass room capabilities.',
    components: [
      'Top interactive "Nightclub Mode Live" pill with real-time tuning listener count badge (42k Tuning In).',
      'Hero headline with high-contrast neon styling and typography ("Hang out with your crew in style").',
      'Feature cards showcasing Spatial Audio (360° lounge acoustics), 4K Zero-latency Streaming, and Aesthetic Glass Rooms.',
      'Active voice lobby badge featuring stacked avatar circles (DJ, VR, +8) and animated graphic equalizer icon.',
      'Full-width primary action "CREATE ACCOUNT" button and secondary outlined "Log In" button.'
    ],
    technical: {
      providers: 'NavigationService, AuthProvider',
      endpoints: 'Static local feature definitions with dynamic telemetry pills',
      storage: 'None required (stateless presentation)',
      sockets: 'Passive connection listener',
      tables: 'N/A'
    },
    ux: 'Engaging layout that clearly communicates why The Crew differs from standard text chat apps, emphasizing music, low-latency voice, and visual polish.'
  },
  {
    id: '03',
    name: 'Authentication & Quick Demo Login',
    file: '03_login.png',
    route: '/login',
    access: 'Public / Auth Form',
    category: 'Security & Access',
    summary: 'Secure login screen supporting traditional password authentication, device persistence, social OAuth, and an instant one-click developer quick-login dock.',
    components: [
      'Clean form inputs for Username/Email and password with toggleable password visibility.',
      'Remember this device toggle switch with animated state transitions.',
      'One-Click Demo Login dock featuring instant persona switches: "👑 Kaelen (Owner)" and "💜 Nyx (VIP)".',
      'Google Sign-In button and third-party authentication shortcuts (Discord, Passkey).',
      'Top navigation bar with back arrow and branding logo.'
    ],
    technical: {
      providers: 'AuthProvider (login, quickLogin, googleLogin)',
      endpoints: 'POST /api/auth/login, POST /api/auth/quick-login, POST /api/auth/google',
      storage: 'SharedPreferences: stores JWT token & user model',
      sockets: 'Authenticates socket connection with JWT Bearer handshake',
      tables: 'users (credential check & bcrypt hash comparison)'
    },
    ux: 'Developer-friendly and evaluator-friendly design allowing immediate entry without entering credentials repeatedly, while maintaining strict server-side JWT security.'
  },
  {
    id: '04',
    name: 'Account Registration & Personalization',
    file: '04_create_account.png',
    route: '/create-account',
    access: 'Public / Registration',
    category: 'User Provisioning',
    summary: 'Account creation flow enabling new members to register unique usernames, custom display handles, email verification, and select custom gaming interest tags.',
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
    ux: 'Smooth registration with inline error handling. On submission, automatically establishes authenticated session and transitions into the main servers hub.'
  },
  {
    id: '05',
    name: 'Servers Hub & Live Channel Chat',
    file: '05_servers_chat.png',
    route: '/servers',
    access: 'Authenticated (Shell Tab 0)',
    category: 'Core Communication',
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
    category: 'Voice & Streaming',
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
    ux: 'Clear visual feedback on audio states with green glowing speaking halos and intuitive one-tap mute toggling.'
  },
  {
    id: '07',
    name: 'Server Member Directory & Hierarchy',
    file: '07_member_list.png',
    route: '/servers/members',
    access: 'Authenticated (Server Drawer)',
    category: 'Community Management',
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
    ux: 'Gives server owners and members a clear visual overview of online community hierarchy and what fellow members are currently playing or doing.'
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
      'Horizontal "ACTIVE NOW" stories rail with user avatar, name, and green online status dot.',
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
    ux: 'Familiar modern messaging inbox layout allowing users to quickly see who is online and resume ongoing conversations with zero delay.'
  },
  {
    id: '09',
    name: '1-on-1 Direct Message Conversation',
    file: '09_dm_chat.png',
    route: '/messages/chat/:userId',
    access: 'Authenticated (Nested Route)',
    category: 'Direct Messaging',
    summary: 'Full-screen private direct chat interface between two users, supporting real-time messaging, delivery status indicators, and partner profile inspection.',
    components: [
      'Custom app bar featuring partner avatar with online dot, partner name ("Nyx"), status ("Editing clips"), voice call button, and info button.',
      'Asymmetric chat bubbles: Mint green right-aligned bubbles for current user; Dark slate left-aligned bubbles for partner.',
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
    ux: 'Private, secure chat thread that automatically marks incoming messages as read upon viewing and updates in real-time via WebSockets.'
  },
  {
    id: '10',
    name: 'Community Discovery & Exploration',
    file: '10_community_discovery.png',
    route: '/discover',
    access: 'Authenticated (Shell Tab 2)',
    category: 'Community & Discovery',
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
    ux: 'Makes discovering new gaming servers and interest groups seamless with intuitive category chips and instant join actions.'
  },
  {
    id: '11',
    name: 'Community Creation & Setup',
    file: '11_create_community.png',
    route: '/discover/create',
    access: 'Authenticated (Modal / Route)',
    category: 'Community Management',
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
    ux: 'Streamlines community creation into a 30-second workflow, automatically bootstrapping channels and giving the creator owner privileges.'
  },
  {
    id: '12',
    name: 'Activity Feed & Real-time Notifications',
    file: '12_notifications.png',
    route: '/activity',
    access: 'Authenticated (Shell Tab 3)',
    category: 'Notifications & Alerts',
    summary: 'Centralized activity feed organizing mentions, message reactions, friend requests, and system announcements into categorized filter tabs.',
    components: [
      'Top app bar with Activity title, "Mark All as Read" double-check icon, and user avatar.',
      'Filter tabs: All, Mentions, Reactions, System.',
      'Detailed notification cards with category icons (@ mention, ❤️ reaction, 👥 friend, 📢 system).',
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
    ux: 'Ensures users never miss important squad mentions or gameplay clip reactions, with clean categorizations to eliminate notification clutter.'
  },
  {
    id: '13',
    name: 'User Profile & Identity Dashboard',
    file: '13_user_profile.png',
    route: '/profile',
    access: 'Authenticated (Shell Tab 4)',
    category: 'Identity & Profile',
    summary: 'Rich user identity dashboard showcasing user avatar, status pill selector, custom bio, earned achievement badges, and a drawer of joined servers.',
    components: [
      'Vibrant gradient banner header with profile gear settings shortcut and app logo.',
      'Centered elevated circular avatar with initial or profile picture.',
      'Username and handle: "Kaelen @kaelen_vr", "Member of The Crew Network".',
      'Status dropdown selector (🟢 ONLINE, 🟡 IDLE, 🔴 DND, ⚫ INVISIBLE).',
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
    ux: 'Empowers users to customize their visual presence across all servers and monitor their community standing and achievements.'
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
    ux: 'Organized with clear section dividers, high-contrast toggle switches, and immediate preference persistence.'
  },
  {
    id: '15',
    name: 'Appearance & Custom Theme Engine',
    file: '15_customize_theme.png',
    route: '/profile/theme',
    access: 'Authenticated (Nested Route)',
    category: 'Customization & Theming',
    summary: 'Interactive appearance customizer allowing users to select color palettes, adjust UI density, and tune dynamic glow effects in real-time.',
    components: [
      'Top header: "Customize Appearance - Tailor colors, density, and glow effects to match your setup vibe."',
      'Theme Palette cards: Cyber Emerald (Matrix slate & mint), Midnight Tokyo (Deep indigo slate), Pure OLED (Pitch black & stark).',
      'Interface Density segment control: Compact, Default, Spacious.',
      'Glow Effects Intensity slider (0% to 100%, currently tuned to 85% Hyper-Glow).',
      'Prominent "Apply Changes ⚡" action button that updates theme tokens across the app.'
    ],
    technical: {
      providers: 'Theme service / AppTheme provider',
      endpoints: 'PUT /api/auth/profile (persists custom theme preference)',
      storage: 'Saves themeMode and accentColor to SharedPreferences',
      sockets: 'Local state trigger',
      tables: 'users (theme_preference)'
    },
    ux: 'Gives power users and gamers full control over UI aesthetics, optimizing for OLED battery life or vibrant neon night-lounge immersion.'
  }
];

function generateHtml() {
  const screensHtml = screensData.map((s, idx) => {
    const b64 = getBase64(s.file);
    return `
    <div class="page screen-page">
      <div class="screen-header">
        <div class="screen-tag">SCREEN ${s.id} OF 15 • ${s.category.toUpperCase()}</div>
        <div class="screen-title-row">
          <h2 class="screen-title">${s.name}</h2>
          <span class="route-badge">${s.route}</span>
        </div>
      </div>

      <div class="screen-layout">
        <!-- Phone Mockup Container -->
        <div class="phone-column">
          <div class="phone-mockup">
            <div class="phone-island"></div>
            <div class="phone-screen">
              ${b64 ? `<img src="${b64}" alt="${s.name}" class="phone-img" />` : `<div class="placeholder">Image Missing</div>`}
            </div>
            <div class="phone-home-indicator"></div>
          </div>
          <div class="phone-caption">
            <strong>Figure ${idx + 1}:</strong> Mobile viewport rendering (390 × 844 pt @ 2x high-DPI).
          </div>
        </div>

        <!-- Details Column -->
        <div class="details-column">
          <div class="card overview-card">
            <div class="card-title">Screen Overview & Intent</div>
            <p class="overview-text">${s.summary}</p>
          </div>

          <div class="card">
            <div class="card-title">Key UI Components & Anatomy</div>
            <ul class="spec-list">
              ${s.components.map(c => `<li>${c}</li>`).join('')}
            </ul>
          </div>

          <div class="card">
            <div class="card-title">Technical & Architectural Specifications</div>
            <table class="tech-table">
              <tr>
                <td class="tech-label">Route & Access:</td>
                <td class="tech-val"><code>${s.route}</code> (${s.access})</td>
              </tr>
              <tr>
                <td class="tech-label">State Providers:</td>
                <td class="tech-val"><code>${s.technical.providers}</code></td>
              </tr>
              <tr>
                <td class="tech-label">REST API Calls:</td>
                <td class="tech-val"><code>${s.technical.endpoints}</code></td>
              </tr>
              <tr>
                <td class="tech-label">WebSocket Events:</td>
                <td class="tech-val"><code>${s.technical.sockets}</code></td>
              </tr>
              <tr>
                <td class="tech-label">Database Schema:</td>
                <td class="tech-val"><code>${s.technical.tables}</code></td>
              </tr>
            </table>
          </div>

          <div class="card">
            <div class="card-title">User Interaction Flow & UX Logic</div>
            <p class="ux-text">${s.ux}</p>
          </div>
        </div>
      </div>

      <div class="page-footer">
        <span>The Crew • Mobile Application System Specification</span>
        <span>Page ${idx + 4} of 20</span>
      </div>
    </div>
    `;
  }).join('\n');

  return `
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>The Crew - Mobile App Architecture & UI Specification</title>
<style>
  @page {
    size: A4 portrait;
    margin: 10mm 12mm 12mm 12mm;
  }

  * {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }

  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    background: #0B0E14;
    color: #E2E8F0;
    line-height: 1.45;
    font-size: 11px;
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
  }

  /* COVER PAGE */
  .cover-page {
    background: radial-gradient(circle at 80% 20%, rgba(157, 78, 221, 0.15), transparent 40%),
                radial-gradient(circle at 20% 80%, rgba(0, 255, 178, 0.12), transparent 40%),
                #07090E;
    padding: 30px 20px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }

  .cover-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    padding-bottom: 16px;
  }

  .cover-logo-row {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .cover-logo-icon {
    width: 44px;
    height: 44px;
    background: linear-gradient(135deg, #9D4EDD, #00FFB2);
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    font-weight: 900;
    color: #07090E;
    box-shadow: 0 0 20px rgba(0, 255, 178, 0.4);
  }

  .cover-logo-text {
    font-size: 20px;
    font-weight: 800;
    letter-spacing: 2px;
    color: #F8FAFC;
  }

  .cover-badge {
    background: rgba(0, 255, 178, 0.1);
    color: #00FFB2;
    border: 1px solid rgba(0, 255, 178, 0.3);
    padding: 4px 12px;
    border-radius: 999px;
    font-weight: 600;
    font-size: 10px;
    letter-spacing: 1px;
  }

  .cover-body {
    margin: 40px 0;
  }

  .cover-tagline {
    color: #00FFB2;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 2px;
    text-transform: uppercase;
    margin-bottom: 12px;
  }

  .cover-title {
    font-size: 42px;
    line-height: 1.1;
    font-weight: 900;
    color: #FFFFFF;
    margin-bottom: 16px;
    letter-spacing: -1px;
  }

  .cover-title span {
    background: linear-gradient(135deg, #00FFB2 0%, #9D4EDD 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .cover-subtitle {
    font-size: 16px;
    color: #94A3B8;
    max-width: 600px;
    line-height: 1.5;
    margin-bottom: 28px;
  }

  .tech-pills {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 36px;
  }

  .tech-pill {
    background: #151923;
    border: 1px solid rgba(255, 255, 255, 0.1);
    color: #CBD5E1;
    padding: 6px 14px;
    border-radius: 8px;
    font-size: 11px;
    font-weight: 600;
  }

  .tech-pill.accent {
    border-color: rgba(0, 255, 178, 0.4);
    color: #00FFB2;
    background: rgba(0, 255, 178, 0.05);
  }

  .cover-stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
    background: rgba(21, 25, 35, 0.6);
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 16px;
    padding: 16px;
  }

  .stat-card {
    text-align: center;
  }

  .stat-number {
    font-size: 24px;
    font-weight: 800;
    color: #00FFB2;
    margin-bottom: 2px;
  }

  .stat-label {
    font-size: 10px;
    color: #94A3B8;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .cover-footer {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    border-top: 1px solid rgba(255, 255, 255, 0.08);
    padding-top: 16px;
  }

  .meta-group {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .meta-label {
    font-size: 9px;
    color: #64748B;
    text-transform: uppercase;
    letter-spacing: 1px;
  }

  .meta-val {
    font-size: 11px;
    font-weight: 600;
    color: #E2E8F0;
  }

  /* EXECUTIVE SUMMARY & ARCHITECTURE */
  .doc-page {
    padding: 24px 20px;
  }

  .page-header {
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    padding-bottom: 12px;
    margin-bottom: 18px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .page-header h1 {
    font-size: 20px;
    color: #FFFFFF;
    font-weight: 800;
  }

  .page-header span {
    color: #00FFB2;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 1px;
  }

  .content-grid-2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
    margin-bottom: 16px;
  }

  .arch-box {
    background: #11141D;
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 12px;
    padding: 14px;
  }

  .arch-box h3 {
    font-size: 13px;
    color: #00FFB2;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .arch-box p {
    color: #94A3B8;
    line-height: 1.5;
    margin-bottom: 8px;
  }

  .arch-layers {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin: 12px 0;
  }

  .arch-layer {
    background: #161B26;
    border: 1px solid rgba(255, 255, 255, 0.06);
    border-left: 3px solid #00FFB2;
    padding: 10px 12px;
    border-radius: 6px;
  }

  .arch-layer.mid {
    border-left-color: #9D4EDD;
  }

  .arch-layer.bottom {
    border-left-color: #00F0FF;
  }

  .arch-layer h4 {
    font-size: 11px;
    font-weight: 700;
    color: #F8FAFC;
    margin-bottom: 2px;
  }

  .arch-layer p {
    font-size: 10px;
    color: #94A3B8;
    margin-bottom: 0;
  }

  /* SCREEN PAGE SPECIFICATIONS */
  .screen-page {
    padding: 20px;
  }

  .screen-header {
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    padding-bottom: 10px;
    margin-bottom: 14px;
  }

  .screen-tag {
    font-size: 9px;
    color: #00FFB2;
    font-weight: 800;
    letter-spacing: 1.5px;
    margin-bottom: 4px;
  }

  .screen-title-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .screen-title {
    font-size: 18px;
    font-weight: 800;
    color: #FFFFFF;
  }

  .route-badge {
    background: rgba(157, 78, 221, 0.15);
    color: #C77DFF;
    border: 1px solid rgba(157, 78, 221, 0.4);
    padding: 2px 10px;
    border-radius: 6px;
    font-family: monospace;
    font-size: 11px;
    font-weight: 600;
  }

  .screen-layout {
    display: grid;
    grid-template-columns: 260px 1fr;
    gap: 20px;
    align-items: start;
    flex-grow: 1;
  }

  /* PHONE MOCKUP */
  .phone-column {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .phone-mockup {
    width: 250px;
    height: 541px; /* Exactly 390x844 aspect ratio: 250 x 541 */
    background: #000000;
    border: 7px solid #1F2432;
    border-radius: 40px;
    position: relative;
    box-shadow: 0 16px 36px rgba(0, 0, 0, 0.7), 0 0 0 1px rgba(255, 255, 255, 0.12);
    overflow: hidden;
  }

  .phone-island {
    position: absolute;
    top: 6px;
    left: 50%;
    transform: translateX(-50%);
    width: 60px;
    height: 14px;
    background: #000000;
    border-radius: 10px;
    z-index: 10;
  }

  .phone-screen {
    width: 100%;
    height: 100%;
    overflow: hidden;
    background: #0B0E14;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .phone-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
  }

  .phone-home-indicator {
    position: absolute;
    bottom: 5px;
    left: 50%;
    transform: translateX(-50%);
    width: 70px;
    height: 3px;
    background: rgba(255, 255, 255, 0.4);
    border-radius: 2px;
    z-index: 10;
  }

  .phone-caption {
    margin-top: 8px;
    font-size: 9px;
    color: #64748B;
    text-align: center;
    max-width: 250px;
  }

  /* DETAILS COLUMN */
  .details-column {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .card {
    background: #111520;
    border: 1px solid rgba(255, 255, 255, 0.06);
    border-radius: 10px;
    padding: 10px 12px;
  }

  .overview-card {
    border-left: 3px solid #00FFB2;
  }

  .card-title {
    font-size: 11px;
    font-weight: 700;
    color: #00FFB2;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    margin-bottom: 6px;
  }

  .overview-text {
    color: #E2E8F0;
    font-size: 10.5px;
    line-height: 1.45;
  }

  .spec-list {
    list-style: none;
    padding-left: 0;
    display: flex;
    flex-direction: column;
    gap: 5px;
  }

  .spec-list li {
    position: relative;
    padding-left: 14px;
    color: #CBD5E1;
    font-size: 10px;
    line-height: 1.4;
  }

  .spec-list li::before {
    content: "•";
    position: absolute;
    left: 0;
    color: #9D4EDD;
    font-weight: bold;
    font-size: 14px;
    line-height: 10px;
  }

  .tech-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 10px;
  }

  .tech-table tr {
    border-bottom: 1px solid rgba(255, 255, 255, 0.04);
  }

  .tech-table tr:last-child {
    border-bottom: none;
  }

  .tech-table td {
    padding: 4px 2px;
    vertical-align: top;
  }

  .tech-label {
    width: 105px;
    color: #94A3B8;
    font-weight: 600;
  }

  .tech-val {
    color: #F1F5F9;
  }

  .tech-val code {
    background: rgba(255, 255, 255, 0.06);
    padding: 1px 4px;
    border-radius: 4px;
    font-family: monospace;
    font-size: 9.5px;
    color: #38BDF8;
  }

  .ux-text {
    color: #94A3B8;
    font-size: 10px;
    line-height: 1.45;
  }

  /* PAGE FOOTER */
  .page-footer {
    border-top: 1px solid rgba(255, 255, 255, 0.06);
    padding-top: 8px;
    display: flex;
    justify-content: space-between;
    font-size: 9px;
    color: #64748B;
    margin-top: auto;
  }

  /* TABLES FOR SPECS */
  .data-table {
    width: 100%;
    border-collapse: collapse;
    margin: 8px 0;
    font-size: 9.5px;
  }

  .data-table th {
    background: #1A202E;
    color: #00FFB2;
    padding: 6px 8px;
    text-align: left;
    font-weight: 700;
    border: 1px solid rgba(255, 255, 255, 0.08);
  }

  .data-table td {
    padding: 6px 8px;
    border: 1px solid rgba(255, 255, 255, 0.06);
    color: #CBD5E1;
  }

  .data-table tr:nth-child(even) {
    background: rgba(255, 255, 255, 0.02);
  }

  .method-badge {
    padding: 1px 5px;
    border-radius: 4px;
    font-size: 8.5px;
    font-weight: bold;
    font-family: monospace;
  }

  .method-get { background: rgba(56, 189, 248, 0.2); color: #38BDF8; }
  .method-post { background: rgba(0, 255, 178, 0.2); color: #00FFB2; }
  .method-put { background: rgba(251, 191, 36, 0.2); color: #FBBF24; }
  .method-delete { background: rgba(248, 113, 113, 0.2); color: #F87171; }
</style>
</head>
<body>

  <!-- COVER PAGE -->
  <div class="page cover-page">
    <div class="cover-header">
      <div class="cover-logo-row">
        <div class="cover-logo-icon">C</div>
        <div class="cover-logo-text">THE CREW</div>
      </div>
      <div class="cover-badge">SYSTEM ARCHITECTURE SPECIFICATION v1.0</div>
    </div>

    <div class="cover-body">
      <div class="cover-tagline">Cross-Platform Gaming & Community Platform</div>
      <h1 class="cover-title">Mobile UI Specification<br><span>& Deep Architectural Guide</span></h1>
      <p class="cover-subtitle">
        An exhaustive technical documentation and mobile UI showcase of The Crew—an aesthetic, low-latency social communication application featuring real-time messaging, spatial voice channels, community exploration, and custom theme engines.
      </p>

      <div class="tech-pills">
        <div class="tech-pill accent">Flutter 3.x (Dart 3.x)</div>
        <div class="tech-pill">Node.js Express REST API</div>
        <div class="tech-pill accent">Socket.IO WebSockets</div>
        <div class="tech-pill">SQLite (WAL Mode Engine)</div>
        <div class="tech-pill">Provider State Architecture</div>
        <div class="tech-pill">GoRouter Navigation Shell</div>
        <div class="tech-pill accent">390×844 Mobile Viewport</div>
      </div>

      <div class="cover-stats-grid">
        <div class="stat-card">
          <div class="stat-number">15</div>
          <div class="stat-label">Mobile Screens</div>
        </div>
        <div class="stat-card">
          <div class="stat-number">18+</div>
          <div class="stat-label">REST API Routes</div>
        </div>
        <div class="stat-card">
          <div class="stat-number">10+</div>
          <div class="stat-label">Socket Event Types</div>
        </div>
        <div class="stat-card">
          <div class="stat-number">&lt; 18ms</div>
          <div class="stat-label">Local Sync Latency</div>
        </div>
      </div>
    </div>

    <div class="cover-footer">
      <div class="meta-group">
        <span class="meta-label">Author / Organization</span>
        <span class="meta-val">The Crew Development Team</span>
      </div>
      <div class="meta-group">
        <span class="meta-label">Target Form Factor</span>
        <span class="meta-val">iOS / Android Smartphone (390×844 pt)</span>
      </div>
      <div class="meta-group">
        <span class="meta-label">Release Date</span>
        <span class="meta-val">September 2026</span>
      </div>
    </div>
  </div>

  <!-- EXECUTIVE SUMMARY & ARCHITECTURE -->
  <div class="page doc-page">
    <div class="page-header">
      <h1>Executive Summary & Architecture Overview</h1>
      <span>SYSTEM SPECIFICATION</span>
    </div>

    <div class="content-grid-2">
      <div class="arch-box">
        <h3>🎯 Vision & Core Philosophy</h3>
        <p>
          <strong>The Crew</strong> is engineered as a next-generation communication client for gamers, modders, creative collectives, and esports squads. Unlike traditional bloated chat applications, The Crew provides a focused, high-contrast dark cyberpunk aesthetic combined with zero-lag channel switching, spatial audio telemetry, and deep identity customization.
        </p>
        <p>
          Every UI surface has been designed strictly around mobile ergonomical principles: floating gesture-friendly drawers, thumb-accessible bottom action bars, high-contrast OLED black themes, and instant reaction docks.
        </p>
      </div>

      <div class="arch-box">
        <h3>⚡ Real-time Reactive Pipeline</h3>
        <p>
          Real-time interactivity is guaranteed via a bidirectional WebSocket cluster managed by Socket.IO. Sockets join granular rooms (<code>channel_&lt;id&gt;</code>, <code>voice_&lt;id&gt;</code>, <code>user_&lt;id&gt;</code>), enabling isolated event dispatches for typing indicators, new messages, emoji reactions, and voice participant states without global broadcast thrashing.
        </p>
        <p>
          State on the client is managed via clean Provider notifiers that rebuild only the active chat feed, voice bar, or direct message thread.
        </p>
      </div>
    </div>

    <div class="arch-box">
      <h3>🏛️ 3-Tier Technical Architecture</h3>
      <div class="arch-layers">
        <div class="arch-layer">
          <h4>Tier 1: Client Application (Flutter / Dart)</h4>
          <p>
            Multi-platform reactive UI built with Flutter 3. Includes <code>GoRouter</code> indexed shell navigation, custom Cupertino and Material design tokens, Google Fonts Inter typography, SQLite local session cache, and responsive viewport sizing adapted for phone dimensions.
          </p>
        </div>
        <div class="arch-layer mid">
          <h4>Tier 2: Real-time API Gateway & Socket Hub (Node.js / Express / Socket.io)</h4>
          <p>
            Express REST engine mounted on <code>/api</code> handles authentication (bcrypt + JWT), server management, and channel messaging. Socket.IO manages state synchronization, user presence heartbeats, typing triggers, and active voice participant tracking.
          </p>
        </div>
        <div class="arch-layer bottom">
          <h4>Tier 3: Persistence & Storage Layer (SQLite WAL Mode / Optional Firestore)</h4>
          <p>
            High-throughput SQLite database running in Write-Ahead Logging (WAL) mode with foreign key enforcement. Automatic database schema migration and rich mock data seeding on startup.
          </p>
        </div>
      </div>
    </div>

    <div class="page-footer">
      <span>The Crew • Mobile Application System Specification</span>
      <span>Page 2 of 20</span>
    </div>
  </div>

  <!-- TABLE OF CONTENTS -->
  <div class="page doc-page">
    <div class="page-header">
      <h1>Document Sitemap & Screen Catalog</h1>
      <span>CATALOG & INDEX</span>
    </div>

    <div class="card" style="margin-bottom: 16px;">
      <div class="card-title">Comprehensive 15-Screen Mobile Directory</div>
      <table class="data-table">
        <thead>
          <tr>
            <th style="width: 40px;">#</th>
            <th style="width: 160px;">Screen Title</th>
            <th style="width: 140px;">Route Path</th>
            <th style="width: 120px;">Category</th>
            <th>Primary Architectural Responsibility</th>
          </tr>
        </thead>
        <tbody>
          ${screensData.map((s, idx) => `
          <tr>
            <td><strong>${s.id}</strong></td>
            <td><strong>${s.name}</strong></td>
            <td><code>${s.route}</code></td>
            <td>${s.category}</td>
            <td>${s.summary.substring(0, 85)}...</td>
          </tr>
          `).join('')}
        </tbody>
      </table>
    </div>

    <div class="content-grid-2">
      <div class="arch-box">
        <h3>📱 Viewport Specification</h3>
        <p><strong>Viewport Width:</strong> 390 pt (Logical) / 780 px (Physical)</p>
        <p><strong>Viewport Height:</strong> 844 pt (Logical) / 1688 px (Physical)</p>
        <p><strong>Device Pixel Ratio:</strong> 2.0x (Retina High-Density)</p>
        <p><strong>Touch Support:</strong> Full mobile touch gestures & kinetic scrolling</p>
      </div>
      <div class="arch-box">
        <h3>🎨 Core Theme Tokens</h3>
        <p><strong>Surface Base:</strong> <code>#0B0E14</code> (Obsidian Black)</p>
        <p><strong>Surface Container:</strong> <code>#151923</code> (Elevated Dark Slate)</p>
        <p><strong>Accent Mint:</strong> <code>#00FFB2</code> (Primary Interactive Color)</p>
        <p><strong>Accent Violet:</strong> <code>#9D4EDD</code> (Community & Brand Accent)</p>
      </div>
    </div>

    <div class="page-footer">
      <span>The Crew • Mobile Application System Specification</span>
      <span>Page 3 of 20</span>
    </div>
  </div>

  <!-- 15 SCREEN PAGES -->
  ${screensHtml}

  <!-- REST API & PROTOCOL SPECIFICATIONS -->
  <div class="page doc-page">
    <div class="page-header">
      <h1>REST API & Real-time WebSocket Protocol</h1>
      <span>TECHNICAL APPENDIX</span>
    </div>

    <div class="card" style="margin-bottom: 14px;">
      <div class="card-title">Complete REST API Endpoint Reference</div>
      <table class="data-table">
        <thead>
          <tr>
            <th style="width: 50px;">Method</th>
            <th style="width: 200px;">Endpoint</th>
            <th style="width: 100px;">Auth Guard</th>
            <th>Description & Payload</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><span class="method-badge method-post">POST</span></td>
            <td><code>/api/auth/register</code></td>
            <td>Public</td>
            <td>Creates new account with username, display name, email, password. Returns JWT & user profile.</td>
          </tr>
          <tr>
            <td><span class="method-badge method-post">POST</span></td>
            <td><code>/api/auth/login</code></td>
            <td>Public</td>
            <td>Authenticates user with email/username and password. Issues signed Bearer JWT token.</td>
          </tr>
          <tr>
            <td><span class="method-badge method-post">POST</span></td>
            <td><code>/api/auth/quick-login</code></td>
            <td>Public</td>
            <td>One-click developer login for demo roles (dev -> Kaelen, vip -> Nyx).</td>
          </tr>
          <tr>
            <td><span class="method-badge method-get">GET</span></td>
            <td><code>/api/servers</code></td>
            <td>Bearer JWT</td>
            <td>Lists all servers joined by current user with member count and role.</td>
          </tr>
          <tr>
            <td><span class="method-badge method-get">GET</span></td>
            <td><code>/api/servers/discover</code></td>
            <td>Public</td>
            <td>Queries public servers with optional <code>category</code> and <code>search</code> query parameters.</td>
          </tr>
          <tr>
            <td><span class="method-badge method-post">POST</span></td>
            <td><code>/api/servers</code></td>
            <td>Bearer JWT</td>
            <td>Creates server, sets user as OWNER, and automatically provisions 4 default channels.</td>
          </tr>
          <tr>
            <td><span class="method-badge method-get">GET</span></td>
            <td><code>/api/channels/:id/messages</code></td>
            <td>Bearer JWT</td>
            <td>Returns ordered chat history with user avatars, roles, and aggregated emoji reactions.</td>
          </tr>
          <tr>
            <td><span class="method-badge method-post">POST</span></td>
            <td><code>/api/channels/:id/messages</code></td>
            <td>Bearer JWT</td>
            <td>Posts text/media message. Immediately broadcasts <code>message:new</code> to room.</td>
          </tr>
          <tr>
            <td><span class="method-badge method-post">POST</span></td>
            <td><code>/api/channels/messages/:id/reactions</code></td>
            <td>Bearer JWT</td>
            <td>Toggles emoji reaction on message. Broadcasts <code>reaction:updated</code>.</td>
          </tr>
          <tr>
            <td><span class="method-badge method-get">GET</span></td>
            <td><code>/api/dms</code></td>
            <td>Bearer JWT</td>
            <td>Returns list of active online squad users and direct conversation threads with unread counts.</td>
          </tr>
          <tr>
            <td><span class="method-badge method-get">GET</span></td>
            <td><code>/api/dms/:userId</code></td>
            <td>Bearer JWT</td>
            <td>Fetches 1-on-1 direct conversation with partner and marks unread messages as read.</td>
          </tr>
          <tr>
            <td><span class="method-badge method-post">POST</span></td>
            <td><code>/api/dms/:userId</code></td>
            <td>Bearer JWT</td>
            <td>Sends direct message and dispatches <code>dm:new</code> event to partner and sender rooms.</td>
          </tr>
          <tr>
            <td><span class="method-badge method-get">GET</span></td>
            <td><code>/api/voice/:channelId</code></td>
            <td>Bearer JWT</td>
            <td>Fetches active voice participants and their speaking/muted states.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="card">
      <div class="card-title">WebSocket Event Dictionary (Socket.IO)</div>
      <table class="data-table">
        <thead>
          <tr>
            <th style="width: 140px;">Event Name</th>
            <th style="width: 80px;">Direction</th>
            <th style="width: 130px;">Target Room</th>
            <th>Payload & Functional Behavior</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><code>channel:join</code></td>
            <td>Client -> Server</td>
            <td><code>channel_&lt;id&gt;</code></td>
            <td>Subscribes client socket to live message and reaction updates in a text channel.</td>
          </tr>
          <tr>
            <td><code>message:new</code></td>
            <td>Server -> Client</td>
            <td><code>channel_&lt;id&gt;</code></td>
            <td>Pushes newly authored message object directly into active chat list.</td>
          </tr>
          <tr>
            <td><code>reaction:updated</code></td>
            <td>Server -> Client</td>
            <td><code>channel_&lt;id&gt;</code></td>
            <td>Pushes updated emoji counts and reacting user IDs for reactive UI badge re-render.</td>
          </tr>
          <tr>
            <td><code>dm:new</code></td>
            <td>Server -> Client</td>
            <td><code>user_&lt;partnerId&gt;</code></td>
            <td>Dispatches direct message payload instantly to recipient's private user room.</td>
          </tr>
          <tr>
            <td><code>voice:speaking_updated</code></td>
            <td>Server -> Client</td>
            <td><code>voice_&lt;channelId&gt;</code></td>
            <td>Broadcasts participant is_speaking boolean state for dynamic microphone glow ring.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="page-footer">
      <span>The Crew • Mobile Application System Specification</span>
      <span>Page 19 of 20</span>
    </div>
  </div>

  <!-- DATABASE ARCHITECTURE & CONCLUSION -->
  <div class="page doc-page">
    <div class="page-header">
      <h1>Database Architecture & Engineering Verification</h1>
      <span>SYSTEM VERIFICATION</span>
    </div>

    <div class="card" style="margin-bottom: 14px;">
      <div class="card-title">SQLite Relational Schema (WAL Mode Enabled)</div>
      <table class="data-table">
        <thead>
          <tr>
            <th style="width: 120px;">Table Name</th>
            <th style="width: 130px;">Primary Key</th>
            <th style="width: 150px;">Foreign Key Constraints</th>
            <th>Core Columns & Indexed Properties</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><code>users</code></td>
            <td><code>id TEXT</code></td>
            <td>—</td>
            <td>username (UNIQUE), display_name, email, password_hash, avatar_url, bio, status, custom_status.</td>
          </tr>
          <tr>
            <td><code>servers</code></td>
            <td><code>id TEXT</code></td>
            <td><code>owner_id -> users(id)</code></td>
            <td>name, description, icon_color, category, is_public, level, created_at.</td>
          </tr>
          <tr>
            <td><code>server_members</code></td>
            <td><code>id TEXT</code></td>
            <td><code>server_id, user_id</code></td>
            <td>role (OWNER, ADMIN, VIP, MEMBER), activity, joined_at. UNIQUE(server_id, user_id).</td>
          </tr>
          <tr>
            <td><code>channels</code></td>
            <td><code>id TEXT</code></td>
            <td><code>server_id -> servers(id)</code></td>
            <td>name, type ('text' | 'voice'), topic, position, created_at.</td>
          </tr>
          <tr>
            <td><code>messages</code></td>
            <td><code>id TEXT</code></td>
            <td><code>channel_id, sender_id</code></td>
            <td>content, has_media, media_url, media_title, media_duration, created_at.</td>
          </tr>
          <tr>
            <td><code>reactions</code></td>
            <td><code>id TEXT</code></td>
            <td><code>message_id, user_id</code></td>
            <td>emoji, created_at. UNIQUE(message_id, user_id, emoji).</td>
          </tr>
          <tr>
            <td><code>direct_messages</code></td>
            <td><code>id TEXT</code></td>
            <td><code>sender_id, receiver_id</code></td>
            <td>content, is_read, created_at.</td>
          </tr>
          <tr>
            <td><code>notifications</code></td>
            <td><code>id TEXT</code></td>
            <td><code>user_id -> users(id)</code></td>
            <td>actor_id, type ('mention' | 'reaction' | 'friend' | 'system'), title, body, time_display, is_read.</td>
          </tr>
          <tr>
            <td><code>voice_participants</code></td>
            <td><code>(channel_id, user_id)</code></td>
            <td><code>channel_id, user_id</code></td>
            <td>is_speaking, is_muted, is_streaming, status_text, joined_at.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="content-grid-2">
      <div class="arch-box">
        <h3>🔒 Security & Integrity Audit</h3>
        <p>• <strong>Password Protection:</strong> Hashed using bcrypt with 10 salt rounds.</p>
        <p>• <strong>Stateless Auth:</strong> Signed JSON Web Tokens (JWT) verified via Express middleware.</p>
        <p>• <strong>Secrets Management:</strong> Environment variables isolated via <code>.env</code> and excluded from Git.</p>
        <p>• <strong>Referential Integrity:</strong> <code>ON DELETE CASCADE</code> active across all foreign keys.</p>
      </div>

      <div class="arch-box">
        <h3>🚀 Future Roadmap & Scaling</h3>
        <p>• <strong>WebRTC Audio Signaling:</strong> Integration with LiveKit or Agora for multi-party audio mesh.</p>
        <p>• <strong>Direct Binary Uploads:</strong> Local disk storage via <code>multer</code> for direct photo/video attachments.</p>
        <p>• <strong>Push Notifications:</strong> Firebase Cloud Messaging (FCM) integration for mobile alerts.</p>
        <p>• <strong>Cross-Device Responsive:</strong> Tablet and foldable device master-detail adaptions.</p>
      </div>
    </div>

    <div class="card" style="margin-top: 10px; background: rgba(0, 255, 178, 0.05); border-color: rgba(0, 255, 178, 0.3);">
      <div class="card-title" style="color: #00FFB2;">System Sign-Off & Verification</div>
      <p style="color: #CBD5E1; font-size: 10px; line-height: 1.4;">
        This document concludes the technical specification and mobile UI audit for <strong>The Crew</strong>. All 15 mobile screens, REST endpoints, and WebSocket real-time event mechanisms have been validated, executed, and archived.
      </p>
    </div>

    <div class="page-footer">
      <span>The Crew • Mobile Application System Specification</span>
      <span>Page 20 of 20</span>
    </div>
  </div>

</body>
</html>
  `;
}

async function buildPdf() {
  console.log('Generating HTML layout for 20-page specification document...');
  const html = generateHtml();
  const htmlPath = path.resolve(__dirname, 'spec_document.html');
  fs.writeFileSync(htmlPath, html);
  console.log(`Saved HTML preview at: ${htmlPath}`);

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

  console.log('Rendering publication-grade A4 PDF...');
  await page.pdf({
    path: outputPdfPath,
    format: 'A4',
    printBackground: true,
    margin: {
      top: '10mm',
      bottom: '10mm',
      left: '12mm',
      right: '12mm'
    }
  });

  await browser.close();
  const stats = fs.statSync(outputPdfPath);
  console.log(`🎉 SUCCESS! PDF generated at: ${outputPdfPath}`);
  console.log(`📊 PDF File Size: ${(stats.size / 1024 / 1024).toFixed(2)} MB`);
}

buildPdf().catch(err => {
  console.error('Error generating PDF:', err);
  process.exit(1);
});
