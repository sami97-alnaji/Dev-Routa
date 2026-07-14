# Realtime storage and retention policy

Schema version 3 adds `realtime_configurations`, `realtime_drafts`, `realtime_history`, and `ai_preferences`. It upgrades schema version 2 without deleting prior data. Realtime configurations store non-secret metadata only; secret fields store secure-storage references and never their values.

History stores redacted event summaries, optional pin/tags/notes metadata, and never raw binary bytes. Repository retention supports maximum-count and age cleanup. The history browser and user-configurable retention controls are still pending.
