---
description: Check Geode GQL LSP and MCP server status and installation
---

# Geode Status Check

Verify that the Geode binary, LSP server, and MCP server are properly installed and accessible.

## Quick Verification

```bash
geode --version          # must report v0.5.11 or newer
geode lsp --help
geode mcp --help
geode serve --help
```

If `geode` is not installed, see the [README](../README.md#installation) for APT, Nix, Docker, and from-source install paths.

## Top-level Commands

| Command | Description |
|---------|-------------|
| `serve` | Start the Geode database server |
| `query` | Execute a GQL query (one-shot) |
| `shell` | Interactive GQL REPL |
| `lsp`   | Language Server Protocol server (stdio) |
| `mcp`   | Model Context Protocol server (stdio or HTTP) |
| `auth`  | Authentication: `login` / `logout` / `token` / `init` / `reseal` / `verify` |
| `login` | Top-level alias for `auth login` |
| `logout`| Top-level alias for `auth logout` |
| `user`  | User management |
| `role`  | Role management |
| `policy`| Row-level-security policy management |
| `grant` / `revoke` | Permission management |
| `backup` / `restore` | Database backup and restore |
| `migrate` | Migrations: `status` / `up` / `create` / `sign` |
| `fle`   | Field-Level Encryption management |
| `storage` | Storage engine maintenance and verification |
| `apikey` | API key management |
| `completion` | Generate shell completion scripts (bash/zsh/fish/powershell) |

## `geode serve` Options

```bash
--data-dir <path>         Data directory (default: ./data)
--listen <addr:port>      QUIC/TLS listen address (default: 0.0.0.0:3141)
--listen-grpc <addr:port> gRPC listen address (advanced; off by default)
--cert <path>             TLS certificate path (auto-generated if missing)
--key <path>              TLS private key path (auto-generated if missing)
--log-level <level>       debug | info | warn | error (default: info)
--idle-timeout <ms>       QUIC idle timeout in ms (default: 300000)
--persist-interval <ms>   Background persistence interval (default: 100)
```

## Global Flags

```bash
-v, --verbose              Verbose output
--config <path>            Configuration file path
--json                     Force JSON output for all subcommands
--audit                    Enable audit logging
--audit-syslog <host:port> Send audit events to a syslog server
--audit-file <path>        Write audit events to a file
--audit-eventlog [source]  Enable Windows Event Log (default source: Geode)
```

## Transport

| Protocol | Default Port | TLS | Notes |
|----------|--------------|-----|-------|
| QUIC | 3141 | Required (TLS 1.3) | Recommended; high-performance UDP. |
| gRPC | 50051 | Optional | Standard HTTP/2; enable with `--listen-grpc`. |

## DSN Connection Strings

```bash
quic://localhost:3141                   # QUIC (default scheme if omitted)
grpc://localhost:50051                  # gRPC
quic://user:pass@host:3141              # With credentials
quic://host:3141?page_size=500          # With options
host:3141                               # Bare host:port — defaults to QUIC
```

## LSP Capabilities

- Hover documentation for GQL keywords, functions, types
- Code completion with triggers `.`, `:`, `$`
- Real-time syntax diagnostics
- Go-to-definition
- Document formatting

Supported file extensions: `.gql`, `.gcypher`, `.cypher`, `.pgql`.

## MCP Capabilities

The Geode MCP server exposes 9 tools (`query`, `schema`, `explain`, `catalogs`, `graphs`, `validate`, `complete`, `hover`, `diagnostics`), 3 resources, 4 resource templates, and 7 query-template prompts. See `/geode:mcp-status` for the full inventory.
