---
description: Check Geode MCP server status and available tools
---

# Geode MCP Status Check

Check if the Geode MCP (Model Context Protocol) server is properly installed and accessible.

Run this command to verify MCP support:
```bash
geode mcp --help
```

If geode is not found, provide installation instructions:

1. Build from source:
   ```bash
   git clone https://gitlab.com/devnw/codepros/geode/geode.git
   cd geode && make build
   export PATH="$PWD/zig-out/bin:$PATH"
   ```

2. Verify installation:
   ```bash
   geode --version
   geode mcp --help
   ```

## MCP Tools Available

The Geode MCP server provides these tools to Claude:

| Tool | Description |
|------|-------------|
| `query` | Execute GQL queries against Geode |
| `schema` | Get graph schema information |
| `explain` | Get query execution plans |
| `catalogs` | List available catalogs |
| `graphs` | List available graphs |
| `validate` | Validate GQL query syntax |
| `complete` | Get code completions for GQL |
| `hover` | Get hover information for tokens |
| `diagnostics` | Get diagnostics for queries |

## MCP Resources Available

| Resource URI | Description |
|--------------|-------------|
| `geode://default/default/schema` | Graph schema |
| `geode://default/default/stats` | Database statistics |
| `geode://config` | Server configuration |

## MCP Prompts Available

| Prompt | Description |
|--------|-------------|
| `find_nodes` | Generate queries to find nodes |
| `find_relationships` | Generate relationship search queries |
| `create_node` | Generate node creation queries |
| `create_relationship` | Generate relationship creation queries |
| `shortest_path` | Generate shortest path queries |
| `graph_analysis` | Generate graph analysis queries |
| `pattern_match` | Generate pattern matching queries |

## Starting the MCP Server

The MCP server can run in two modes:

```bash
# stdio mode (default, for Claude Code integration)
geode mcp serve

# HTTP mode (for remote access)
geode mcp serve --http --port 8080

# With custom Geode QUIC endpoint
geode mcp serve -e quic://localhost:3141

# With custom Geode gRPC endpoint
geode mcp serve -e grpc://localhost:50051
```

## Transport Configuration

The MCP server connects to a running Geode database server. Geode supports two transport protocols:

| Protocol | Scheme | Default Port | TLS | Description |
|----------|--------|-------------|-----|-------------|
| QUIC | `quic://` | 3141 | Required (TLS 1.3) | **Recommended** - high-performance UDP transport |
| gRPC | `grpc://` | 50051 | Optional | Standard HTTP/2 based |

### Starting the Geode Server

```bash
# Default: QUIC on port 3141 (TLS auto-generated)
geode serve

# Explicit QUIC address
geode serve --listen 0.0.0.0:3141

# Enable both QUIC and gRPC
geode serve --listen 0.0.0.0:3141 --listen-grpc 0.0.0.0:50051

# With custom TLS certificates
geode serve --cert /path/to/server.crt --key /path/to/server.key

# With persistent storage
geode serve --data-dir /var/lib/geode

# With config file
geode serve --config /path/to/config.yaml
```
