---
description: Quick reference for GQL syntax and keywords
---

# GQL Syntax Reference

Provide a quick reference for GQL syntax. Focus on: "$ARGUMENTS"

If no specific topic, provide an overview:

## Keywords

### Query Clauses
- `MATCH` - Find patterns in the graph
- `WHERE` - Filter results
- `RETURN` - Specify output
- `ORDER BY` - Sort results (ASC/DESC)
- `LIMIT` / `OFFSET` - Pagination
- `WITH` - Chain query parts

### Modification
- `CREATE` - Create nodes/relationships
- `MERGE` - Create if not exists
- `SET` - Update properties
- `DELETE` / `DETACH DELETE` - Remove data

### Aggregation
- `GROUP BY` - Group results
- `HAVING` - Filter groups

### Transaction Control
- `BEGIN` - Start a transaction
- `COMMIT` - Commit the current transaction
- `ROLLBACK` - Rollback the current transaction

### Query Analysis
- `EXPLAIN` - Show logical query execution plan
- `PROFILE` - Execute and show per-operator performance metrics

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

```
(variable:Label {property: value})  -- Node
-[:RELATIONSHIP_TYPE]->             -- Directed relationship
<-[:TYPE]-                          -- Reverse direction
-[:TYPE]-                           -- Undirected
-[:TYPE*1..3]->                     -- Variable length path
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

### Vector (Geode)
`distance()`, `similarity()`, `cosine()`, `euclidean()`

## Wire Protocol Messages

### Client Messages
| Message | Purpose |
|---------|---------|
| `HELLO` | Client greeting (name, version, conformance) |
| `RUN_GQL` | Submit GQL query with parameters |
| `PULL` | Request next page of results |
| `BEGIN` / `COMMIT` / `ROLLBACK` | Transaction demarcation |

### Server Response Types
| Response | Description |
|----------|-------------|
| `SCHEMA` | Column descriptors (always first for new statement) |
| `BINDINGS` | Result rows with ordering and pagination metadata |
| `EXPLAIN` | Logical operator array (JSON) |
| `PROFILE` | Per-operator metrics (JSON) |
| `ERROR` | Error details with ISO/IEC 39075 status codes |

## Transport

All messages are transmitted over **QUIC+TLS** (default port 3141) or **gRPC** (port 50051). QUIC transport uses TLS 1.3 with stream multiplexing and 0-RTT resumption.

## DSN Connection Strings

```
quic://localhost:3141                        # QUIC (recommended)
grpc://localhost:50051                       # gRPC
quic://user:pass@localhost:3141              # With auth
quic://localhost:3141?page_size=500          # With options
```

Provide detailed explanations based on user's specific question.
