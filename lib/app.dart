import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/network/dio_request_execution_service.dart';
import 'core/agent_control/application/agent_orchestrator.dart';
import 'core/agent_control/application/agent_permission_engine.dart';
import 'core/agent_control/application/app_command_bus.dart';
import 'core/agent_control/data/codex_subscription_adapter.dart';
import 'core/agent_control/domain/agent_models.dart';
import 'core/security/flutter_secure_storage_service.dart';
import 'core/storage/database_schema.dart';
import 'core/storage/local_workspace_repository.dart';
import 'core/theme/app_theme.dart';
import 'features/requests/presentation/request_workflow_cubit.dart';
import 'features/realtime/data/realtime_repository.dart';
import 'features/realtime/data/realtime_transport.dart';
import 'features/graphql/data/graphql_repository.dart';
import 'features/graphql/data/graphql_http_service.dart';
import 'features/graphql/data/graphql_introspection_service.dart';
import 'features/graphql/application/graphql_execution_service.dart';
import 'features/graphql/application/graphql_request_resolver.dart';
import 'features/graphql/application/graphql_subscription_service.dart';
import 'features/realtime/presentation/realtime_session_cubit.dart';
import 'features/workspace/presentation/app_shell.dart';
import 'features/workspace/presentation/workspace_cubit.dart';
import 'features/grpc/data/grpc_persistence_repository.dart';
import 'features/ai_assistant/application/codex_agents_controller.dart';

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
          GoRoute(
            path: '/ai-agents',
            builder: (context, state) => const AppShell(initialSection: 8),
          ),
          GoRoute(
            path: '/grpc',
            builder: (context, state) => const AppShell(initialSection: 7),
          ),
        ],
      );

  final AppDatabase _database;
  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    final secureStorage = FlutterSecureStorageService();
    final repository = LocalWorkspaceRepository(_database, secureStorage);
    final commandBus = AppCommandBus();
    final bindings = CodexAgentCommandBindings(
      commandBus,
      GrpcPersistenceRepository(_database),
    )..register();
    final codexController = CodexAgentsController(
      CodexSubscriptionAdapter(
        orchestratorForWorkspace: (workspaceId) => AgentOrchestrator(
          bindings.registry(workspaceId),
          AgentPermissionEngine(),
          InMemoryAgentAuditSink(),
        ),
      ),
    );
    return RepositoryProvider<LocalWorkspaceRepository>(
      create: (_) => repository,
      child: RepositoryProvider<CodexAgentsService>.value(
        value: CodexAgentsService(codexController),
        child: MultiBlocProvider(
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
                resolver: GraphqlRequestResolver(
                  context.read<GraphqlRepository>(),
                  secureStorage: secureStorage,
                ),
              ),
              child: RepositoryProvider<GraphqlIntrospectionService>(
                create: (_) => GraphqlIntrospectionService(
                  GraphqlHttpService(secureStorage: secureStorage),
                ),
                child: RepositoryProvider<GraphqlSubscriptionService>(
                  create: (context) => GraphqlSubscriptionService(
                    resolver: GraphqlRequestResolver(
                      context.read<GraphqlRepository>(),
                      secureStorage: secureStorage,
                    ),
                  ),
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
          ),
        ),
      ),
    );
  }
}
