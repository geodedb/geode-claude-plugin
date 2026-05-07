# Requirements

> **Last Updated:** 2026-05-06
>
> This is a flatfile mirror of requirements tracked in GitLab. **GitLab is the source of truth.**
>
> **View in GitLab:** [All Issues](https://gitlab.com/devnw/codepros/geode/geode-claude-plugin/-/issues)

## Plugin Features (Implemented)

The following features are documented in README.md and implemented via configuration:

### MCP Integration

| Feature | Status | Configuration |
|---------|--------|---------------|
| MCP Server Launch | Implemented | `.mcp.json` |
| query tool | Implemented | geode mcp serve |
| schema tool | Implemented | geode mcp serve |
| explain tool | Implemented | geode mcp serve |
| catalogs tool | Implemented | geode mcp serve |
| graphs tool | Implemented | geode mcp serve |
| validate tool | Implemented | geode mcp serve |
| complete tool | Implemented | geode mcp serve |
| hover tool | Implemented | geode mcp serve |
| diagnostics tool | Implemented | geode mcp serve |

### LSP Integration

| Feature | Status | Configuration |
|---------|--------|---------------|
| LSP Server Launch | Implemented | `.lsp.json` |
| textDocument/hover | Implemented | geode lsp |
| textDocument/completion | Implemented | geode lsp |
| textDocument/definition | Implemented | geode lsp |
| textDocument/formatting | Implemented | geode lsp |
| textDocument/publishDiagnostics | Implemented | geode lsp |

### Slash Commands

| Command | Status | File |
|---------|--------|------|
| /geode:status | Implemented | commands/status.md |
| /geode:mcp-status | Implemented | commands/mcp-status.md |
| /geode:examples | Implemented | commands/examples.md |
| /geode:syntax | Implemented | commands/syntax.md |
| /geode:query | Implemented | commands/query.md |

### File Extension Support

| Extension | Language ID | Status |
|-----------|-------------|--------|
| .gql | gql | Implemented |
| .gcypher | gql | Implemented |
| .cypher | gql | Implemented |
| .pgql | gql | Implemented |

### CI/CD Pipeline

| Job | Stage | Status |
|-----|-------|--------|
| validate-json | validate | Implemented |
| validate-config-schema | validate | Implemented |
| validate-shell | validate | Implemented |
| validate-markdown | validate | Implemented |
| test-structure | test | Implemented |
| test-hooks | test | Implemented |
| test-integration | integration | Implemented |

### Agents

| Agent | Status | File |
|-------|--------|------|
| gql-query-writer | Implemented | agents/gql-query-writer.md |
| gql-debugger | Implemented | agents/gql-debugger.md |
| graph-schema-designer | Implemented | agents/graph-schema-designer.md |

### Skills

| Skill | Status | Path |
|-------|--------|------|
| gql-syntax-reference | Implemented | skills/gql-syntax-reference/SKILL.md |
| gql-query-patterns | Implemented | skills/gql-query-patterns/SKILL.md |
| geode-mcp-tools | Implemented | skills/geode-mcp-tools/SKILL.md |

### Marketplace

| Item | Status | Path |
|------|--------|------|
| geode marketplace manifest | Implemented | ../geode/.claude-plugin/marketplace.json |

## Gap Status

All gaps have been resolved. See [GAP_ANALYSIS_RESOLVED.md](GAP_ANALYSIS_RESOLVED.md) for details.

| Gap ID | Title | Status | GitLab Issue |
|--------|-------|--------|--------------|
| GAP-0001 | CI Pipeline Missing MCP Structure Test | Resolved | [#1](https://gitlab.com/devnw/codepros/geode/geode-claude-plugin/-/issues/1) |
| GAP-0002 | Incorrect Repository URL in Documentation | Resolved | [#2](https://gitlab.com/devnw/codepros/geode/geode-claude-plugin/-/issues/2) |
| GAP-0003 | Incorrect Package Manager Installation Instructions | Resolved | [#3](https://gitlab.com/devnw/codepros/geode/geode-claude-plugin/-/issues/3) |
| GAP-0004 | No Integration Testing for Plugin Functionality | Resolved | [#4](https://gitlab.com/devnw/codepros/geode/geode-claude-plugin/-/issues/4) |
| GAP-0005 | Missing MCP JSON Schema Validation in CI | Resolved | [#5](https://gitlab.com/devnw/codepros/geode/geode-claude-plugin/-/issues/5) |
| GAP-0006 | Incorrect Repository URL in plugin.json | Resolved | [#6](https://gitlab.com/devnw/codepros/geode/geode-claude-plugin/-/issues/6) |
