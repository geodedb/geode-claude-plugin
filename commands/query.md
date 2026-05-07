---
description: Help write or debug a GQL query
---

# GQL Query Assistant

Help the user write, debug, or optimize a GQL query.

User's request: "$ARGUMENTS"

## Triage

1. **Writing a new query**: ask about
   - desired output and shape
   - node labels / relationship types
   - filters
   - sort + pagination
2. **Debugging**: scan for
   - missing `RETURN`
   - bracket / parenthesis mismatch
   - type mismatch in `WHERE`
   - missing string quotes
   - variables defined in `MATCH` but unused / shadowed in `RETURN`
   - unclosed `BEGIN` (no `COMMIT` / `ROLLBACK`)
3. **Optimizing**:
   - add indexes for hot filter properties
   - filter early (`WHERE` before `WITH`)
   - use parameters (`$param`) instead of inline values
   - `EXPLAIN` for the logical plan
   - `PROFILE` for per-operator timing + memory

## Connecting to Geode

Clients use a unified DSN format:

```text
quic://localhost:3141                        # QUIC, default
grpc://localhost:50051                       # gRPC
quic://user:pass@geode.example.com:3141      # With credentials
quic://localhost:3141?page_size=500          # With options
localhost:3141                               # Bare host:port — defaults to QUIC
```

| Protocol | Default Port | TLS | Notes |
|----------|--------------|-----|-------|
| QUIC | 3141 | Required (TLS 1.3) | High-performance UDP transport |
| gRPC | 50051 | Optional | Standard HTTP/2 |

## CLI Query Flags (`geode query`)

```text
--dsn <dsn>                Connection DSN (overrides --server / --grpc)
--server <addr:port>       Server address (default 127.0.0.1:3141)
--grpc                     Use gRPC transport
-g, --graph <name>         Auto-prepend USE GRAPH <name>
-f, --file <path>          Execute statements from a file
--format <fmt>             json | table | csv | dot (default: json)
--param <name> <value>     Add a query parameter (JSON literal); repeatable
--page-size <n>            Result page size (default: 128)
--timeout <secs>           Connection timeout (default: 30)
--retry <count>            Retry attempts on failure (default: 0)
--begin / --commit / --rollback  Transaction control
-U, --user / -P, --password      Authenticate with username + password
--no-saved-session         Don't auto-load saved session token
--insecure-tls-skip-verify Skip TLS verification (development only)
--ca-cert / --client-cert / --client-key  mTLS material
```

## Transactions

```gql
BEGIN
-- multiple statements here
COMMIT      -- or ROLLBACK to abort
```

## Query Analysis

```gql
EXPLAIN
MATCH (p:Person)-[:KNOWS]->(f:Person)
RETURN p.name, f.name
```

`PROFILE` runs the query and returns per-operator metrics: rows in/out, wall clock, allocation, spill.

## GQL vs Cypher Differences

Geode implements ISO GQL (ISO/IEC 39075:2024) with Cypher compatibility:

- `MATCH`, `CREATE`, `RETURN` — same as Cypher
- Use `TRUE` / `FALSE` (uppercase)
- String concatenation with `||`
- Comments: `//`, `/* */`, plus `--` (Geode extension)

Provide working code examples and explain the syntax.
