import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/create_account_screen.dart';
import '../screens/main_chat_screen.dart';
import '../screens/community_discovery_screen.dart';
import '../screens/dm_inbox_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/voice_channel_screen.dart';
import '../screens/member_list_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/create_community_screen.dart';
import '../screens/customize_theme_screen.dart';
import '../screens/dm_chat_screen.dart';
import '../widgets/bottom_nav_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // Splash & Auth flow
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/create-account',
      builder: (context, state) => const CreateAccountScreen(),
    ),
    // Main app with bottom nav
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/servers',
              builder: (context, state) => const MainChatScreen(),
              routes: [
                GoRoute(
                  path: 'members',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const MemberListScreen(),
                ),
                GoRoute(
                  path: 'voice',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const VoiceChannelScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/messages',
              builder: (context, state) => const DmInboxScreen(),
              routes: [
                GoRoute(
                  path: 'chat/:userId',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final userId = state.pathParameters['userId'] ?? '';
                    return DmChatScreen(partnerId: userId);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/discover',
              builder: (context, state) => const CommunityDiscoveryScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CreateCommunityScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/activity',
              builder: (context, state) => const NotificationsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const UserProfileScreen(),
              routes: [
                GoRoute(
                  path: 'settings',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'theme',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CustomizeThemeScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
