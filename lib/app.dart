import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/workspace/presentation/app_shell.dart';

class DevRouteApp extends StatelessWidget {
  const DevRouteApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const AppShell()),
      GoRoute(
        path: '/request',
        builder: (context, state) => const AppShell(initialSection: 1),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const AppShell(initialSection: 2),
      ),
      GoRoute(
        path: '/environments',
        builder: (context, state) => const AppShell(initialSection: 3),
      ),
      GoRoute(
        path: '/ai',
        builder: (context, state) => const AppShell(initialSection: 4),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const AppShell(initialSection: 5),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'DevRoute AI Studio',
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.dark,
    routerConfig: _router,
  );
}
