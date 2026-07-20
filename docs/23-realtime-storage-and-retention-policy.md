# Realtime storage and retention policy

Schema version 5 contains `realtime_configurations`, `realtime_drafts`, `realtime_history`, and `ai_preferences`. Migrations from supported versions 1, 2, 3, and 4 preserve existing data. Version 5 adds workspace/collection/request/environment/failure history filters, persisted realtime age/count retention, and non-secret AI provider metadata. Realtime configurations store secure-storage references, never resolved secret values.

History stores redacted event summaries, status/failure links, pin/tags/local notes, and never raw binary bytes. The browser supports protocol/workspace/status/failure/date/search filters, reopen-as-draft, deletion, clear, comparison, JSON/JSONL export, and persisted maximum-count plus age cleanup. Workspace deletion cascades through realtime configurations, drafts, history, and settings.
