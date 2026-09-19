# The Crew — Frontend Architectural & Developer Guide (Flutter Client)

> **The Crew** is a Discord-inspired cyberpunk community mobile platform built with **Flutter 3.13+** and **Dart 3.13+**. It delivers a high-performance, real-time community experience featuring multi-room text chat, interactive emoji reactions, spatial audio voice stages, direct messaging (DMs), server & community discovery, live notification feeds, customizable cyberpunk themes, and seamless cross-device local network connectivity.

---

## Table of Contents
1. [Executive Architecture Overview](#1-executive-architecture-overview)
2. [Complete Technology Stack & Dependencies](#2-complete-technology-stack--dependencies)
3. [Obsidian Pulse Design System & Visual Tokens](#3-obsidian-pulse-design-system--visual-tokens)
4. [Routing & Navigation Architecture (`go_router`)](#4-routing--navigation-architecture-go_router)
5. [Reactive State Management Layer (`provider`)](#5-reactive-state-management-layer-provider)
6. [Data Models & Schema Serialization](#6-data-models--schema-serialization)
7. [Networking & Real-Time Synchronization](#7-networking--real-time-synchronization)
8. [Comprehensive Screen Catalog (15 Screens)](#8-comprehensive-screen-catalog-15-screens)
9. [Reusable Component & Widget Library](#9-reusable-component--widget-library)
10. [Multi-Device & Network Configuration Guide](#10-multi-device--network-configuration-guide)
11. [Developer Onboarding, Build & Testing Guide](#11-developer-onboarding-build--testing-guide)
12. [Troubleshooting & Best Practices](#12-troubleshooting--best-practices)

---

## 1. Executive Architecture Overview

The Crew frontend adopts a strict **Layered Clean Architecture** pattern designed for high maintainability, testability, and smooth 60/120 FPS UI rendering.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                            │
│  • 15 Screens (Auth, Servers, Chat, Voice, DMs, Discovery, Profile)     │
│  • Reusable UI Widgets (BottomNavShell, Dialogs, Logos, Buttons)        │
│  • Obsidian Pulse Theme (AppColors, AppTextStyles, AppTheme)            │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ Watches State / Dispatches Actions
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      STATE MANAGEMENT LAYER (Provider)                  │
│  • AuthProvider         • ServerProvider        • ChatProvider          │
│  • DmProvider           • VoiceProvider         • NotificationProvider  │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ Invokes Domain Services
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        SERVICE & NETWORK LAYER                          │
│  • ApiService (REST HTTP Client + Dynamic LAN Host Switcher)            │
│  • SocketService (Socket.io Real-time WebSocket Protocol Client)        │
│  • AuthService (SharedPreferences Persistent Session Store)             │
│  • NavigationService (Context-Free Global Navigation Helpers)           │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ Serializes / Hydrates
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              DATA LAYER                                 │
│  • UserModel            • ServerModel           • ChannelModel          │
│  • MessageModel         • DmModel               • VoiceParticipantModel │
│  • NotificationModel    • ServerMemberModel     • MessageReaction       │
└─────────────────────────────────────────────────────────────────────────┘
```

### Architectural Guarantees
1. **Unidirectional Data Flow**: UI widgets listen to `Provider` state changes via `context.watch<T>()` and trigger actions via `context.read<T>()`.
2. **Zero Network Coupling in UI**: Widgets never make direct HTTP calls or interact directly with raw WebSocket socket descriptors. All transport logic is strictly encapsulated in `lib/services/` and mediated by `lib/providers/`.
3. **Optimistic Local Updates with Server Reconciliation**: Actions such as sending chat messages, sending DMs, or toggling emoji reactions immediately update local reactive lists for zero-latency user feedback, reconciling with backend responses upon WebSocket confirmation.
4. **Dynamic Connection Resilience**: Mobile devices running physical builds on local Wi-Fi can switch backend host endpoints on the fly without recompilation via `ServerConfigDialog` and `ApiService.setHost()`.

---

## 2. Complete Technology Stack & Dependencies

The Flutter client targets **iOS, Android, macOS, and Web** from a single unified codebase.

| Dependency | Exact Version | Architectural Purpose | Implementation File |
| :--- | :--- | :--- | :--- |
| **`flutter`** | SDK (3.13+) | Core UI rendering framework, Material 3 runtime, gesture recognizers | Root SDK |
| **`provider`** | `^6.1.2` | Dependency injection & reactive state management (`ChangeNotifierProvider`, `MultiProvider`) | [lib/main.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/main.dart) |
| **`go_router`** | `^15.1.2` | Declarative routing, nested shell branches, deep linking, modal dialog navigators | [lib/router/app_router.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/router/app_router.dart) |
| **`http`** | `^1.2.0` | High-level REST HTTP client for interacting with Node.js backend endpoints | [lib/services/api_service.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/services/api_service.dart) |
| **`socket_io_client`** | `^3.0.0` | Real-time WebSocket connection to Node.js backend (chat, reactions, DMs, presence, voice) | [lib/services/socket_service.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/services/socket_service.dart) |
| **`google_fonts`** | `^6.2.1` | Typography system loading Inter and Outfit styles at runtime with offline caching | [lib/theme/app_text_styles.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/theme/app_text_styles.dart) |
| **`shared_preferences`** | `^2.2.3` | Key-value disk persistence for JWT authentication tokens, user sessions, and host overrides | [lib/services/auth_service.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/services/auth_service.dart) |
| **`google_sign_in`** | `^6.2.2` | Google OAuth client supporting both native Android/iOS and web token flows | [lib/providers/auth_provider.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/providers/auth_provider.dart) |
| **`cached_network_image`** | `^3.4.1` | Disk and memory-cached image rendering with placeholder shimmer for avatars and banners | [lib/widgets/](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/widgets/) |
| **`flutter_svg`** | `^2.0.17` | High-performance vector rendering for cyberpunk brand badges and logos | [lib/widgets/app_logo.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/widgets/app_logo.dart) |
| **`cupertino_icons`** | `^1.0.8` | Standard iOS glyph asset bundle | Embedded asset |

---

## 3. Obsidian Pulse Design System & Visual Tokens

The user interface implements **Obsidian Pulse**, an atmospheric, cyberpunk-inspired dark design system optimized for high contrast on OLED/AMOLED displays.

### 3.1 Surface Hierarchy & Color Tokens ([lib/theme/app_colors.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/theme/app_colors.dart))

```
┌────────────────────────────────────────────────────────────────────────┐
│ SURFACE ELEVATIONS                                                     │
├──────────────────────────┬──────────────┬──────────────────────────────┤
│ Token                    │ Hex Value    │ Semantic Usage               │
├──────────────────────────┼──────────────┼──────────────────────────────┤
│ AppColors.surfaceBase    │ #0A0A0B      │ Deepest root canvas        │
│ AppColors.surface        │ #131315      │ Primary screen scaffold    │
│ AppColors.surfaceCanvas  │ #121214      │ Alternative background     │
│ AppColors.surfaceContainer Lowest│ #0E0E10│ Recessed inputs / search bars │
│ AppColors.surfaceContainer Low   │ #1B1B1D│ List item backgrounds    │
│ AppColors.surfaceContainer │ #18181B    │ Cards & modal sheets       │
│ AppColors.surfaceContainer │ #2A2A2C  │ Popups, tooltips, dialogs.   │
│ AppColors.surfaceRaised  │ #222226    │ Floating bottom bars & pills │
└──────────────────────────┴──────────────┴──────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────┐
│ BORDERS & DIVIDERS                                                     │
├──────────────────────────┬──────────────┬──────────────────────────────┤
│ AppColors.borderSubtle   │ #27272A      │ Card outlines & card dividers│
│ AppColors.borderMuted    │ #1F1F23      │ Subtle section borders       │
└──────────────────────────┴──────────────┴──────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────┐
│ NEON ACCENTS & BRANDING                                                │
├──────────────────────────┬──────────────┬──────────────────────────────┤
│ AppColors.accentPurple   │ #8B5CF6      │ Primary brand color & focus  │
│ AppColors.accentPink     │ #EC4899      │ Nitro, streaming, highlights │
│ AppColors.accentMint     │ #CFFFE2      │ Online status, CTAs, badges  │
│ AppColors.primaryContainer│ #BEEDD1     │ Mint highlight containers    │
└──────────────────────────┴──────────────┴──────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────┐
│ TYPOGRAPHY COLORS                                                      │
├──────────────────────────┬──────────────┬──────────────────────────────┤
│ AppColors.textPrimary    │ #F4F4F5      │ High-contrast headers & text │
│ AppColors.textSecondary  │ #A1A1AA      │ Subtitles & secondary labels │
│ AppColors.textMuted      │ #71717A      │ Timestamps, hints, footers   │
└──────────────────────────┴──────────────┴──────────────────────────────┘
```

### 3.2 Typography Scale ([lib/theme/app_text_styles.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/theme/app_text_styles.dart))
Typography is powered by Google Fonts `Inter`:

| Style Token  | Font Size | Weight        | Line Height | Letter Spacing | Usage |
| :---         | :---      | :---          | :--- | :--- | :--- |
| `displayLg`  | 36px      | Bold (700)    | 1.15 | -0.5px | Hero titles & splash branding |
| `headlineLg` | 28px      | Bold (700)    | 1.25 | -0.3px | Screen headings & modal titles|
| `headlineMd` | 22px      | SemiBold (600)| 1.30 | 0.0px  | Server names & channel titles |
| `headlineSm` | 18px      | SemiBold (600)| 1.35 | 0.0px  | Card headers & usernames      |
| `titleMd`    | 16px      | Medium (500)  | 1.40 | 0.1px  | Message sender names          |
| `bodyLg`     | 16px      | Regular (400) | 1.50 | 0.15px | Long-form bios & guidelines   |
| `bodyMd`     | 14px      | Regular (400) | 1.45 | 0.25px | Chat messages & input fields  |
| `bodySm`     | 12px      | Regular (400) | 1.40 | 0.4px  | Subtitles & timestamps        |
| `labelMd`    | 12px      | SemiBold (600)| 1.20 | 0.8px  | Role tags & buttons           |
| `labelSm`    | 11px      | Bold (700)    | 1.20 | 1.2px  | Section header tracking pills |

### 3.3 Material 3 Dark Theme Specification ([lib/theme/app_theme.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/theme/app_theme.dart))
- **Scaffold Background**: `AppColors.surfaceBase` (`#0A0A0B`).
- **AppBar**: Transparent background with light status icons and zero elevation.
- **Input Decoration**: Rounded rectangle borders (`Radius.circular(12)`), filled with `AppColors.surfaceContainer`, with `AppColors.borderSubtle` outlines.
- **Bottom Navigation Bar**: Custom frosted glass shell with blurred backdrop.

---

## 4. Routing & Navigation Architecture (`go_router`)

The entire navigation graph is declared in [lib/router/app_router.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/router/app_router.dart).

```
/ (Global Navigator Key: _rootNavigatorKey)
 │
 ├── /splash                     ───> SplashScreen
 ├── /welcome                    ───> WelcomeScreen
 ├── /login                      ───> LoginScreen
 ├── /create-account             ───> CreateAccountScreen
 │
 └── StatefulShellRoute.indexedStack (BottomNavShell)
      │
      ├── Branch 0: /servers     ───> MainChatScreen
      │    ├── /servers/members  ───> MemberListScreen   (Root Navigator Stack)
      │    └── /servers/voice    ───> VoiceChannelScreen (Root Navigator Stack)
      │
      ├── Branch 1: /messages    ───> DmInboxScreen
      │    └── /messages/chat/:userId ──> DmChatScreen   (Root Navigator Stack)
      │
      ├── Branch 2: /discover    ───> CommunityDiscoveryScreen
      │    └── /discover/create  ───> CreateCommunityScreen (Root Navigator Stack)
      │
      ├── Branch 3: /activity    ───> NotificationsScreen
      │
      └── Branch 4: /profile     ───> UserProfileScreen
           ├── /profile/settings ───> SettingsScreen       (Root Navigator Stack)
           └── /profile/theme    ───> CustomizeThemeScreen (Root Navigator Stack)
```

### 4.1 Shell vs. Root Navigation Strategy
- **Stateful Indexed Stack (`StatefulShellRoute`)**: The 5 bottom navigation branches (`Servers`, `Messages`, `Discover`, `Activity`, `Profile`) stay live in memory when switching tabs. Text inputs, draft messages, and scroll offsets are completely preserved.
- **Root Navigator Overrides (`parentNavigatorKey: _rootNavigatorKey`)**: Full-screen flows—such as `DmChatScreen`, `VoiceChannelScreen`, `MemberListScreen`, `CreateCommunityScreen`, and `SettingsScreen`—are configured with the root navigator key. This pushes the new route completely over the bottom navigation bar, hiding the tabs and giving the full screen real estate to the active task.
- **Dynamic Parameter Parsing**: Sub-routes extract strongly-typed path parameters:
  ```dart
  GoRoute(
    path: 'chat/:userId',
    parentNavigatorKey: _rootNavigatorKey,
    builder: (context, state) {
      final userId = state.pathParameters['userId'] ?? '';
      return DmChatScreen(partnerId: userId);
    },
  )
  ```

---

## 5. Reactive State Management Layer (`provider`)

The application bootstraps 6 global `ChangeNotifier` providers in [lib/main.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/main.dart) using `MultiProvider`.

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: authProvider),
    ChangeNotifierProvider(create: (_) => ServerProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    ChangeNotifierProvider(create: (_) => DmProvider()),
    ChangeNotifierProvider(create: (_) => VoiceProvider()),
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
  ],
  child: const TheCrewApp(),
)
```

---

### 5.1 `AuthProvider` ([lib/providers/auth_provider.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/providers/auth_provider.dart))

#### State Properties & Getters
- `UserModel? currentUser`: Currently authenticated user profile.
- `bool isAuthenticated`: Returns `true` if `currentUser != null`.
- `bool isLoading`: True during authentication network operations.
- `String? errorMessage`: Captures human-readable authentication failure messages.

#### Core Methods
- `Future<void> restoreSession()`: Reads stored JWT and user JSON from `SharedPreferences`. Re-authenticates socket connection and validates token with `GET /api/auth/me`.
- `Future<bool> register({username, displayName, email, password, interests})`: Registers a new account, stores token, joins default server `s1` (Neon Arcade), connects socket, and notifies listeners.
- `Future<bool> login({login, password})`: Authenticates via email or username, saves JWT, and starts real-time socket connection.
- `Future<bool> quickLogin([String username = 'kaelen_vr'])`: 1-tap instant demo authentication without manual typing.
- `Future<bool> signInWithGoogle()`: Launches native Google Sign-In sheet, sends OAuth payload (`email`, `displayName`, `photoUrl`, `googleId`) to `POST /api/auth/google`, and initializes session.
- `Future<bool> updateProfile({displayName, bio, status, customStatus})`: Sends `PUT /api/auth/profile` and refreshes cached session.
- `Future<void> logout()`: Clears memory, deletes disk session in `AuthService`, disconnects socket, and resets state.

---

### 5.2 `ServerProvider` ([lib/providers/server_provider.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/providers/server_provider.dart))

#### State Properties & Getters
- `List<ServerModel> joinedServers`: All servers joined by current user.
- `List<ServerModel> discoveryServers`: Public servers returned by search/category query.
- `ServerModel? currentServer`: Active server selected in the sidebar.
- `List<ChannelModel> channels`: All channels belonging to `currentServer`.
- `ChannelModel? currentChannel`: Active text or voice channel.
- `List<ServerMemberModel> members`: Member roster of `currentServer`.
- `List<ChannelModel> textChannels`: Convenience getter filtering `c.isText`.
- `List<ChannelModel> voiceChannels`: Convenience getter filtering `c.isVoice`.

#### Core Methods
- `Future<void> fetchJoinedServers()`: Calls `GET /api/servers`. Automatically selects the first server if none is active.
- `Future<void> selectServer(ServerModel server)`: Sets active server, triggers `fetchChannels()` and `fetchMembers()`.
- `Future<void> fetchChannels(String serverId)`: Calls `GET /api/servers/:id/channels`. Automatically defaults to `#lounge` or the first text channel.
- `void selectChannel(ChannelModel channel)`: Switches the active channel view.
- `Future<void> fetchMembers(String serverId)`: Calls `GET /api/servers/:id/members`.
- `Future<void> fetchDiscoveryServers({String? category, String? search})`: Queries `GET /api/servers/discover?category=...&search=...`.
- `Future<bool> createServer({name, description, category, isPublic, iconColor})`: Posts to `POST /api/servers`, auto-generates default channels, joins server as `OWNER`, and switches active view.
- `Future<bool> joinServer(String serverId)`: Calls `POST /api/servers/:id/join` and refreshes joined list.

---

### 5.3 `ChatProvider` ([lib/providers/chat_provider.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/providers/chat_provider.dart))

#### State Properties & Getters
- `List<MessageModel> messages`: Live message history for the active text channel.
- `String? activeChannelId`: ID of the channel currently subscribed to.
- `bool isLoading`: True while initial channel history is fetching.

#### Socket.IO Event Integrations
- Subscribes to `message:new`: Checks if `newMsg.channelId == activeChannelId`. Performs deduplication by ID, appends message, and calls `notifyListeners()`.
- Subscribes to `reaction:updated`: Finds target message by `message_id`, updates its `reactions` array via `copyWith(reactions: ...)`, and calls `notifyListeners()`.

#### Core Methods
- `Future<void> loadChannel(String channelId)`: Leaves previous socket room via `leaveChannel()`, clears message list, joins new socket room `channel:join`, and queries `GET /api/channels/:id/messages`.
- `Future<bool> sendMessage(String text)`: Posts to `POST /api/channels/:id/messages`. Optimistically appends to local list if not yet delivered by socket.
- `Future<void> toggleReaction(String messageId, String emoji)`: Calls `POST /api/channels/messages/:messageId/reactions` and reconciles updated reaction list.

---

### 5.4 `DmProvider` ([lib/providers/dm_provider.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/providers/dm_provider.dart))

#### State Properties & Getters
- `List<DmConversationModel> conversations`: List of recent 1-on-1 direct message conversations with latest message, timestamp, and unread counts.
- `List<UserModel> activeNow`: Online friends available to squad up with.
- `List<DmMessageModel> currentMessages`: Message history of the currently opened DM thread.
- `UserModel? currentPartner`: Profile of the user currently being messaged.

#### Socket.IO Event Integrations
- Subscribes to `dm:new`: If the DM belongs to the active thread (`currentPartner`), it appends the message immediately to `_currentMessages`. Also calls `fetchConversations()` to update inbox previews and unread badges in background.

#### Core Methods
- `Future<void> fetchConversations()`: Calls `GET /api/dms` to refresh conversation summaries and "Active Now" list.
- `Future<void> loadDmThread(String partnerId)`: Calls `GET /api/dms/:userId` to retrieve partner metadata and conversation history, automatically marking unread messages as read.
- `Future<bool> sendDm(String partnerId, String text)`: Posts to `POST /api/dms/:userId`. Appends to thread immediately and triggers inbox refresh.

---

### 5.5 `VoiceProvider` ([lib/providers/voice_provider.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/providers/voice_provider.dart))

#### State Properties & Getters
- `List<VoiceParticipantModel> participants`: Live list of members connected to the active voice stage.
- `String? channelId`: ID of the connected voice channel.
- `bool isConnected`: True if user is currently inside a voice stage.
- `bool isMuted`: Local microphone mute status.
- `bool isDeafened`: Local audio output deafened status.
- `bool isSpeaking`: Simulated speaking broadcast state.

#### Socket.IO Event Integrations
- `voice:joined`: Appends or updates participant record in `_participants`.
- `voice:left`: Removes participant record matching `userId`.
- `voice:mute_updated`: Updates `isMuted` and `statusText` for target user.
- `voice:speaking_updated`: Updates `isSpeaking` halo animation for target user.

#### Core Methods
- `Future<void> loadParticipants(String channelId)`: Queries `GET /api/voice/:channelId`.
- `Future<void> joinVoice(String channelId)`: Emits `POST /api/voice/:channelId/join` and sets `isConnected = true`.
- `Future<void> leaveVoice()`: Emits `POST /api/voice/:channelId/leave`, sets `isConnected = false`, and resets channel ID.
- `Future<void> toggleMute()`: Calls `POST /api/voice/:channelId/toggle-mute`.
- `void toggleDeafen()`: Toggles local audio mute state.
- `Future<void> toggleSpeaking()`: Calls `POST /api/voice/:channelId/speaking` with boolean state.

---

### 5.6 `NotificationProvider` ([lib/providers/notification_provider.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/providers/notification_provider.dart))

#### State Properties & Getters
- `List<NotificationModel> notifications`: Filtered notifications feed.
- `String activeFilter`: Current active tab (`All`, `Mentions`, `Reactions`, `Friends`, `System`).
- `int unreadCount`: Number of notifications where `!isRead`.

#### Core Methods
- `Future<void> fetchNotifications({String? filter})`: Queries `GET /api/notifications?type=...`.
- `Future<void> markAsRead(String id)`: Posts to `POST /api/notifications/:id/read` and marks item read in place.
- `Future<void> markAllAsRead()`: Posts to `POST /api/notifications/read-all` and marks all items read.

---

## 6. Data Models & Schema Serialization

All models are located in `lib/models/` and include factory constructors for `fromJson` and serialization for `toJson`.

### 6.1 Entity Matrix

| Model | Source File | JSON Contract Fields |
| :--- | :--- | :--- |
| **`UserModel`** | [user_model.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/models/user_model.dart) | `id`, `username`, `display_name`, `email`, `avatar_url`, `bio`, `status`, `custom_status`, `interests`, `created_at` |
| **`ServerModel`** | [server_model.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/models/server_model.dart) | `id`, `name`, `description`, `icon_url`, `icon_color`, `owner_id`, `category`, `is_public`, `level`, `member_count`, `online_count`, `my_role` |
| **`ServerMemberModel`**| [server_model.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/models/server_model.dart) | `member_id`, `user_id`, `username`, `display_name`, `avatar_url`, `role`, `activity`, `status`, `custom_status`, `isOnline` getter |
| **`ChannelModel`** | [channel_model.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/models/channel_model.dart) | `id`, `server_id`, `name`, `type` (`text`\|`voice`), `topic`, `position`, `created_at`, `isText`/`isVoice` getters |
| **`MessageModel`** | [message_model.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/models/message_model.dart) | `id`, `channel_id`, `sender_id`, `content`, `has_media`, `media_url`, `media_title`, `media_duration`, `created_at`, `username`, `display_name`, `avatar_url`, `sender_role`, `reactions` |
| **`MessageReaction`** | [message_model.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/models/message_model.dart) | `emoji`, `count`, `users` (list of user IDs who reacted) |
| **`DmConversationModel`**| [dm_model.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/models/dm_model.dart) | `partner_id`, `display_name`, `username`, `avatar_url`, `status`, `custom_status`, `last_message`, `last_message_time`, `unread_count` |
| **`DmMessageModel`** | [dm_model.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/models/dm_model.dart) | `id`, `sender_id`, `receiver_id`, `content`, `is_read`, `created_at`, `sender_name`, `sender_avatar` |
| **`VoiceParticipantModel`**| [voice_participant_model.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/models/voice_participant_model.dart) | `channel_id`, `user_id`, `username`, `display_name`, `avatar_url`, `is_speaking`, `is_muted`, `is_streaming`, `status_text`, `joined_at` |
| **`NotificationModel`**| [notification_model.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/models/notification_model.dart) | `id`, `user_id`, `actor_id`, `type`, `title`, `body`, `time_display`, `is_read`, `actor_username`, `actor_display_name`, `actor_avatar` |

---

## 7. Networking & Real-Time Synchronization

The networking architecture is split between a REST client (`ApiService`) and a real-time WebSocket client (`SocketService`).

### 7.1 `ApiService` ([lib/services/api_service.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/services/api_service.dart))

#### Dynamic Host Selection Algorithm
To enable physical testing on Android and iOS devices connected over local Wi-Fi without hardcoding IPs, `ApiService` uses a 4-tier fallback:

```dart
// Host Resolution Priority Order:
1. SharedPreferences override: Key 'backend_host_override' set by ServerConfigDialog
2. Environment Variable: String.fromEnvironment('BACKEND_HOST') passed at build time
3. Auto-detected reachable IP:
     • Tests 'localhost:3000' (Mac/Desktop/Simulator)
     • Tests '172.30.6.83:3000' (Physical Wi-Fi LAN IP)
     • Tests '10.0.2.2:3000' (Android Emulator loopback)
4. Default fallback: 'localhost:3000'
```

#### Diagnostic Health Ping
`ApiService.testConnection([host])` dispatches a `GET /api/health` request with a **4-second strict timeout**. It returns `true` only if `statusCode == 200`, preventing bad host overrides from being saved.

#### Authorization Interceptor
Whenever an authenticated session exists, `_headers()` automatically injects:
```dart
{
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer <token>'
}
```

---

### 7.2 `SocketService` ([lib/services/socket_service.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/services/socket_service.dart))

#### Connection Lifecycle
- **Instantiation**: Creates a single `io.Socket` using `io.OptionBuilder().setTransports(['websocket', 'polling'])`.
- **Handshake Auth**: Passes `{ token: token }` in `auth` payload for server-side token validation.
- **Auto-Reconnection**: Automatically fails over to HTTP long-polling if raw WebSockets are blocked by carrier NATs.

#### Client Event Matrix

```
┌───────────────────────────────┬────────────┬────────────────────────────────────────────────────────┐
│ Event Name                    │ Direction  │ Action & Payload                                       │
├───────────────────────────────┼────────────┼────────────────────────────────────────────────────────┤
│ channel:join                  │ Emitted    │ { channelId: string }                                  │
│ channel:leave                 │ Emitted    │ { channelId: string }                                  │
│ message:new                   │ Listened   │ Appends MessageModel to active ChatProvider channel    │
│ reaction:updated              │ Listened   │ Replaces reaction list on target MessageModel          │
│ dm:new                        │ Listened   │ Delivers DmMessageModel to DmProvider & updates unread │
│ voice:join                    │ Emitted    │ { channelId: string }                                  │
│ voice:leave                   │ Emitted    │ { channelId: string }                                  │
│ voice:joined                  │ Listened   │ Appends VoiceParticipantModel to stage roster          │
│ voice:left                    │ Listened   │ Removes participant from stage roster                  │
│ voice:mute_updated            │ Listened   │ Updates mute badge on participant card                 │
│ voice:speaking_updated        │ Listened   │ Toggles glowing speaking halo animation                │
└───────────────────────────────┴────────────┴────────────────────────────────────────────────────────┘
```

---

## 8. Comprehensive Screen Catalog (15 Screens)

Every screen is located in `lib/screens/` and represents a distinct user journey.

---

### 8.1 `SplashScreen` ([splash_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/splash_screen.dart))
- **Route**: `/splash`
- **Purpose**: Brand introduction, asset preloading, and authentication check.
- **Visuals**: Futuristic pulsating hexagon logo with glowing ambient rings and loading spinner.
- **State Logic**: Invokes `ApiService.init()`, then `AuthProvider.restoreSession()`. If authenticated, routes to `/servers` via `context.go('/servers')`; otherwise navigates to `/welcome`.

---

### 8.2 `WelcomeScreen` ([welcome_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/welcome_screen.dart))
- **Route**: `/welcome`
- **Purpose**: High-impact onboarding gateway.
- **Visuals**: Hero banner featuring cyberpunk typography, subtitle pitch, and glow action buttons.
- **Actions**:
  - `Create Account` ➔ Navigates to `/create-account`.
  - `Log In` ➔ Navigates to `/login`.
  - `Quick Demo Login (Kaelen)` ➔ 1-tap demo auth bypassing credentials entry.

---

### 8.3 `LoginScreen` ([login_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/login_screen.dart))
- **Route**: `/login`
- **Purpose**: User credential authentication.
- **Visuals**: Email/username text field, obscured password field with visibility toggle, error banner.
- **Features**:
  - Validates inputs before dispatching `authProvider.login(login, password)`.
  - Quick Demo Chips: 1-tap authentication for demo users `kaelen_vr` or `nyx_9`.
  - `GoogleSignInButton`: Triggers Google OAuth.
  - Link to `/create-account`.

---

### 8.4 `CreateAccountScreen` ([create_account_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/create_account_screen.dart))
- **Route**: `/create-account`
- **Purpose**: New user registration.
- **Visuals**: Multi-field onboarding form: Username, Display Name, Email, Password, and Interactive Gamer Interests selector pills (`Gaming`, `VFX`, `Music`, `Tech`, `Art`, `Anime`).
- **State Logic**: Dispatches `authProvider.register(...)`. Upon success, backend automatically creates the user, hashes password with `bcryptjs`, auto-joins default community `s1` (Neon Arcade), and routes into `/servers`.

---

### 8.5 `MainChatScreen` ([main_chat_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/main_chat_screen.dart))
- **Route**: `/servers` (Branch 0 of bottom navigation shell)
- **Purpose**: The primary Discord-style hub of the platform.
- **Layout & Sub-Components**:
  1. **Server Icon Rail**: Vertical left bar listing joined community icons (`Neon Arcade`, `Synthwave Beats`, etc.) with active selection indicator and "+" button to discover/create servers.
  2. **Channel Drawer**: Expandable sidebar displaying server categories, text channels (`#welcome`, `#lounge`, `#gaming-clips`), voice channels (`Chill Beats [Voice]`), and server settings button.
  3. **Chat Message List**: Reverse-scroll message stream with user avatars, role badges (`OWNER`, `ADMIN`, `VIP`), timestamps, and media cards (video/clip player with custom duration labels).
  4. **Emoji Reaction Bar**: Displays aggregated emoji counts (`🔥 2`, `🤯 1`, `👑 1`) with active user highlight. Tapping toggles reaction in real time.
  5. **Active Voice Stage Banner**: Floating card at top of chat showing connected members in voice stage with 1-tap "Join Voice" action.
  6. **Message Input Dock**: Text field with media attachment picker, emoji tray button, and send action.
- **Navigation Shortcuts**: Top AppBar includes icon buttons to jump to `MemberListScreen` (`/servers/members`) and `VoiceChannelScreen` (`/servers/voice`).

---

### 8.6 `MemberListScreen` ([member_list_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/member_list_screen.dart))
- **Route**: `/servers/members` (Pushed over root navigator)
- **Purpose**: Community roster and user discovery.
- **Visuals**: Member list partitioned by hierarchy:
  - **OWNER** (Golden accent)
  - **ADMIN** (Purple accent)
  - **VIP** (Pink accent)
  - **MEMBERS & OFFLINE** (Muted accent)
- **Interactions**: Tapping any member opens an interactive modal bottom sheet displaying their avatar, online dot, bio, and custom status, along with a **"Direct Message"** button that navigates directly into `/messages/chat/:userId`.

---

### 8.7 `VoiceChannelScreen` ([voice_channel_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/voice_channel_screen.dart))
- **Route**: `/servers/voice` (Pushed over root navigator)
- **Purpose**: Spatial audio voice deck.
- **Visuals**: Interactive 2-column participant grid. Each participant card features:
  - User avatar with animated green pulsating halo when speaking (`is_speaking == 1`).
  - Mute indicator badge (`is_muted == 1`).
  - Screen share / streaming badge (`is_streaming == 1`).
  - Activity subtitle (e.g. *"Playing Sector 9"*, *"DJ Co-Host"*).
- **Controls Toolbar**:
  - **Mute / Unmute**: Toggles local microphone state and broadcasts via WebSocket.
  - **Deafen**: Toggles incoming audio state.
  - **Simulate Speaking**: Toggles speaking state broadcast to test green halo animation.
  - **Disconnect**: Leaves voice channel and pops back to chat screen.

---

### 8.8 `DmInboxScreen` ([dm_inbox_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/dm_inbox_screen.dart))
- **Route**: `/messages` (Branch 1 of bottom navigation shell)
- **Purpose**: Direct message inbox and friends hub.
- **Sections**:
  1. **Search Bar**: Filters active conversations and friends in real time.
  2. **Active Now Tray**: Horizontal scrollable row of online friends with pulsing mint status dots. Tapping an avatar immediately opens `/messages/chat/:userId`.
  3. **Direct Messages List**: Recent conversation tiles displaying partner avatar, username, snippet of latest message, formatted timestamp, and unread pill badge. Tapping any conversation navigates to `/messages/chat/:userId`.

---

### 8.9 `DmChatScreen` ([dm_chat_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/dm_chat_screen.dart))
- **Route**: `/messages/chat/:userId` (Pushed over root navigator)
- **Purpose**: Dedicated full-screen 1-on-1 private messaging screen.
- **Features**:
  - **AppBar**: Displays partner avatar, display name, online status indicator, and profile button.
  - **Thread Stream**: Message bubbles aligned right (sent by current user) and left (sent by partner), with timestamp grouping.
  - **Auto-Scroll Engine**: Automatically animates scroll position to bottom upon sending or receiving messages.
  - **Partner Profile Modal**: Tapping partner header opens rich profile bottom sheet with bio, status, and account stats.
  - **Instant Input**: Chat input field with immediate optimistic UI append.

---

### 8.10 `CommunityDiscoveryScreen` ([community_discovery_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/community_discovery_screen.dart))
- **Route**: `/discover` (Branch 2 of bottom navigation shell)
- **Purpose**: Explore public servers.
- **Visuals**:
  - **Category Pills**: Horizontal filter chips (`All`, `Gaming`, `Music`, `Anime & Art`, `Tech`, `Cozy`).
  - **Search Input**: Live query search against server names and descriptions.
  - **Server Cards**: High-gloss cards displaying server icon, name, level badge (`LVL 3`), member count, online member count, and a 1-tap **"Join Server"** action.
  - **Floating Action Button**: Launches `/discover/create` to create a new community.

---

### 8.11 `CreateCommunityScreen` ([create_community_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/create_community_screen.dart))
- **Route**: `/discover/create` (Pushed over root navigator)
- **Purpose**: Setup wizard for spinning up a new community.
- **Inputs**:
  - Community Name & Description text fields.
  - Category dropdown selector (`Gaming`, `Music`, `Tech`, etc.).
  - Neon Accent Color Picker (`#9D4EDD`, `#00F0FF`, `#FF007F`, `#FF6B35`, `#00FF66`).
  - Public / Private community toggle switch.
- **State Logic**: Invokes `serverProvider.createServer(...)`. Automatically creates channels (`#welcome`, `#lounge`, `#media-share`, `Lounge Voice`), sets current user as `OWNER`, and redirects to chat.

---

### 8.12 `NotificationsScreen` ([notifications_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/notifications_screen.dart))
- **Route**: `/activity` (Branch 3 of bottom navigation shell)
- **Purpose**: Real-time activity and alerts feed.
- **Visuals**:
  - Filter tabs: `All`, `Mentions` (`@`), `Reactions` (`🔥`), `Friends` (`👥`), `System` (`⚙️`).
  - Notification items with actor avatar, bold action summary, target channel, and time ago display.
  - Unread items marked with mint highlight border.
  - **"Mark All Read"** AppBar action that clears unread badges across the app.

---

### 8.13 `UserProfileScreen` ([user_profile_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/user_profile_screen.dart))
- **Route**: `/profile` (Branch 4 of bottom navigation shell)
- **Purpose**: User identity, status customization, and account overview.
- **Features**:
  - Profile header with large circular avatar, display name, `@username`, and online badge.
  - **Custom Status Editor**: Inline editable field (e.g. *"Playing Sector 9"*, *"Editing clips"*).
  - **Bio Card**: User's personalized bio.
  - **Joined Server Badges**: Horizontal badge row showing all servers the user belongs to.
  - **Account Statistics**: Member since date, total messages, voice hours.
  - Action buttons: Quick jump to `/profile/settings` and `/profile/theme`.

---

### 8.14 `SettingsScreen` ([settings_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/settings_screen.dart))
- **Route**: `/profile/settings` (Pushed over root navigator)
- **Purpose**: Diagnostics, networking preferences, and account controls.
- **Features**:
  - **Backend Diagnostics Section**: Shows current backend host address (`http://localhost:3000` or LAN IP).
  - **"Configure Backend" Button**: Opens the `ServerConfigDialog` modal to test connection pings and switch IPs.
  - **App Cache & Storage**: Option to clear cached images and local logs.
  - **Sign Out**: Clears session, disconnects sockets, and redirects to `/welcome`.

---

### 8.15 `CustomizeThemeScreen` ([customize_theme_screen.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/screens/customize_theme_screen.dart))
- **Route**: `/profile/theme` (Pushed over root navigator)
- **Purpose**: Visual theme customization.
- **Visuals**: Interactive theme presets showcasing:
  - **Obsidian Pulse** (Default deep black with neon purple & mint accents).
  - **Cyberpunk 2099** (Cyan & neon yellow electric palette).
  - **Midnight AMOLED** (Zero-contrast pure `#000000` pitch black).

---

## 9. Reusable Component & Widget Library

All shared widgets reside in `lib/widgets/`.

### 9.1 `ServerConfigDialog` ([lib/widgets/server_config_dialog.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/widgets/server_config_dialog.dart))
An indispensable developer & user diagnostic modal launched via `ServerConfigDialog.show(context)`:
- **Preset Chips**: 1-tap selectors for **Physical Phone (LAN Wi-Fi: `172.30.6.83:3000`)**, **Android Emulator (`10.0.2.2:3000`)**, and **Localhost (`localhost:3000`)**.
- **Custom Host Input**: Clean text input with auto-stripping of `http://`, `https://`, and `/api` prefixes.
- **Live Ping Diagnostic**: Dispatches an HTTP `GET /api/health` request and renders a live green checkmark with response time, or a red error warning if the host is unreachable.
- **Persistence**: Calling "Save & Apply" updates `SharedPreferences`, resets `SocketService` to reconnect to the new host, and displays a confirmation SnackBar.

### 9.2 `BottomNavShell` ([lib/widgets/bottom_nav_shell.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/widgets/bottom_nav_shell.dart))
A floating frosted glass navigation bar wrapping the `StatefulNavigationShell`:
- **Glassmorphism**: Built using `BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20))` and semi-transparent container background.
- **Tab Items**: 5 icons corresponding to the primary navigation branches (Servers, Messages, Discover, Activity, Profile).
- **Badge Engine**: Automatically watches `NotificationProvider.unreadCount` and renders a red badge dot over the Activity tab when unread items exist.

### 9.3 `GoogleSignInButton` ([lib/widgets/google_sign_in_button.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/widgets/google_sign_in_button.dart))
- Custom button strictly adhering to Google branding guidelines while maintaining the Obsidian dark aesthetic.
- Displays official multi-color Google 'G' logo, loading spinner during auth handshakes, and invokes `authProvider.signInWithGoogle()`.

### 9.4 `AppLogo` ([lib/widgets/app_logo.dart](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/lib/widgets/app_logo.dart))
- Reusable brand component rendering the stylized futuristic hexagonal Crew emblem.
- Supports arbitrary size parameters (`size: 28`, `size: 32`, `size: 64`) and rounded container clipping.

---

## 10. Multi-Device & Network Configuration Guide

Because The Crew is designed for mobile devices, the Flutter client must connect to the Node.js backend across various environments:

```
┌──────────────────────────────┬──────────────────────────────┬────────────────────────────────────────────┐
│ Target Platform              │ Recommended Backend URL      │ How to Configure                           │
├──────────────────────────────┼──────────────────────────────┼────────────────────────────────────────────┤
│ macOS Desktop App            │ http://localhost:3000        │ Default (Zero config needed)               │
│ Chrome Web                   │ http://localhost:3000        │ Default (Zero config needed)               │
│ iOS Simulator                │ http://localhost:3000        │ Default (Shares Mac loopback)              │
│ Android Emulator             │ http://10.0.2.2:3000         │ Select "Android Emulator" in Config Dialog │
│ Physical Device over Wi-Fi   │ http://172.30.6.83:3000      │ Select "Wi-Fi Preset" in Config Dialog     │
└──────────────────────────────┴──────────────────────────────┴────────────────────────────────────────────┘
```

### Passing Host at Build Time
You can permanently compile the client with a specific backend address without manual dialog configuration:

```bash
flutter run --dart-define=BACKEND_HOST=172.30.6.83:3000
```

### Reverse Port Forwarding for Android USB Debugging
If your physical Android phone is connected via USB with Developer Mode enabled:
```bash
adb reverse tcp:3000 tcp:3000
```
*This allows the physical phone to reach the backend using `localhost:3000` through the USB cable!*

---

## 11. Developer Onboarding, Build & Testing Guide

### 11.1 Prerequisites
- **Flutter SDK**: Version `^3.13.0`
- **Dart SDK**: Version `^3.13.0`
- **Xcode**: 15+ (for iOS and macOS desktop builds)
- **Android Studio / SDK**: Android API 33+ (for Android builds)

### 11.2 Setup Commands

```bash
# 1. Clone the repository and navigate to root
cd /path/to/The_crew_flutter_mini_project

# 2. Fetch all Dart dependencies
flutter pub get

# 3. Run Dart static analysis to ensure zero warnings or errors
flutter analyze

# 4. Run automated widget and unit tests
flutter test
```

### 11.3 Running on Different Targets

```bash
# Run on macOS desktop (Fastest development cycle)
flutter run -d macos

# Run in Google Chrome
flutter run -d chrome

# Run on an attached physical device or simulator
flutter run
```

### 11.4 Production Release Builds

```bash
# Build Android APK
flutter build apk --release

# Build Android App Bundle (for Google Play)
flutter build appbundle --release

# Build iOS IPA (Requires Xcode code signing)
flutter build ipa --release

# Build Web distribution (outputs to build/web/)
flutter build web --release
```

---

## 12. Troubleshooting & Best Practices

### 1. `SocketException: Connection refused (OS Error: Connection refused, errno = 111)`
- **Cause**: The Flutter client is attempting to reach `localhost:3000` from an Android emulator or physical device. `localhost` on a phone refers to the phone itself, not your development computer.
- **Fix**: Open `ServerConfigDialog` (accessible from the settings screen or welcome screen) and select the `10.0.2.2:3000` chip (for emulator) or your Wi-Fi LAN IP (e.g. `172.30.6.83:3000` for physical phone).

### 2. `RenderFlex overflowed by XX pixels`
- **Cause**: Keyboard emergence causing viewport shrink on input focus.
- **Fix**: All auth and chat screens wrap content in `SingleChildScrollView` or use `resizeToAvoidBottomInset: true` combined with `MediaQuery.of(context).viewInsets.bottom` padding.

### 3. Image Loading Failure / CORS on Flutter Web
- **Cause**: Loading external avatars or server icons on Flutter Web without CORS headers.
- **Fix**: The backend Express server has `app.use(cors())` enabled globally with `origin: '*'`.

### 4. iOS App Transport Security (ATS) Blocking Local HTTP
- **Cause**: iOS blocks unencrypted `http://` network requests by default.
- **Fix**: In `ios/Runner/Info.plist`, `NSAppTransportSecurity` contains `NSAllowsArbitraryLoads: true` for local development.
