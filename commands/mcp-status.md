---
description: Check Geode MCP server status and available tools
---

# Geode MCP Status Check

Verify that the Geode MCP (Model Context Protocol) server is installed and accessible.

```bash
geode mcp --help
```

If `geode` is missing or stale, see the [README](../README.md#installation).

## Starting the MCP Server

`geode mcp` (alias `geode mcp serve`) supports two transports:

```bash
# stdio (default for Claude Code, Claude Desktop, etc.)
geode mcp --stdio

# HTTP transport on a fixed port
geode mcp serve --port 8080

# Connect to a non-default Geode endpoint (host:port — no scheme)
geode mcp -e localhost:3141 --stdio
geode mcp serve --port 8080 -e geode.example.com:3141
```

> When `--stdio` is selected, **stdout is reserved for JSON-RPC**. All log output goes to stderr.

## MCP Tools (9)

| Tool | Description |
|------|-------------|
| `query` | Execute a GQL query against Geode |
| `schema` | Get graph schema (labels, relationship types, properties) |
| `explain` | Logical execution plan for a query |
| `catalogs` | List available catalogs |
| `graphs` | List available graphs in a catalog |
| `validate` | Validate GQL syntax + Geode extensions (no server needed) |
| `complete` | GQL completions at a cursor position |
| `hover` | Hover documentation for a GQL element |
| `diagnostics` | Full diagnostics for a GQL document (alias of `validate`) |

## MCP Resources (3)

| Resource URI | Description |
|--------------|-------------|
| `geode://default/default/schema` | Current graph schema |
| `geode://default/default/stats`  | Database statistics |
| `geode://config`                  | Server configuration / version |

## MCP Resource Templates (4)

```text
geode://{catalog}/{graph}/schema
geode://{catalog}/{graph}/stats
geode://{catalog}/{graph}/node/{label}
geode://{catalog}/{graph}/relationship/{type}
```

## MCP Prompts (7)

| Prompt | Description |
|--------|-------------|
| `find_nodes` | Generate queries to find nodes by label/properties |
| `find_relationships` | Generate relationship search queries |
| `create_node` | Generate node creation queries |
| `create_relationship` | Generate relationship creation queries |
| `shortest_path` | Generate shortest-path queries |
| `graph_analysis` | Generate analytics queries (degree, centrality, …) |
| `pattern_match` | Generate pattern-matching queries |

## Authentication

The MCP server enforces authentication by default (bearer token) so tool calls are never anonymous. Disable only for local development with `geode mcp --no-auth` (debug builds only — release builds reject the flag and require a configured token).
