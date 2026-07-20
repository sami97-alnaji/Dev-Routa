# WebSocket contract

Supported schemes are `ws` and `wss`. The adapter supports enabled headers and query parameters, Bearer/Basic/API-key auth through secure references, environments, subprotocols, connection timeout, bounded manual/automatic reconnect, text/formatted-JSON/binary-file send, text/binary receive, cancellation, close-code classification, sequence/timestamp/direction/type/size metadata, bounded timeline, filters, sanitized clipboard/export, drafts, saved configurations, history, and independent tabs.

Binary data is transmitted from a supported local path but represented in UI/history as `[binary payload not retained]`. TLS verification remains the platform default and cannot be silently disabled. No automatic application-level ping is sent because ping behavior is server/protocol-specific; reconnect remains explicitly bounded.
