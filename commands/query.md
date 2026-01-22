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

3. **If optimizing**: Suggest improvements:
   - Add indexes for frequently filtered properties
   - Use LIMIT to reduce result sets
   - Filter early with WHERE
   - Use parameters ($param) instead of inline values

## GQL vs Cypher differences

Geode implements ISO GQL (ISO/IEC 39075:2024) with Cypher compatibility:
- Both `MATCH`, `CREATE`, `RETURN` work the same
- Use `TRUE`/`FALSE` (not `true`/`false`)
- String concatenation: `||` operator
- Comments: `//` for line, `/* */` for block

Provide working code examples and explain the syntax.
