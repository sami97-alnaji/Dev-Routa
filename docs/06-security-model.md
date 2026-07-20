# Security model

- API keys, bearer tokens, Basic-auth passwords, and secret environment variables never enter SQLite as plaintext.
- Secure storage is accessed only through `SecureStorageService`.
- UI should mask secret values by default; logs must redact authorization, cookies, passwords, and tokens.
- AI analysis requires explicit user consent before request/response data can be shared.
- History must support clearing and later exclusion of sensitive requests.

Phase 2 masks Authorization, Cookie, token, password, and API-key values in diagnostics, cURL export, history snapshots, and generated bug reports. Tokens detected in JSON are suggestions only and are never automatically saved.
## Phase 4 security

GraphQL errors, diagnostics, schema snapshots, exports, and subscription events must redact runtime secrets. Introspection is explicit, TLS verification remains enabled, and external AI remains disabled by default.
