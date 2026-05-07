---
name: gql-syntax-reference
description: Use when writing, reviewing, or debugging GQL (ISO/IEC 39075:2024) and you need an authoritative reference for keywords, operators, types, transactions, comments, vector functions, or wire-protocol behavior. Loaded on demand to avoid bloating the default context.
---

# GQL Syntax Reference

Geode implements **ISO/IEC 39075:2024 (GQL)** with Cypher compatibility.

## Statement structure

```text
<reading clauses> <projection> [<post-projection ops>]

reading      : MATCH | OPTIONAL MATCH | WITH <reading>
projection   : RETURN <expr-list>
post-proj    : ORDER BY <expr-list> | LIMIT <int> | OFFSET <int>
mutation     : CREATE | MERGE | SET | DELETE | DETACH DELETE
```

## Patterns

```text
(v:Label {key: value})            # node binding
(v:Label1:Label2)                 # multi-label
-[:TYPE]->                        # outbound directed
<-[:TYPE]-                        # inbound
-[:TYPE]-                         # undirected
-[r:TYPE {prop: val}]->           # bound relationship variable
-[:TYPE*1..3]->                   # variable-length, hops 1..3
-[:TYPE*..]->                     # zero or more
```

## Boolean and null logic

- `TRUE`, `FALSE`, `NULL` are uppercase.
- Three-valued logic: `NULL AND TRUE = NULL`, `NULL OR TRUE = TRUE`.
- Use `IS NULL` / `IS NOT NULL` — never `= NULL`.

## Comments

```gql
// line comment
/* block
   comment */
-- line comment (Geode extension)
```

## Transactions

```gql
BEGIN
MATCH (a:Account {id: $from}) SET a.balance = a.balance - $amt
MATCH (b:Account {id: $to})   SET b.balance = b.balance + $amt
COMMIT      -- or ROLLBACK
```

Geode uses MVCC + Serializable Snapshot Isolation (SSI). A transaction that contends will fail at `COMMIT` with an SSI error code; retry from `BEGIN`.

## Aggregations

```text
count(*)         total rows
count(x)         non-null x
count(DISTINCT x)
sum / avg / min / max / collect / stddev / percentileCont(x, p)
```

`GROUP BY` is implicit on non-aggregated `RETURN` columns. `HAVING` filters groups.

## String / list / math

| Family | Examples |
|--------|----------|
| String | `toLower`, `toUpper`, `trim`, `substring(s, start, len)`, `replace(s, find, with)`, `split(s, sep)` |
| List   | `size`, `head`, `tail`, `reverse`, `range(start, end[, step])`, `[x IN list WHERE ...]` |
| Math   | `abs`, `ceil`, `floor`, `round`, `sqrt`, `log`, `pi()`, `rand()` |

## Vector (Geode extension)

```gql
distance(vec, target, metric)
similarity(vec, target, metric)        // 1 - distance
```

Metrics: `'L2'`, `'cosine'`, `'dot'` (alias `'dot_product'`).

## EXPLAIN / PROFILE

```gql
EXPLAIN MATCH (n) RETURN n              -- logical plan only, no execution
PROFILE MATCH (n) RETURN n              -- runs and reports per-operator metrics
```

`PROFILE` returns per-operator: rows in/out, wall ms, allocation bytes, spill bytes.

## Error codes (ISO/IEC 39075)

Errors use a five-letter SQLSTATE-style code, e.g. `42000` (syntax), `42P01` (undefined relation), `40001` (serialization failure). Geode-specific codes start with `G`.

## See also

- `skills/gql-query-patterns` for runnable templates
- `commands/syntax.md` for the at-a-glance summary
