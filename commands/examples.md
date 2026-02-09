---
description: Show GQL query examples for common patterns
---

# GQL Query Examples

Provide helpful GQL (Graph Query Language) examples based on what the user asks about: "$ARGUMENTS"

If no specific topic is provided, show these common patterns:

## Basic Queries

### Match and Return
```gql
MATCH (n:Person)
RETURN n.name, n.age
```

### Filter with WHERE
```gql
MATCH (p:Person)
WHERE p.age > 25 AND p.city = 'Seattle'
RETURN p.name
```

### Relationships
```gql
MATCH (p:Person)-[:KNOWS]->(friend:Person)
RETURN p.name, friend.name
```

### Variable-Length Paths
```gql
MATCH (a:Person)-[:KNOWS*1..3]->(b:Person)
WHERE a.name = 'Alice'
RETURN b.name, length(path) AS distance
```

## Aggregations

```gql
MATCH (p:Person)
RETURN p.city, count(*) AS population
ORDER BY population DESC
LIMIT 10
```

### GROUP BY with HAVING
```gql
MATCH (p:Person)
RETURN p.city, avg(p.age) AS avg_age, count(*) AS cnt
GROUP BY p.city
HAVING count(*) > 5
ORDER BY avg_age DESC
```

## Vector Search (Geode-specific)

```gql
MATCH (doc:Document)
WHERE distance(doc.embedding, $query_vector, 'L2') < 0.5
RETURN doc.title, doc.content
ORDER BY distance(doc.embedding, $query_vector, 'L2')
LIMIT 5
```

## Create Data

```gql
CREATE (p:Person {name: 'Alice', age: 30, city: 'Portland'})
RETURN p
```

### Create Relationships
```gql
MATCH (a:Person {name: 'Alice'}), (b:Person {name: 'Bob'})
CREATE (a)-[:KNOWS {since: 2024}]->(b)
RETURN a.name, b.name
```

## Update Data

```gql
MATCH (p:Person {name: 'Alice'})
SET p.age = 31
RETURN p
```

## Transactions

```gql
BEGIN
MATCH (a:Account {id: 'A1'})
SET a.balance = a.balance - 100

MATCH (b:Account {id: 'B2'})
SET b.balance = b.balance + 100
COMMIT
```

To rollback: `ROLLBACK` instead of `COMMIT`.

## Query Analysis

### Explain a Query Plan
```gql
EXPLAIN
MATCH (p:Person)-[:KNOWS]->(f:Person)
WHERE p.age > 25
RETURN p.name, f.name
```

Returns the logical operator tree showing how the query will be executed.

### Profile Query Performance
```gql
PROFILE
MATCH (p:Person)-[:KNOWS]->(f:Person)
WHERE p.age > 25
RETURN p.name, f.name
```

Returns per-operator metrics including rows processed, time, and memory usage.

## WITH Chaining

```gql
MATCH (p:Person)-[:KNOWS]->(f:Person)
WITH p, count(f) AS friend_count
WHERE friend_count > 5
RETURN p.name, friend_count
ORDER BY friend_count DESC
```

## MERGE (Create if Not Exists)

```gql
MERGE (p:Person {name: 'Charlie'})
SET p.updated = TRUE
RETURN p
```

## Delete Data

```gql
// Delete a node (must have no relationships)
MATCH (p:Person {name: 'Charlie'})
DELETE p

// Delete a node and all its relationships
MATCH (p:Person {name: 'Charlie'})
DETACH DELETE p
```

Explain the syntax and provide variations based on user's specific needs.
