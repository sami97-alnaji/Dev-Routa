# Phase 2 gap audit

> Historical baseline audit. All listed Phase 2 gaps were closed and reverified
> in `docs/18-phase2-final-closure-audit.md` on 2026-07-14.

## Baseline verified on 2026-07-14

- Repository: `main`, clean before Phase 2 work.
- Flutter 3.41.8 / Dart 3.11.5.
- `flutter pub get`, `flutter analyze`, and `flutter test` passed before changes.

## Verified complete

- Flutter Windows and Android targets, theme, routing shell, and feature-folder foundation.
- Dio, Drift, and secure-storage dependencies are present.
- The initial Drift schema, secure-storage adapter, and a redaction helper exist.

## Partially implemented

- A Dio service sends a basic request but has no validation, settings, cancellation, authentication, variable resolution, history write, or typed failure mapping.
- The schema names core entities but has no CRUD repository, ordering, cascade policy, request settings, drafts, or history policy.
- The shell adapts between rail and bottom navigation but has only a URL/method form and an inline response text view.

## Placeholder only

- Collections, environments, history, responses, settings, and AI screens.
- All feature `data` and `domain` folders other than their README placeholders.
- Workspace persistence, saved requests, request tabs/drafts, response viewer, cURL tools, token capture, production safety, and bug reports.

## Out of Phase 2 scope

- WebSocket, SSE, GraphQL, gRPC, SOAP, MQTT, Socket.IO, cloud synchronization, accounts, billing, marketplace, mock server, scenario runner, CI runner, and external AI providers.

## Delivery decision

Phase 2 replaces the live request path with Cubit-to-use-case-to-repository composition. SQLite/Drift owns non-secret metadata and secure storage owns secret values. The first migration is versioned so existing Phase 1 installations can upgrade safely.
