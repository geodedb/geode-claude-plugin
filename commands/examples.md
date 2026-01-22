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

## Aggregations

```gql
MATCH (p:Person)
RETURN p.city, count(*) AS population
ORDER BY population DESC
LIMIT 10
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

## Update Data

```gql
MATCH (p:Person {name: 'Alice'})
SET p.age = 31
RETURN p
```

Explain the syntax and provide variations based on user's specific needs.
