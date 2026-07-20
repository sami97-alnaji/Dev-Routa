# DevRoute AI Studio

DevRoute AI Studio is a local-first Flutter workspace for designing, executing,
debugging, and monitoring APIs. It combines a focused REST workflow with
realtime protocol tooling, local diagnostics, and optional AI assistance that
is always consent-gated.

## Status

- Phase 2: Complete
- Phase 3: Complete
- Repository closure: Complete
- Current milestone: v0.3.0-alpha.1

This is a validated alpha development milestone, not a final production release.

## Capabilities

### Phase 2: REST and local workspaces

- Local workspaces, collections, nested folders, saved requests, drafts, and
  history with search, move, duplicate, reorder, replay, and retention.
- REST requests using GET, POST, PUT, PATCH, DELETE, HEAD, and OPTIONS.
- Query parameters, headers, auth, JSON/raw/form/multipart/binary bodies,
  response inspection, cancellation, and byte-bounded Unicode-safe previews.
- Environments, variable resolution, secret references, production mutation
  confirmation, safe exports, and redacted diagnostics.

### Phase 3: realtime and developer intelligence

- WebSocket connections with isolated sessions, reconnect/backoff, history,
  comparison, and local echo/abnormal-close coverage.
- SSE and HTTP streaming with raw, line, and NDJSON modes, incremental UTF-8
  decoding, bounded retention, filters, cancellation, and exports.
- Local diagnostics plus optional AI analysis. AI is disabled by default and
  requires explicit, reversible consent with a redacted payload preview.

## Platforms and stack

Windows and Android are validated targets. The app uses Flutter and Dart,
flutter_bloc, go_router, Dio, Drift/SQLite, and flutter_secure_storage. Its
feature-based Clean Architecture keeps widgets focused on presentation while
repositories, services, and Cubits own persistence, protocol, and workflow
logic.

Local data is stored in SQLite. Secret values are never stored there: records
keep secure-storage references only. Headers, cookies, exports, histories,
diagnostics, and AI previews are redacted. Do not commit tokens, credentials,
certificates, `.env` files, or local databases.

## Setup and validation

```powershell
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run -d windows
flutter run -d android
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build windows --debug
flutter build apk --debug
```

Use a Windows device target for the desktop command and a connected emulator or
device for Android. The Android artifact is written to
`build/app/outputs/flutter-apk/app-debug.apk`; the Windows runner is under
`build/windows/x64/runner/Debug`.

## Repository layout

```text
lib/core/       transport, storage, security, diagnostics, and shared utilities
lib/features/   workspace, request, history, environment, realtime, and AI UI
lib/shared/     protocol models, service contracts, and reusable components
test/           deterministic local-server, migration, protocol, and widget tests
docs/           product, architecture, phase, protocol, and closure documentation
```

## Protocol support and intentional exclusions

REST, WebSocket, SSE, and HTTP streaming are supported. GraphQL, gRPC, SOAP,
MQTT, Socket.IO, cloud sync, accounts, teams, billing, public mock servers,
traffic proxies, and real hosted AI providers are intentionally deferred.

## Development workflow

Create a feature branch, run code generation and the validation commands above,
then open a pull request to `main`. CI repeats format, generated-code, analyze,
test, Android debug-build, and Windows debug-build checks. Contributions must
keep secrets out of Git and retain explicit consent before any real AI provider
receives data or credentials.

## Further documentation

- [Phase 2 closure audit](docs/18-phase2-final-closure-audit.md)
- [Phase 3 execution plan](docs/19-phase3-execution-plan.md)
- [Realtime architecture](docs/20-realtime-architecture.md)
- [WebSocket contract](docs/21-websocket-contract.md)
- [SSE and HTTP streaming contract](docs/22-sse-and-http-streaming-contract.md)
- [Storage and retention policy](docs/23-realtime-storage-and-retention-policy.md)
- [AI consent model](docs/24-developer-intelligence-and-ai-consent.md)
- [Phase 3 test plan](docs/25-phase3-test-plan.md)
- [Phase 3 completion report](docs/26-phase3-completion-report.md)
- [Repository closure](docs/27-phase2-phase3-repository-closure.md)
