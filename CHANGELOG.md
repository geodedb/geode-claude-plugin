# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-05-06

### Added

- Three subagents: `gql-query-writer`, `gql-debugger`, `graph-schema-designer`.
- Three progressive-disclosure skills: `gql-syntax-reference`, `gql-query-patterns`, `geode-mcp-tools`.
- Marketplace manifest in the `geode` monorepo so `claude plugin marketplace add ./geode` works.
- Minimum-version gate (`v0.5.11`) in `hooks/check-geode.sh`.
- Documentation for DSN connection strings, mTLS, and audit logging.
- New examples: authenticated DSN, cosine vector search, migration signing, backup/restore.

### Changed

- `.mcp.json` now launches `geode mcp --stdio` explicitly (was `mcp serve`).
- `commands/status.md` rewritten against `geode v0.5.11` CLI surface.
- `commands/mcp-status.md` corrected: `--port` (no `--http`), `-e host:port` (no scheme prefix).
- `commands/syntax.md` adds transactions, `--` comments, expanded vector metrics, DSN section.
- `commands/query.md` adds `--page-size`, `--timeout`, `--retry`, `--graph`, transaction flags, mTLS.
- `README.md` rewritten: APT/Nix/Docker/source install paths; DSN + auth + audit; updated structure tree.

### Fixed

- Removed references to non-existent `session` and `authn` top-level subcommands.
- Removed false claim that `mcp serve` accepts `--http` and DSN-style endpoint URLs.
- Corrected `geode serve --log-level` choices to `debug|info|warn|error`.

## [2.0.0] - 2026-01-26

Initial release with MCP support and resolved gaps.
