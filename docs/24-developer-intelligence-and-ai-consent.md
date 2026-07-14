# Developer intelligence and AI consent

The deterministic local diagnostics engine distinguishes observed facts from suggestions for unresolved variables, duplicate auth, response status, slow/large responses, connection failures, reconnects, and SSE heartbeat absence.

External AI is disabled by default. `ConsentAiService` builds an exact redacted preview only after explicit consent; bodies, headers, history, and events are independently opt-in and pass through secret redaction. `FakeAiProvider` supports deterministic tests. No real provider is configured, no provider key is stored in SQLite, and no analysis runs automatically.
