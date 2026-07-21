import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/network/dio_request_execution_service.dart';
import 'core/security/flutter_secure_storage_service.dart';
import 'core/storage/database_schema.dart';
import 'core/storage/local_workspace_repository.dart';
import 'core/theme/app_theme.dart';
import 'features/requests/presentation/request_workflow_cubit.dart';
import 'features/realtime/data/realtime_repository.dart';
import 'features/realtime/data/realtime_transport.dart';
import 'features/graphql/data/graphql_repository.dart';
import 'features/graphql/data/graphql_http_service.dart';
import 'features/graphql/application/graphql_execution_service.dart';
import 'features/graphql/application/graphql_subscription_service.dart';
import 'features/realtime/presentation/realtime_session_cubit.dart';
import 'features/workspace/presentation/app_shell.dart';
import 'features/workspace/presentation/workspace_cubit.dart';

class DevRouteApp extends StatelessWidget {
  DevRouteApp({super.key, AppDatabase? database})
    : _database = database ?? AppDatabase(),
      _router = GoRouter(
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
            path: '/settings',
            builder: (context, state) => const AppShell(initialSection: 4),
          ),
          GoRoute(
            path: '/realtime',
            builder: (context, state) => const AppShell(initialSection: 5),
          ),
          GoRoute(
            path: '/graphql',
            builder: (context, state) => const AppShell(initialSection: 6),
          ),
        ],
      );

  final AppDatabase _database;
  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    final secureStorage = FlutterSecureStorageService();
    final repository = LocalWorkspaceRepository(_database, secureStorage);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => RequestWorkflowCubit(
            DioRequestExecutionService(secureStorage: secureStorage),
            repository,
          )..restoreDrafts(),
        ),
        BlocProvider(create: (_) => WorkspaceCubit(repository)..load()),
        BlocProvider(
          create: (_) => RealtimeSessionCubit(
            RealtimeTransport(),
            RealtimeRepository(_database),
            secureStorage: secureStorage,
          ),
        ),
      ],
      child: RepositoryProvider<GraphqlRepository>(
        create: (_) =>
            GraphqlRepository(_database, secureStorage: secureStorage),
        child: RepositoryProvider<GraphqlExecutionService>(
          create: (context) => GraphqlExecutionService(
            GraphqlHttpService(secureStorage: secureStorage),
            context.read<GraphqlRepository>(),
          ),
          child: RepositoryProvider<GraphqlSubscriptionService>(
            create: (_) => GraphqlSubscriptionService(),
            child: MaterialApp.router(
              title: 'DevRoute AI Studio',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: ThemeMode.dark,
              routerConfig: _router,
            ),
          ),
        ),
      ),
    );
  }
}
