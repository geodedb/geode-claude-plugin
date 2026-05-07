# Geode GQL Plugin for Claude Code

This plugin provides Language Server Protocol (LSP) support, Model Context Protocol (MCP) tools, and slash commands for Geode's GQL (Graph Query Language) in Claude Code.

## Features

### MCP Tools (via `geode mcp serve`)

The MCP server provides Claude with direct access to Geode:

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

### MCP Resources

| Resource URI | Description |
|--------------|-------------|
| `geode://default/default/schema` | Graph schema |
| `geode://default/default/stats` | Database statistics |
| `geode://config` | Server configuration |

### MCP Prompts

Pre-built prompts for common graph operations:

- `find_nodes` - Generate queries to find nodes
- `find_relationships` - Generate relationship search queries
- `create_node` / `create_relationship` - Generate creation queries
- `shortest_path` - Generate shortest path queries
- `graph_analysis` - Generate graph analysis queries
- `pattern_match` - Generate pattern matching queries

### LSP Features (via `geode lsp`)

- **Syntax Diagnostics**: Real-time error detection for GQL queries
- **Hover Documentation**: Documentation for GQL keywords, functions, and types
- **Code Completion**: Intelligent completions for keywords, functions, and types
- **Go-to-Definition**: Navigate to symbol definitions
- **Document Formatting**: Format GQL documents

### Slash Commands

- `/geode:status` - Check LSP and MCP installation, server commands, and transport config
- `/geode:mcp-status` - Detailed MCP server status and available tools
- `/geode:examples` - Show GQL query examples (including transactions, EXPLAIN, PROFILE)
- `/geode:syntax` - Quick reference for GQL syntax, keywords, and wire protocol
- `/geode:query` - Help write, debug, or optimize GQL queries

## Supported File Extensions

- `.gql` - GQL files
- `.gcypher` - Geode Cypher variant
- `.cypher` - Cypher compatibility
- `.pgql` - Property Graph Query Language

## Installation

### Prerequisites — install `geode` v0.5.11+

The plugin only configures Claude Code; the actual GQL functionality lives in the `geode` binary. Pick **one** install path.

#### APT (Debian/Ubuntu)

```bash
curl -fsSL https://apt.geodedb.com/geodedb-keyring.gpg \
  | sudo tee /usr/share/keyrings/geodedb-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/geodedb-archive-keyring.gpg] https://apt.geodedb.com/ stable main" \
  | sudo tee /etc/apt/sources.list.d/geodedb.list
sudo apt update && sudo apt install geode
```

#### Nix

```bash
nix run github:codeprosorg/geode -- --version
```

#### Docker

```bash
docker run --rm codeprosorg/geode:latest --version
docker run -p 3141:3141/udp codeprosorg/geode:latest serve
```

#### Build from Source (Zig 0.16.0+)

```bash
git clone https://gitlab.com/devnw/codepros/geode/geode.git
cd geode && make build
export PATH="$PWD/zig-out/bin:$PATH"
```

Verify:

```bash
geode --version    # must report v0.5.11 or newer
```

### Install the plugin (Claude Code)

The `geode` monorepo ships a marketplace manifest at `.claude-plugin/marketplace.json` that lists this plugin.

```bash
# From the parent of the geode monorepo
claude plugin marketplace add ./geode
claude plugin install geode@geode --scope user
```

Scopes:

- `--scope user` — all projects (`~/.claude/settings.json`)
- `--scope project` — shared with the team (`.claude/settings.json`)
- `--scope local` — this machine only (`.claude/settings.local.json`)

### Test the plugin without installing

```bash
# From the geode monorepo root
claude --plugin-dir ./geode-claude-plugin
```

## Usage

### Starting the Geode Server

```bash
# Default: QUIC transport on port 3141 (TLS auto-generated)
geode serve

# Explicit QUIC listen address
geode serve --listen 0.0.0.0:3141

# Enable both QUIC and gRPC
geode serve --listen 0.0.0.0:3141 --listen-grpc 0.0.0.0:50051

# With persistent storage
geode serve --data-dir /var/lib/geode

# With custom TLS certificates
geode serve --cert /path/to/server.crt --key /path/to/server.key

# With config file (YAML, TOML, or JSON)
geode serve --config .geode/config.yaml

# Set log level
geode serve --log-level debug
```

### Transport Protocols

| Protocol | Scheme | Default Port | TLS | Description |
|----------|--------|-------------|-----|-------------|
| QUIC | `quic://` | 3141 | Required (TLS 1.3) | **Recommended** - high-performance UDP transport |
| gRPC | `grpc://` | 50051 | Optional | Standard HTTP/2 based |

QUIC is the default and recommended transport. It provides built-in TLS 1.3, stream multiplexing, and 0-RTT connection resumption. gRPC is available as an alternative when HTTP/2 compatibility is needed.

### DSN Connection Strings

All client libraries use a unified DSN (Data Source Name) format:

```text
quic://localhost:3141                            # QUIC (recommended)
grpc://localhost:50051                           # gRPC
quic://user:pass@localhost:3141                  # With authentication
quic://localhost:3141?page_size=500              # With query options
localhost:3141                                   # Scheme-less (defaults to QUIC)
```

### Configuration Files

Geode searches for config files in order:

1. `.geode/config.{yaml|toml|json}` (project config)
2. `~/.config/geode/config.*` (user config)

CLI flags override config file values, which override defaults.

### Storage

Geode uses MVCC-based persistent storage with:

- **Write-Ahead Logging (WAL)** for durability
- **Transparent Data Encryption (TDE)** with KMS support
- **S3 cloud backup** integration (S3, DigitalOcean Spaces)
- Binary format for efficient on-disk storage

Configure storage with `--data-dir`:

```bash
geode serve --data-dir /var/lib/geode
```

### CLI Commands

Geode uses a unified binary with these commands:

| Command | Description |
|---------|-------------|
| `serve` | Start the Geode database server |
| `query` | Execute a GQL query (one-shot) |
| `shell` | Interactive GQL REPL |
| `lsp` | Language Server Protocol server (stdio) |
| `mcp` | Model Context Protocol server (stdio or HTTP) |
| `auth` | Authentication: `login` / `logout` / `token` / `init` / `reseal` / `verify` |
| `login` | Top-level alias for `auth login` |
| `logout` | Top-level alias for `auth logout` |
| `user` | User management |
| `role` | Role management |
| `policy` | Row-level-security policy management |
| `grant` / `revoke` | Permission management |
| `backup` / `restore` | Database backup and restore |
| `migrate` | Migrations: `status` / `up` / `create` / `sign` |
| `fle` | Field-Level Encryption management |
| `storage` | Storage engine maintenance and verification |
| `apikey` | API key management |
| `completion` | Generate shell completion scripts (bash/zsh/fish/powershell) |

### LSP Features

Once loaded, the LSP server automatically starts when you open a supported file:

- Red squiggles for syntax errors
- Hover tooltips with documentation
- Completion suggestions as you type

### Slash Commands

```bash
/geode:status                  # Check if LSP and MCP are working
/geode:mcp-status              # Detailed MCP tools and resources
/geode:examples                # Show common GQL patterns
/geode:examples vector         # Show vector search examples
/geode:syntax                  # GQL syntax quick reference
/geode:syntax aggregation      # Aggregation function reference
/geode:query                   # Help write a new query
```

## Authentication & Transport

### DSN

All clients (CLI, MCP, drivers) use a unified DSN:

```text
quic://[user:pass@]host[:port][?key=value]   # default scheme
grpc://[user:pass@]host[:port][?key=value]   # gRPC
host[:port]                                  # bare host:port → QUIC
```

| Protocol | Default Port | TLS                  |
|----------|--------------|----------------------|
| QUIC     | 3141         | Required (TLS 1.3)   |
| gRPC     | 50051        | Optional             |

### Authentication

```bash
# Save a session for repeated use
geode auth login -U alice --save-session
geode auth token             # print saved credentials JSON
geode auth logout

# Offline (operates directly on the data dir)
geode auth init    --data-dir ./data
geode auth verify  --data-dir ./data
geode auth reseal  --data-dir ./data
```

### Mutual TLS

Provide enterprise PKI material on any client subcommand:

```text
--ca-cert /etc/ssl/ca.crt
--client-cert /etc/ssl/client.crt
--client-key  /etc/ssl/client.key
```

### Audit Logging

Global flags (apply to any subcommand):

```text
--audit                     Enable audit logging
--audit-file <path>         Append events to a file
--audit-syslog <host:port>  Send events to a syslog server
--audit-eventlog [source]   Windows Event Log (default source: Geode)
```

## LSP Capabilities

| Feature | Support |
|---------|---------|
| textDocument/hover | Yes |
| textDocument/completion | Yes (triggers: `.`, `:`, `$`) |
| textDocument/definition | Yes |
| textDocument/formatting | Yes |
| textDocument/publishDiagnostics | Yes |

## Plugin Structure

```text
geode-claude-plugin/
├── .claude-plugin/
│   └── plugin.json       # Plugin metadata (v2.1.0)
├── .lsp.json             # LSP server config (extension → language)
├── .mcp.json             # MCP server launch (stdio)
├── agents/
│   ├── gql-query-writer.md
│   ├── gql-debugger.md
│   └── graph-schema-designer.md
├── skills/
│   ├── gql-syntax-reference/SKILL.md
│   ├── gql-query-patterns/SKILL.md
│   └── geode-mcp-tools/SKILL.md
├── commands/
│   ├── status.md         # /geode:status
│   ├── mcp-status.md     # /geode:mcp-status
│   ├── examples.md       # /geode:examples
│   ├── syntax.md         # /geode:syntax
│   └── query.md          # /geode:query
├── hooks/
│   ├── hooks.json        # SessionStart hook config
│   └── check-geode.sh    # Installation + version check (>= 0.5.11)
├── docs/
│   ├── REQUIREMENTS.md
│   ├── GAP_ANALYSIS.md
│   └── superpowers/plans/
└── README.md
```

## Troubleshooting

### LSP Not Starting

1. Verify geode is installed:

   ```bash
   geode lsp --help
   ```

2. Check that geode is in your PATH

3. Restart Claude Code after loading the plugin

### No Completions

Completions are triggered by:

- Typing `.` after a variable
- Typing `:` for label syntax
- Typing `$` for parameter names

### Server Connection Issues

1. Verify the server is running:

   ```bash
   geode serve
   ```

2. Check the transport and port:
   - QUIC: default `0.0.0.0:3141`
   - gRPC: requires `--listen-grpc 0.0.0.0:50051`

3. For TLS issues, try auto-generated certificates (default) or specify `--cert` and `--key`

## Development

To modify this plugin:

1. Edit `.lsp.json` for LSP configuration
2. Edit `.mcp.json` for MCP server configuration
3. Add/edit commands in `commands/` directory
4. Edit `hooks/check-geode.sh` for installation checks
5. Test with `claude --plugin-dir ./geode-claude-plugin`

## License

Apache License 2.0 - See [LICENSE](LICENSE) for details.
