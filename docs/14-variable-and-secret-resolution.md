# Variable and secret resolution

Syntax is `{{name}}`. Resolution precedence is Runtime > Request > Environment > Defaults. Nested values resolve recursively; unresolved names and cycles are returned as diagnostics rather than silently replaced.

Secret values are read only at execution time from platform secure storage. SQLite stores the secret reference, never the secret value. Resolved previews are masked when secret-derived; history, cURL export, error messages, and bug reports redact sensitive headers by default.
