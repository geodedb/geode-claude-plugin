---
name: gql-query-patterns
description: Use when you need a runnable GQL template for a known shape — filtered scan, aggregation, variable-length path, MERGE upsert, vector kNN, transactional transfer, or EXPLAIN/PROFILE. Each template is parameterized.
---

# GQL Query Patterns

Each pattern is the smallest correct version. Adjust labels, relationship types, and parameters.

## 1. Filtered scan with projection

```gql
MATCH (p:Person)
WHERE p.age >= $minAge AND p.city = $city
RETURN p.name, p.age
ORDER BY p.age DESC
LIMIT $limit
```

## 2. One-hop relationship

```gql
MATCH (a:Person {id: $id})-[:KNOWS]->(b:Person)
RETURN b.name
```

## 3. Variable-length path

```gql
MATCH path = (a:Person {id: $id})-[:KNOWS*1..$maxHops]-(b:Person)
WHERE b.id <> $id
RETURN b.name, length(path) AS hops
ORDER BY hops
LIMIT $limit
```

## 4. Aggregation with GROUP BY / HAVING

```gql
MATCH (p:Person)-[:LIVES_IN]->(c:City)
RETURN c.name, count(p) AS population, avg(p.age) AS avg_age
GROUP BY c.name
HAVING count(p) >= $minPop
ORDER BY population DESC
```

## 5. MERGE upsert

```gql
MERGE (u:User {id: $id})
ON CREATE SET u.created = datetime(), u.email = $email
ON MATCH  SET u.last_seen = datetime()
RETURN u
```

## 6. Vector kNN by cosine

```gql
MATCH (d:Document)
WHERE d.embedding IS NOT NULL
RETURN d.title, distance(d.embedding, $query, 'cosine') AS score
ORDER BY score
LIMIT $k
```

## 7. Transactional transfer

```gql
BEGIN
MATCH (a:Account {id: $from})
WHERE a.balance >= $amount
SET a.balance = a.balance - $amount

MATCH (b:Account {id: $to})
SET b.balance = b.balance + $amount

RETURN a.balance AS from_balance, b.balance AS to_balance
COMMIT
```

## 8. EXPLAIN / PROFILE

```gql
EXPLAIN
MATCH (p:Person)-[:KNOWS]->(f:Person)
WHERE p.age > $minAge
RETURN p.name, f.name
```

```gql
PROFILE
MATCH (p:Person)-[:KNOWS]->(f:Person)
WHERE p.age > $minAge
RETURN p.name, f.name
```

## 9. Detach delete (relationships first)

```gql
MATCH (n:Tombstone) DETACH DELETE n
```

## 10. WITH chaining for staged filtering

```gql
MATCH (p:Person)-[:KNOWS]->(f:Person)
WITH p, count(f) AS friend_count
WHERE friend_count >= $minFriends
RETURN p.name, friend_count
ORDER BY friend_count DESC
LIMIT $limit
```

## Cross-references

- See `skills/gql-syntax-reference` for keyword/operator/type definitions.
- See `commands/examples.md` for a smaller curated set.
