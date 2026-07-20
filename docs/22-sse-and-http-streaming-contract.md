# SSE and HTTP streaming contract

SSE accepts HTTP(S) GET streams, sends `Accept: text/event-stream`, supports headers/auth/environments and `Last-Event-ID`, parses event/data/id/retry/comment fields across arbitrary UTF-8 chunks, preserves multi-line data, reports malformed retry values and heartbeat comments, applies server retry guidance to bounded reconnect, and supports stop/reconnect/search/filter/sanitized JSON or JSONL export. SSE is receive-only and never exposes a composer.

Generic HTTP streaming supports HTTP(S), configured method/headers/auth/body/environment resolution, production mutation confirmation, raw UTF-8 chunks, line-delimited text, and NDJSON/JSON Lines. Incremental decoding preserves code points split across network chunks; malformed NDJSON lines become diagnostics. Updates are batched, memory is bounded with visible dropped counts, and completion, failure, cancellation, history, and sanitized exports are distinct and tested with local servers.
