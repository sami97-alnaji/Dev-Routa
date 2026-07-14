# SSE and HTTP streaming contract

SSE accepts HTTP(S) GET streams, sends `Accept: text/event-stream`, supports `Last-Event-ID`, parses event/data/id/retry/comment fields, preserves multi-line data, exposes heartbeat diagnostics, and has bounded reconnect through the shared session policy. SSE is receive-only.

Generic HTTP streaming supports HTTP(S), configured method/headers/body, raw UTF-8 chunks, cancellation, and bounded retained chunks. The standalone NDJSON decoder is tested. UI selection between raw/line/NDJSON views and a local integration server suite remain pending.
