import 'package:devroute_ai_studio/features/graphql/data/graphql_subscription_transport.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'subscription transport rejects non-WebSocket endpoints before connecting',
    () async {
      await expectLater(
        GraphqlSubscriptionTransport().connect(
          endpoint: 'https://example.test/graphql',
          document: 'subscription Updates { update }',
        ),
        throwsA(
          isA<GraphqlFailure>().having(
            (failure) => failure.category,
            'category',
            GraphqlFailureCategory.validation,
          ),
        ),
      );
    },
  );
}
