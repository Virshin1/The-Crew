# The Crew 🚀🎮

> A full-stack, Discord-inspired cyberpunk community mobile platform built with **Flutter** and powered by a real-time **Node.js & Socket.io** backend with a pluggable dual database engine (**SQLite** & **Google Cloud Firestore**).

---

## 📚 Comprehensive Documentation

The project includes two exhaustive, dedicated technical guides covering every tier of the platform:

| Document | Focus Area | Description |
| :--- | :--- | :--- |
| 📱 **[FRONTEND.md](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/FRONTEND.md)** | Flutter Client | Complete architecture, Obsidian Pulse design system, `go_router` navigation tree, Provider state management, Socket.io client sync, multi-device LAN IP configuration, and screen-by-screen catalog. |
| ⚡ **[BACKEND.md](file:///Users/virshin/Downloads/The_crew_flutter_mini_project/BACKEND.md)** | Node.js & Socket.io Server | Dual database engine (SQLite / Cloud Firestore), relational schema & ERD, JWT & OAuth auth flow, complete REST API endpoint reference, and WebSocket event contracts. |

---

## ✨ Key Features

- **Text Chat Channels**: Real-time messaging, multi-user typing indicators, message deduplication, and media attachments.
- **Interactive Emoji Reactions**: Real-time reaction counts and optimistic UI updates via WebSockets.
- **Spatial Audio Voice Stages**: Live participant rosters, active speaker halos, mute/unmute, and deafen controls.
- **Direct Messaging (DMs)**: Dedicated full-screen 1-on-1 real-time chat (`DmChatScreen`), "Active Now" online presence, and unread badge counters.
- **Community Discovery & Server Creation**: Browse servers by categories (Gaming, Music, Art, Tech, Cozy) or spin up your own community.
- **Role Hierarchy**: Grouped permissions and styling for `OWNER`, `ADMIN`, `VIP`, and `MEMBER`.
- **Activity & Notification Feed**: Filterable alerts for mentions, reactions, friend requests, and system events.
- **Dynamic Network Connectivity**: Switch backend hosts on physical devices on the fly via the in-app server selector dialog.
- **Dual Database Support**: Zero-config local SQLite with WAL mode for development, and live Google Cloud Firestore integration (`the-crew-4da98`) with 127 records pre-migrated.

---

## 🚀 Quick Start

### 1. Launch the Backend Server

```bash
cd backend
npm install
npm run dev
```
*The server will start at `http://localhost:3000` with WebSocket endpoint ready and auto-seed the SQLite database with mock cyber communities and users.*

Verify health:
```bash
curl http://localhost:3000/api/health
```

### 2. Launch the Flutter Client

In a separate terminal:
```bash
flutter pub get

# Run on macOS desktop
flutter run -d macos

# Or run on Chrome
flutter run -d chrome

# Or run on a connected mobile device with LAN host override
flutter run --dart-define=BACKEND_HOST=172.30.6.83:3000
```

---

## 🧪 Quick Demo Credentials

You can use the built-in **1-Tap Quick Demo Login** on the login screen, or sign in manually:

- **Username**: `kaelen_vr` (or `nyx_9`)
- **Password**: `password123`

---

## 📁 Repository Structure

```
The_crew_flutter_mini_project/
├── FRONTEND.md                 # Exhaustive Flutter client guide
├── BACKEND.md                  # Exhaustive Node.js & Socket.io server guide
├── README.md                   # Project overview & quickstart
├── pubspec.yaml                # Flutter dependencies & assets
├── lib/                        # Flutter application source code
│   ├── main.dart               # App entrypoint & MultiProvider setup
│   ├── models/                 # Dart data models (User, Server, Message, etc.)
│   ├── providers/              # State management (Auth, Server, Chat, Dm, Voice)
│   ├── router/                 # GoRouter navigation & StatefulShellRoute
│   ├── screens/                # 15 UI screens (including DmChatScreen)
│   ├── services/               # ApiService, SocketService, AuthService
│   ├── theme/                  # Obsidian Pulse design system tokens
│   └── widgets/                # Reusable UI components & dialogs
└── backend/                    # Node.js & Socket.io server
    ├── package.json            # Server scripts & dependencies
    ├── database.sqlite         # Local SQLite database (WAL mode)
    ├── test_integration.js     # End-to-end integration test runner
    └── src/
        ├── server.js           # Server bootstrap & socket initialization
        ├── config.js           # Environment configuration
        ├── db.js               # SQLite driver & schema definition
        ├── db_firestore.js     # Google Cloud Firestore adapter
        ├── firebase.js         # Firebase Admin SDK initializer
        ├── seed.js             # Demo cyber dataset seeder
        ├── middleware/         # JWT authentication middleware
        ├── routes/             # REST API controllers
        └── sockets/            # Socket.io event dispatchers
```
