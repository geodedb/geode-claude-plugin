---
name: geode-mcp-tools
description: Use when deciding which Geode MCP tool to call (validate vs diagnostics, query vs explain, schema vs catalogs/graphs) or when chaining tools to answer a graph question. Loaded on demand.
---

# Geode MCP Tools — Practical Guide

The Geode MCP server exposes 9 tools. They split into two groups:

| Group | Tools | Needs server? |
|-------|-------|---------------|
| Server-backed | `query`, `schema`, `explain`, `catalogs`, `graphs` | Yes (a running `geode serve`) |
| LSP-backed (offline) | `validate`, `complete`, `hover`, `diagnostics` | No |

## Tool selection cheatsheet

- **"Is this query syntactically valid?"** → `validate`. No server needed.
- **"Show me everything wrong with this query."** → `diagnostics` (alias of `validate`, returns the same shape but Claude tends to prefer `diagnostics` semantically when the user said "diagnose").
- **"Run it."** → `query`. Always check `validate` first if the cost of failure is high.
- **"How would the engine run this?"** → `explain`. Returns the logical operator tree only.
- **"What labels and properties exist?"** → `schema`.
- **"What graphs are in catalog X?"** → `graphs` (with `catalog`).
- **"What catalogs are there?"** → `catalogs`.
- **"What can I type next here?"** → `complete` with `query`/`line`/`column`.
- **"What does this token mean?"** → `hover` with `query`/`line`/`column`.

## Common chains

### "Is this query safe to run?"

1. `validate` — bail if errors.
2. `explain` — bail if the plan does an `AllNodesScan` larger than the user accepts.
3. `query` — execute.

### "Author a query against an unknown DB."

1. `catalogs` → pick one (default `default`).
2. `graphs` (with `catalog`) → pick one.
3. `schema` → see labels and relationships.
4. Compose query, `validate`, then `query`.

### "Why is this slow?"

1. `explain` — inspect the plan; flag full scans, large cartesian, unbounded variable-length paths.
2. If still mysterious, run with `PROFILE` from a CLI to get per-operator metrics (MCP `query` does not expose `PROFILE` output by default).

## Resources

| URI | Use |
|-----|-----|
| `geode://default/default/schema` | Snapshot of the schema for the default catalog/graph |
| `geode://default/default/stats`  | Node/relationship/index counts |
| `geode://config`                 | Server version + GQL conformance |

Templates exist for arbitrary `{catalog}/{graph}/{node|relationship}` URIs.

## Prompts

7 query-template prompts: `find_nodes`, `find_relationships`, `create_node`, `create_relationship`, `shortest_path`, `graph_analysis`, `pattern_match`. Use these when you want a starting query that the user will edit, not when you want a final answer.

## Error patterns

- `Error: Failed to initialize client` — server unreachable. Confirm `geode serve` is running and the endpoint matches.
- `Error: AuthenticationFailed` — the MCP server's bearer token is set but the client did not present it. Configure `GEODE_MCP_TOKEN` or run with `auth_mode=none` for local dev only.
- `validate` returning empty `diagnostics` array means the query parses cleanly — that is success, not "no information".
