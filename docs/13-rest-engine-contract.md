# REST engine contract

The UI dispatches to `RequestWorkflowCubit`; the Cubit validates then delegates only to `DioRequestExecutionService`. The engine uses `validateStatus: (_) => true`, so all non-2xx HTTP responses are normal responses rather than transport failures.

Before execution the workflow validates HTTP(S) URLs and JSON. Dio applies method, headers, body, redirects, timeouts, and a cancellable token. Authentication reads secret references only through `SecureStorageService`. Failures map to `cancelled`, `timeout`, `tls`, `network`, `http`, or `unknown`, without exposing stack traces.

Responses include status, headers, timing, byte size, cookies, and a workspace-configurable bounded preview. Environment and secure-storage references resolve only immediately before execution. Known runtime secret values are removed from immutable history and safe exports even when a server reflects them.
