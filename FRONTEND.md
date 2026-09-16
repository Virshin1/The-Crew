# The Crew — Frontend Documentation (Flutter Client)

> **The Crew** is a Discord-inspired cyberpunk community mobile platform built with Flutter. It features real-time text chat, emoji reactions, interactive voice channels, direct messaging, server/community discovery, notification feeds, customizable themes, and cross-device network connectivity.

---

## Table of Contents
1. [Architecture Overview](#1-architecture-overview)
2. [Tech Stack & Dependencies](#2-tech-stack--dependencies)
3. [Design System: Obsidian Pulse](#3-design-system-obsidian-pulse)
4. [Routing & Navigation Architecture](#4-routing--navigation-architecture)
5. [State Management (Provider Layer)](#5-state-management-provider-layer)
6. [Services & Networking Layer](#6-services--networking-layer)
7. [Screen Catalog & User Flows](#7-screen-catalog--user-flows)
8. [Reusable Components & Modals](#8-reusable-components--modals)
9. [Multi-Device & Network Configuration](#9-multi-device--network-configuration)
10. [Setup & Development Guide](#10-setup--development-guide)

---

## 1. Architecture Overview

The frontend follows a clean, modular, layered architecture that strictly separates UI presentation, reactive business state, network communication, and data modeling.

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  • 15 Screens (Chat, Voice, DMs, Discovery, Profile, Auth)  │
│  • Reusable UI Widgets (BottomNavShell, Dialogs, Buttons)    │
│  • Obsidian Pulse Theme (AppColors, AppTextStyles, AppTheme)│
└──────────────────────────────┬──────────────────────────────┘
                               │ Watches / Dispatches Actions
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 State Management (Provider)                 │
│  • AuthProvider         • ServerProvider   • ChatProvider   │
│  • DmProvider           • VoiceProvider    • NotificationPrv│
└──────────────────────────────┬──────────────────────────────┘
                               │ Calls
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   Service & Network Layer                   │
│  • ApiService (REST HTTP client + Dynamic Host Selector)    │
│  • SocketService (Socket.io Real-time Event Client)         │
│  • AuthService (SharedPreferences Session Caching)          │
│  • NavigationService (Context-free Router Helpers)          │
└──────────────────────────────┬──────────────────────────────┘
                               │ Serializes / Deserializes
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                         Data Layer                          │
│  • UserModel            • ServerModel      • ChannelModel   │
│  • MessageModel         • DmModel          • VoiceModel     │
│  • NotificationModel    • ServerMemberModel                 │
└─────────────────────────────────────────────────────────────┘
```

### Key Architectural Principles
- **Separation of Concerns**: Screens never make direct HTTP calls or interact directly with raw WebSocket sockets; all actions flow through dedicated `ChangeNotifier` providers.
- **Optimistic UI + Real-Time Reconciliation**: Chat and DM messages reflect instantly on submission while socket events sync across other active sessions in real time.
- **Dynamic Connection Resilience**: Mobile devices on physical Wi-Fi can switch backend endpoints on the fly without recompiling via `ServerConfigDialog` and `ApiService.setHost()`.

---

## 2. Tech Stack & Dependencies

The client is built on **Flutter 3.13+** using Dart null-safety.

| Package | Version | Purpose |
| :--- | :--- | :--- |
| **`flutter`** | SDK | Core UI toolkit and Material Design runtime |
| **`provider`** | `^6.1.2` | Dependency injection & reactive state management (`ChangeNotifierProvider`, `MultiProvider`) |
| **`go_router`** | `^15.1.2` | Declarative URL routing, nested navigation stacks, and `StatefulShellRoute` bottom bar |
| **`http`** | `^1.2.0` | High-level REST HTTP client for interacting with backend endpoints |
| **`socket_io_client`** | `^3.0.0` | Real-time WebSocket connection to Node.js backend (chat, reactions, DMs, presence, voice) |
| **`google_fonts`** | `^6.2.1` | Typography system loading Inter and Outfit styles |
| **`shared_preferences`** | `^2.2.3` | Persistent local storage for JWT auth tokens, user profiles, and backend IP overrides |
| **`google_sign_in`** | `^6.2.2` | Native and web Google authentication integration |
| **`cached_network_image`** | `^3.4.1` | Efficient image caching and placeholder rendering for user avatars and server icons |
| **`flutter_svg`** | `^2.0.17` | Vector rendering for futuristic logos and badges |
| **`cupertino_icons`** | `^1.0.8` | iOS-styled iconography when needed |

---

## 3. Design System: Obsidian Pulse

The application uses an atmospheric, cyberpunk-inspired dark theme called **Obsidian Pulse**.

### Color Tokens ([lib/theme/app_colors.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/theme/app_colors.dart))

```dart
// Core Surfaces
static const Color surface           = Color(0xFF131315);
static const Color surfaceBase       = Color(0xFF0A0A0B); // Deepest canvas
static const Color surfaceContainer  = Color(0xFF18181B); // Card container
static const Color surfaceRaised     = Color(0xFF222226); // Elevated sheets

// Borders & Dividers
static const Color borderSubtle      = Color(0xFF27272A);
static const Color borderMuted       = Color(0xFF1F1F23);

// Neon Accents
static const Color accentPurple      = Color(0xFF8B5CF6); // Primary branding
static const Color accentPink        = Color(0xFFEC4899); // Nitro / highlights
static const Color accentMint        = Color(0xFFCFFFE2); // Online badges & CTA

// Typography
static const Color textPrimary       = Color(0xFFF4F4F5);
static const Color textSecondary     = Color(0xFFA1A1AA);
static const Color textMuted         = Color(0xFF71717A);
```

### Typography Hierarchy ([lib/theme/app_text_styles.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/theme/app_text_styles.dart))
- **Headlines**: Semi-bold to Bold Inter (`headlineLg: 28px`, `headlineMd: 22px`, `headlineSm: 18px`).
- **Body**: Medium Inter (`bodyLg: 16px`, `bodyMd: 14px`, `bodySm: 12px`).
- **Labels / Badges**: Upper-case bold tracking (`labelSm: 11px`, `labelMd: 12px`).

### Material 3 Dark Theme ([lib/theme/app_theme.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/theme/app_theme.dart))
AppTheme configures scaffold background to `surfaceBase`, customizes `AppBarTheme`, `BottomNavigationBarTheme`, `CardTheme`, and `InputDecorationTheme` with rounded subtle borders and muted hint text.

---

## 4. Routing & Navigation Architecture

The application utilizes **`go_router`** declared in [lib/router/app_router.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/router/app_router.dart).

### Route Hierarchy

```
/ (Root Navigator)
 ├── /splash                    (SplashScreen)
 ├── /welcome                   (WelcomeScreen)
 ├── /login                     (LoginScreen)
 ├── /create-account            (CreateAccountScreen)
 └── StatefulShellRoute.indexedStack (BottomNavShell)
      ├── Branch 0: /servers    (MainChatScreen)
      │    ├── /servers/members (MemberListScreen)  [Pushed over root]
      │    └── /servers/voice   (VoiceChannelScreen) [Pushed over root]
      ├── Branch 1: /messages   (DmInboxScreen)
      │    └── /messages/chat/:userId (DmChatScreen) [Pushed over root]
      ├── Branch 2: /discover   (CommunityDiscoveryScreen)
      │    └── /discover/create (CreateCommunityScreen) [Pushed over root]
      ├── Branch 3: /activity   (NotificationsScreen)
      └── Branch 4: /profile    (UserProfileScreen)
           ├── /profile/settings(SettingsScreen) [Pushed over root]
           └── /profile/theme   (CustomizeThemeScreen) [Pushed over root]
```

### Root vs. Shell Navigation
- The 5 primary tabs stay mounted in memory via `StatefulShellRoute.indexedStack`, preserving scroll positions and draft input when switching between Chats, DMs, and Discovery.
- Full-screen subpages (e.g. `DmChatScreen`, `VoiceChannelScreen`, `MemberListScreen`, `SettingsScreen`) use `parentNavigatorKey: _rootNavigatorKey` to render above the bottom navigation bar.


---

## 5. State Management (Provider Layer)

All application providers are registered at the root in [lib/main.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/main.dart) using `MultiProvider`.

### 1. `AuthProvider` ([lib/providers/auth_provider.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/providers/auth_provider.dart))
- **Responsibilities**:
  - Manages active user session (`UserModel? currentUser`, `bool isAuthenticated`).
  - Restores session automatically from `SharedPreferences` on app launch.
  - Verifies token validity via `GET /api/auth/me`.
  - Handles `register()`, `login()`, `quickLogin(username)`, `signInWithGoogle()`, and `logout()`.
  - Automatically initializes and terminates the `SocketService` upon login/logout.
  - Handles profile updates (display name, bio, custom status).

### 2. `ServerProvider` ([lib/providers/server_provider.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/providers/server_provider.dart))
- **Responsibilities**:
  - Fetches and caches joined servers (`_joinedServers`) and discovery catalog (`_discoveryServers`).
  - Manages active server selection (`selectServer()`).
  - Fetches server channels and segregates them into `textChannels` and `voiceChannels`.
  - Fetches and sorts members (`_members`) by role hierarchy (`OWNER` > `ADMIN` > `VIP` > `MEMBER`).
  - Creates new servers and handles server join flows.

### 3. `ChatProvider` ([lib/providers/chat_provider.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/providers/chat_provider.dart))
- **Responsibilities**:
  - Maintains message history for the active text channel (`List<MessageModel> messages`).
  - Subscribes to Socket.IO `channel:join` and `channel:leave` rooms.
  - Listens for real-time incoming messages (`message:new`) and dedupes them by ID.
  - Handles real-time emoji reaction updates (`reaction:updated`) and optimistic state updates.
  - Sends messages with optional media attachments.

### 4. `DmProvider` ([lib/providers/dm_provider.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/providers/dm_provider.dart))
- **Responsibilities**:
  - Fetches DM conversation summaries and active online friends (`/api/dms`).
  - Loads 1-on-1 direct message history with a selected partner (`/api/dms/:userId`).
  - Automatically marks unread messages as read upon thread opening.
  - Listens to real-time `dm:new` WebSocket events and updates conversation lists and open chat views.

### 5. `VoiceProvider` ([lib/providers/voice_provider.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/providers/voice_provider.dart))
- **Responsibilities**:
  - Tracks live participants in the current voice channel (`VoiceParticipantModel`).
  - Manages local microphone and audio states (`isMuted`, `isDeafened`, `isSpeaking`, `isConnected`).
  - Subscribes to `voice:joined`, `voice:left`, `voice:mute_updated`, and `voice:speaking_updated` socket events.
  - Joins and leaves voice rooms (`/api/voice/:channelId/join` and `/leave`).

### 6. `NotificationProvider` ([lib/providers/notification_provider.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/providers/notification_provider.dart))
- **Responsibilities**:
  - Fetches notifications with category filtering (`All`, `Mentions`, `Reactions`, `Friends`, `System`).
  - Tracks badge count of unread notifications (`unreadCount`).
  - Dispatches `markAsRead(id)` and `markAllAsRead()`.

---

## 6. Services & Networking Layer

### `ApiService` ([lib/services/api_service.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/services/api_service.dart))
A resilient HTTP singleton client built over `package:http`:
- **Dynamic Host Resolution**:
  ```dart
  // Priority order:
  1. SharedPreferences override ('backend_host_override')
  2. Compile-time --dart-define=BACKEND_HOST=...
  3. Auto-detected reachable IP (localhost:3000, 172.30.6.83:3000, 10.0.2.2:3000)
  4. Fallback default 'localhost:3000'
  ```
- **Automatic Authorization**: Injects `Authorization: Bearer <token>` into all outbound requests once authenticated.
- **Diagnostics**: Includes `testConnection(host)` method with a 4-second timeout to verify health checks before persisting overrides.

### `SocketService` ([lib/services/socket_service.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/services/socket_service.dart))
Manages real-time bidirectional communication using `socket_io_client`:
- **Transports**: Configured for `['websocket', 'polling']` for instant fallbacks across mobile networks.
- **Authentication**: Passes user JWT in connection handshake payload (`auth: { token: ... }`).
- **Room Subscriptions**: Emits `channel:join` and `voice:join` when navigating to specific rooms.
- **Event Listeners**: Exposes structured Dart callbacks for `message:new`, `reaction:updated`, `dm:new`, `voice:joined`, etc.

### `AuthService` ([lib/services/auth_service.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/services/auth_service.dart))
Wraps `SharedPreferences` to securely persist:
- `auth_token`: String JWT token.
- `auth_user`: Serialized JSON representation of `UserModel`.

---

## 7. Screen Catalog & User Flows

| Screen | File | Description & Key Features |
| :--- | :--- | :--- |
| **Splash Screen** | [splash_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/splash_screen.dart) | Futuristic pulsating logo, initializes `ApiService`, checks session, auto-redirects to `/servers` or `/welcome`. |
| **Welcome Screen** | [welcome_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/welcome_screen.dart) | Visual brand hero, options to Register, Login, or 1-Tap Quick Demo Login. |
| **Login Screen** | [login_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/login_screen.dart) | Email/Username input, password toggle, Quick Demo Login buttons (Kaelen / Nyx), Google Sign-In. |
| **Create Account** | [create_account_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/create_account_screen.dart) | Full user onboarding: Username, Display Name, Email, Password, and gamer interest selector pills. |
| **Main Chat Screen** | [main_chat_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/main_chat_screen.dart) | Discord-style layout: Server sidebar, Channel drawer, active text chat list, embedded media card, active voice widget, and message input. |
| **Member List Screen** | [member_list_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/member_list_screen.dart) | Server roster grouped by Owner, Admin, VIP, and Member with online status indicators, custom activity bios, and 1-tap "Direct Message" action sheet. |
| **Voice Channel Screen**| [voice_channel_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/voice_channel_screen.dart) | Spatial audio participant grid, animated speaking halos, Mute, Deafen, Screen Share, and Disconnect controls. |
| **DM Inbox Screen** | [dm_inbox_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/dm_inbox_screen.dart) | Horizontal active-now friend stories, recent DM conversations, unread badges, and direct navigation into dedicated `DmChatScreen`. |
| **DM Chat Screen** | [dm_chat_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/dm_chat_screen.dart) | Dedicated full-screen 1-on-1 real-time direct messaging, partner profile sheet, message bubbles, timestamp grouping, and auto-scroll. |
| **Community Discovery** | [community_discovery_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/community_discovery_screen.dart) | Search bar, category filters (Gaming, Music, Art, Tech, Cozy), server cards with member counts and 1-tap Join. |
| **Create Community** | [create_community_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/create_community_screen.dart) | Server setup modal: community name, description, category selector, neon accent color picker, public/private toggle. |
| **Notifications Screen**| [notifications_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/notifications_screen.dart) | Real-time notification feed with tabs for All, Mentions, Reactions, Friends, and System; Mark All as Read button. |
| **User Profile Screen** | [user_profile_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/user_profile_screen.dart) | Profile header, custom status editor, bio card, joined server badges, account statistics, and quick navigation. |
| **Settings Screen** | [settings_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/settings_screen.dart) | Connection diagnostics, active server IP info, cache clearing, theme switching, and sign-out button. |
| **Customize Theme** | [customize_theme_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/customize_theme_screen.dart) | Theme selector previewing Obsidian Pulse, Cyberpunk Neon, and Midnight AMOLED presets. |

---

## 8. Reusable Components & Modals

### `ServerConfigDialog` ([lib/widgets/server_config_dialog.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/widgets/server_config_dialog.dart))
A bottom-sheet modal that lets developers and users adjust backend networking on physical devices:
- Quick presets for **Physical Phone (LAN Wi-Fi)**, **Android Emulator (`10.0.2.2:3000`)**, and **Localhost**.
- Text field for custom host input (`http://<ip>:<port>`).
- Built-in **"Test Ping"** button that sends a test request to `/api/health` and displays instant latency/success feedback.
- Persists changes to local storage and updates `SocketService` on the fly.

### `BottomNavShell` ([lib/widgets/bottom_nav_shell.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/widgets/bottom_nav_shell.dart))
A custom floating frosted-glass bottom bar with subtle neon borders, housing the 5 core navigation icons with badge counters.

### `GoogleSignInButton` ([lib/widgets/google_sign_in_button.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/widgets/google_sign_in_button.dart))
Custom-styled button adhering to Google brand guidelines while matching the obsidian dark palette, supporting real Google OAuth and seamless demo fallbacks.

---

## 9. Multi-Device & Network Configuration

When running on different development targets, the client needs to reach the Node.js backend:

| Target Platform | Recommended Backend Address | How to Configure |
| :--- | :--- | :--- |
| **macOS Desktop / Chrome Web** | `localhost:3000` | Automatically detected by default |
| **iOS Simulator** | `localhost:3000` | Works directly via loopback |
| **Android Emulator** | `10.0.2.2:3000` | Select preset in `ServerConfigDialog` or use `adb reverse tcp:3000 tcp:3000` |
| **Physical Phone (Wi-Fi)** | `172.30.6.83:3000` (LAN IP) | Select Wi-Fi preset in `ServerConfigDialog` or pass `--dart-define=BACKEND_HOST=172.30.6.83:3000` |

### Setting Host at Build Time
```bash
flutter run --dart-define=BACKEND_HOST=172.30.6.83:3000
```

---

## 10. Setup & Development Guide

### Prerequisites
- **Flutter SDK**: `^3.13.0` (Dart `^3.13.0`)
- **Xcode** (for iOS/macOS testing)
- **Android Studio / Command-line tools** (for Android testing)

### Installation
```bash
# 1. Clone repository and navigate to root
cd /path/to/The_crew_flutter_mini_project

# 2. Install Dart dependencies
flutter pub get

# 3. Analyze code quality
flutter analyze

# 4. Launch the application
# For macOS Desktop:
flutter run -d macos

# For Chrome (Web):
flutter run -d chrome

# For Connected Android / iOS device:
flutter run
```

### Hot Reload & Dev Tools
- In the terminal running Flutter, press **`r`** for hot reload and **`R`** for hot restart.
- Open the Flutter DevTools URL displayed in the console to inspect widget trees, monitor network traffic, and profile memory usage.
