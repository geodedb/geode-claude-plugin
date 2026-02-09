---
description: Check Geode GQL LSP and MCP server status and installation
---

# Geode Status Check

Check if the Geode GQL Language Server and MCP server are properly installed and accessible.

Run these commands to verify:
```bash
geode --version
geode lsp --help
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
   geode lsp --help
   geode mcp --help
   ```

## Server Commands

Geode uses a **unified binary architecture** with the following commands:

| Command | Description |
|---------|-------------|
| `serve` | Start the Geode database server |
| `query` | Execute a GQL query |
| `shell` | Start interactive shell (REPL) |
| `lsp` | Start Language Server Protocol server |
| `mcp` | Model Context Protocol server |
| `auth` | Authentication commands (login, logout, token) |
| `backup` | Create database backup |
| `restore` | Restore database from backup |
| `migrate` | Database migration commands |
| `user` | Manage users |
| `role` | Manage roles |
| `policy` | Manage policies |
| `grant` | Grant permissions |
| `revoke` | Revoke permissions |
| `fle` | Field-Level Encryption management |
| `storage` | Storage engine management and verification |
| `session` | Session management |
| `authn` | Authentication provider configuration |
| `apikey` | API key management |

## Serve Command Options

```bash
geode serve [OPTIONS]

Options:
  -c, --config <path>          Path to config file (YAML, TOML, or JSON)
  --listen <addr:port>         QUIC/TLS listen address (default: 0.0.0.0:3141)
  --listen-grpc <addr:port>    gRPC listen address (disabled by default)
  --cert <path>                TLS certificate path (default: auto-generate)
  --key <path>                 TLS private key path (default: auto-generate)
  --data-dir <path>            Data directory for storage and generated certs
  --log-level <level>          Log level: trace|debug|info|warn|error|critical (default: info)
  --order-keys expr            Allow expressions in ORDER BY
```

## Transport

| Protocol | Default Port | TLS | Notes |
|----------|-------------|-----|-------|
| QUIC | 3141 | Required (TLS 1.3) | **Recommended** - high-performance UDP transport |
| gRPC | 50051 | Optional | Standard HTTP/2 based, enable with `--listen-grpc` |

## LSP Capabilities

- Hover documentation for GQL keywords, functions, types
- Code completion with triggers: `.`, `:`, `$`
- Real-time syntax diagnostics
- Go-to-definition support
- Document formatting

Supported file extensions: `.gql`, `.gcypher`, `.cypher`, `.pgql`

## MCP Capabilities

The Geode MCP server provides tools for:
- Query execution and validation
- Schema introspection
- Query explanation and optimization
- Code completions and diagnostics
- Graph analysis prompts

See `/geode:mcp-status` for detailed MCP tool information.
