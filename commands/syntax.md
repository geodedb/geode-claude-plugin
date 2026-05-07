---
description: Quick reference for GQL syntax and keywords
---

# GQL Syntax Reference

Provide a quick reference for GQL (ISO/IEC 39075:2024). Focus on: "$ARGUMENTS"

If no specific topic is provided, give the overview below.

## Keywords

### Query Clauses

- `MATCH` — find patterns in the graph
- `WHERE` — filter results
- `RETURN` — specify output
- `ORDER BY` — sort (`ASC`/`DESC`)
- `LIMIT` / `OFFSET` — pagination
- `WITH` — chain query parts

### Modification

- `CREATE` — create nodes / relationships
- `MERGE` — create if not exists
- `SET` — update properties
- `DELETE` / `DETACH DELETE` — remove data

### Aggregation

- `GROUP BY` / `HAVING`

### Transactions (per session)

- `BEGIN`
- `COMMIT`
- `ROLLBACK`

### Query Analysis

- `EXPLAIN` — logical operator tree
- `PROFILE` — execute and return per-operator metrics

### Comments

```gql
// single-line
/* block
   comment */
-- single-line (Geode extension)
```

## Data Types

| Type | Example |
|------|---------|
| INTEGER | `42` |
| FLOAT | `3.14` |
| STRING | `'hello'` or `"hello"` |
| BOOLEAN | `TRUE`, `FALSE` |
| NULL | `NULL` |
| LIST | `[1, 2, 3]` |
| MAP | `{key: 'value'}` |
| VECTOR | `[0.1, 0.2, 0.3]` |

## Pattern Syntax

```text
(variable:Label {property: value})  -- Node
-[:RELATIONSHIP_TYPE]->             -- Directed relationship
<-[:TYPE]-                          -- Reverse direction
-[:TYPE]-                           -- Undirected
-[:TYPE*1..3]->                     -- Variable-length path
```

## Functions

### Aggregation

`count()`, `sum()`, `avg()`, `min()`, `max()`, `collect()`

### String

`toLower()`, `toUpper()`, `trim()`, `substring()`, `replace()`

### List

`size()`, `head()`, `tail()`, `reverse()`, `range()`

### Math

`abs()`, `ceil()`, `floor()`, `round()`, `sqrt()`

### Vector (Geode extension)

`distance(vec, target, metric)`, `similarity()`, `cosine()`, `euclidean()`
Supported metrics: `'L2'`, `'cosine'`, `'dot'`, `'manhattan'`, `'chebyshev'`, `'hamming'`.

## Wire Protocol Messages

### Client → Server

| Message | Purpose |
|---------|---------|
| `HELLO` | Greeting (name, version, conformance) |
| `RUN_GQL` | Submit GQL with parameters |
| `PULL` | Request next page of results |
| `BEGIN` / `COMMIT` / `ROLLBACK` | Transaction demarcation |

### Server → Client

| Response | Description |
|----------|-------------|
| `SCHEMA` | Column descriptors (always first for a new statement) |
| `BINDINGS` | Result rows + ordering / pagination metadata |
| `EXPLAIN` | Logical operator array (JSON) |
| `PROFILE` | Per-operator metrics (JSON) |
| `ERROR` | ISO/IEC 39075 status code + detail |

## Transport

All messages travel over **QUIC+TLS 1.3** (default port 3141) or **gRPC** (port 50051). QUIC adds stream multiplexing and 0-RTT resumption.

## DSN Connection Strings

```text
quic://localhost:3141                        # QUIC (recommended)
grpc://localhost:50051                       # gRPC
quic://user:pass@localhost:3141              # With auth
quic://localhost:3141?page_size=500          # With options
localhost:3141                               # Scheme-less (defaults to QUIC)
```

Provide detailed explanations based on the user's specific question.
