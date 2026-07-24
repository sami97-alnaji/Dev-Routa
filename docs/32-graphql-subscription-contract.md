# GraphQL subscription contract

The supported WebSocket protocol is `graphql-transport-ws`. The transport implements subprotocol negotiation, connection initialization, acknowledgement timeout, subscribe, next, error, complete, ping/pong, stop, and disconnect. Each connection owns one operation and exposes a typed event stream.

Status: COMPLETE. Bounded reconnect/resubscription, timeline controls, runtime-secret isolation, and lifecycle coverage are implemented; see [the repository closure](37-phase4-repository-closure.md).
