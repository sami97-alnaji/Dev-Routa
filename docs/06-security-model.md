# Security model

- API keys, bearer tokens, Basic-auth passwords, and secret environment variables never enter SQLite as plaintext.
- Secure storage is accessed only through `SecureStorageService`.
- UI should mask secret values by default; logs must redact authorization, cookies, passwords, and tokens.
- AI analysis requires explicit user consent before request/response data can be shared.
- History must support clearing and later exclusion of sensitive requests.
