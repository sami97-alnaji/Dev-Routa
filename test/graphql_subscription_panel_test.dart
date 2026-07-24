import 'package:devroute_ai_studio/features/graphql/application/graphql_subscription_service.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:devroute_ai_studio/features/graphql/presentation/graphql_subscription_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  GraphqlSubscriptionTabState timelineState({
    List<GraphqlTimelineEvent>? events,
    GraphqlSubscriptionPhase phase = GraphqlSubscriptionPhase.idle,
    int reconnectAttempts = 0,
    GraphqlFailure? error,
  }) => GraphqlSubscriptionTabState(
    phase: phase,
    events:
        events ??
        <GraphqlTimelineEvent>[
          GraphqlTimelineEvent(
            sequence: 1,
            receivedAt: DateTime.utc(2026, 7, 21, 9),
            data: const <String, Object?>{
              'message': 'first',
              'authorization': 'Bearer reflected-secret',
              'nested': <String, Object?>{'access_token': 'nested-secret'},
            },
          ),
          GraphqlTimelineEvent(
            sequence: 2,
            receivedAt: DateTime.utc(2026, 7, 21, 9, 1),
            data: const <String, Object?>{'message': 'second'},
            errors: const <GraphqlResponseError>[
              GraphqlResponseError(message: 'event failed'),
            ],
          ),
        ],
    reconnectAttempts: reconnectAttempts,
    error: error,
  );

  Widget subject({
    required GraphqlSubscriptionTabState state,
    GraphqlSubscriptionConnect? onConnect,
    Future<void> Function()? onDisconnect,
    Future<void> Function()? onReconnect,
    VoidCallback? onStop,
    VoidCallback? onClear,
  }) => MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 1100,
        height: 760,
        child: GraphqlSubscriptionPanel(
          key: const ValueKey<String>('subscription-panel'),
          tabId: 'tab-1',
          state: state,
          onConnect: onConnect ?? (_) async {},
          onDisconnect: onDisconnect ?? () async {},
          onReconnect: onReconnect ?? () async {},
          onStop: onStop ?? () {},
          onClear: onClear ?? () {},
        ),
      ),
    ),
  );

  testWidgets('passes bounded reconnect settings when connecting', (
    tester,
  ) async {
    GraphqlReconnectPolicy? captured;

    await tester.pumpWidget(
      subject(
        state: const GraphqlSubscriptionTabState(),
        onConnect: (policy) async => captured = policy,
      ),
    );

    await tester.tap(
      find.byKey(const Key('graphql-subscription-auto-reconnect')),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('graphql-subscription-auto-resubscribe')),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('graphql-subscription-max-attempts')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('5').last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('graphql-subscription-connect-toggle')),
    );
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.enabled, isTrue);
    expect(captured!.resubscribe, isTrue);
    expect(captured!.maxAttempts, 5);
  });

  testWidgets('searches and filters a sanitized bounded timeline', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(state: timelineState(phase: GraphqlSubscriptionPhase.active)),
    );

    final firstEvent = find.byKey(const Key('graphql-subscription-event-1'));
    final secondEvent = find.byKey(const Key('graphql-subscription-event-2'));

    expect(firstEvent, findsOneWidget);
    final firstEventText = tester.widget<SelectableText>(
      find.descendant(of: firstEvent, matching: find.byType(SelectableText)),
    );
    expect(firstEventText.data, contains('first'));
    expect(firstEventText.data, contains('[REDACTED]'));
    expect(firstEventText.data, isNot(contains('reflected-secret')));
    expect(firstEventText.data, isNot(contains('nested-secret')));

    await tester.enterText(
      find.byKey(const Key('graphql-subscription-search')),
      'second',
    );
    await tester.pumpAndSettle();

    expect(firstEvent, findsNothing);
    expect(secondEvent, findsOneWidget);
    final secondEventText = tester.widget<SelectableText>(
      find.descendant(of: secondEvent, matching: find.byType(SelectableText)),
    );
    expect(secondEventText.data, contains('second'));

    await tester.enterText(
      find.byKey(const Key('graphql-subscription-search')),
      '',
    );
    await tester.tap(find.byKey(const Key('graphql-subscription-errors-only')));
    await tester.pumpAndSettle();

    expect(firstEvent, findsNothing);
    expect(secondEvent, findsOneWidget);
  });

  testWidgets('exposes reconnect, stop, clear, and error state', (
    tester,
  ) async {
    var reconnectCalls = 0;
    var stopCalls = 0;
    var clearCalls = 0;

    await tester.pumpWidget(
      subject(
        state: timelineState(
          phase: GraphqlSubscriptionPhase.failed,
          reconnectAttempts: 2,
          error: const GraphqlFailure(
            GraphqlFailureCategory.protocol,
            'Socket closed.',
          ),
        ),
        onReconnect: () async => reconnectCalls++,
        onStop: () => stopCalls++,
        onClear: () => clearCalls++,
      ),
    );

    expect(find.text('Reconnects: 2'), findsOneWidget);
    expect(find.textContaining('Socket closed.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('graphql-subscription-reconnect')));
    await tester.pumpAndSettle();
    expect(reconnectCalls, 1);

    await tester.tap(find.byKey(const Key('graphql-subscription-clear')));
    await tester.pump();
    expect(clearCalls, 1);

    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const Key('graphql-subscription-stop')),
          )
          .onPressed,
      isNull,
    );
    expect(stopCalls, 0);
  });

  testWidgets('redacts a sensitive subscription error before rendering', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(
        state: timelineState(
          phase: GraphqlSubscriptionPhase.failed,
          error: const GraphqlFailure(
            GraphqlFailureCategory.graphql,
            'Subscription failed with token=private-value',
          ),
        ),
      ),
    );

    expect(find.textContaining('private-value'), findsNothing);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('graphql-subscription-error')))
          .data,
      contains('[REDACTED]'),
    );
  });
}
