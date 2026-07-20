# Phase 2 verified test plan

The final Phase 2 suite contains 26 passing tests across pure services, migrations, repositories, deterministic local HTTP, draft state, safe export, and responsive widgets.

Migration coverage upgrades database versions 1, 2, and 3 to version 4 and verifies retained rows. Repository coverage exercises CRUD, nesting, duplicate/move/search/order, cascade cleanup, secure-reference ownership, environments, history, replay, and retention. HTTP tests use loopback-only servers for JSON, multipart, API-key query, runtime environment variables, and reflected-secret history redaction. Widget tests cover the desktop REST editor, Android unsaved-back confirmation, and desktop environment-variable editing.

The release gate runs format, dependency resolution, Drift generation, static analysis, all tests, Windows debug build, Android debug build, and `git diff --check`.
