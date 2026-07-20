# Developer intelligence and AI consent

The deterministic local diagnostics engine distinguishes observed facts from heuristic suggestions for invalid URLs, unresolved variables, duplicate/missing auth, secret exposure risk, HTTP status/network/timeout/TLS categories, content-type/JSON mismatch, slow/large responses, WebSocket close/reconnect failures, SSE malformed/stalled streams, and malformed NDJSON lines.

External AI is disabled by default and preferences are reversible/persisted locally. `ConsentAiService` builds an exact redacted preview only after explicit consent; bodies, headers, history, and events are independently opt-in and pass through secret redaction. Explain, error analysis, request-fix, realtime-summary, and test-idea actions never auto-run or auto-apply. Cancellation and safe errors are supported. `FakeAiProvider` supplies deterministic coverage because no external credential is available; no provider key is stored in SQLite and no real provider is called.
