---
description: Help write or debug a GQL query
---

# GQL Query Assistant

Help the user write, debug, or optimize their GQL query.

User's request: "$ARGUMENTS"

When helping with queries:

1. **If writing a new query**: Ask clarifying questions about:
   - What data they want to retrieve
   - Node labels and relationship types
   - Filter conditions needed
   - Sorting and pagination requirements

2. **If debugging**: Look for common issues:
   - Missing RETURN clause
   - Incorrect pattern syntax (parentheses, brackets)
   - Type mismatches in WHERE conditions
   - Missing quotes around strings
   - Variable scope issues (variables defined in MATCH used in RETURN)
   - Transaction not committed (missing COMMIT after BEGIN)

3. **If optimizing**: Suggest improvements:
   - Add indexes for frequently filtered properties
   - Use LIMIT to reduce result sets
   - Filter early with WHERE
   - Use parameters ($param) instead of inline values
   - Use EXPLAIN to inspect the query plan
   - Use PROFILE to measure per-operator performance

## Connecting to Geode

Clients connect using a DSN (Data Source Name) connection string:

```
quic://localhost:3141                            # QUIC transport (recommended)
grpc://localhost:50051                           # gRPC transport
quic://user:pass@geode.example.com:3141          # With authentication
quic://localhost:3141?page_size=500&tls=1         # With options
```

| Protocol | Default Port | TLS | Notes |
|----------|-------------|-----|-------|
| QUIC | 3141 | Required (TLS 1.3) | **Recommended** - high-performance UDP transport |
| gRPC | 50051 | Optional | Standard HTTP/2 based |

## Transaction Support

Geode supports full ACID transactions with Serializable Snapshot Isolation (SSI):

```gql
BEGIN
-- multiple statements here
COMMIT    -- or ROLLBACK to abort
```

## Query Analysis

Use `EXPLAIN` to see the logical query plan without executing:
```gql
EXPLAIN
MATCH (p:Person)-[:KNOWS]->(f:Person)
RETURN p.name, f.name
```

Use `PROFILE` to execute and get per-operator performance metrics:
```gql
PROFILE
MATCH (p:Person)-[:KNOWS]->(f:Person)
RETURN p.name, f.name
```

PROFILE returns metrics including: rows consumed/produced, wall clock time, memory allocation, and spill information per operator.

## GQL vs Cypher differences

Geode implements ISO GQL (ISO/IEC 39075:2024) with Cypher compatibility:
- Both `MATCH`, `CREATE`, `RETURN` work the same
- Use `TRUE`/`FALSE` (not `true`/`false`)
- String concatenation: `||` operator
- Comments: `//` for line, `/* */` for block

Provide working code examples and explain the syntax.
