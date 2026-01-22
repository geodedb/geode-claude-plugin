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

Provide detailed explanations based on user's specific question.
