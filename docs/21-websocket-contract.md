# WebSocket contract

Supported schemes are `ws` and `wss`. The adapter supports headers, query parameters, subprotocols, connection timeout, bounded reconnect policy, text/JSON send, binary send, text/binary receive, cancellation, manual disconnect, sequence/timestamp/direction/type/size metadata, bounded timeline, search, and sanitized persistence.

Binary data is transmitted when requested but represented in UI/history as `[binary payload not retained]`. Ping policy, binary file picker, independent desktop session tabs, and a saved-configuration picker are not yet implemented.
