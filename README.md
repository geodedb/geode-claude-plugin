# Geode GQL Language Server Plugin for Claude Code

This plugin provides Language Server Protocol (LSP) support and slash commands for Geode's GQL (Graph Query Language) in Claude Code.

## Features

### LSP Features
- **Syntax Diagnostics**: Real-time error detection for GQL queries
- **Hover Documentation**: Documentation for GQL keywords, functions, and types
- **Code Completion**: Intelligent completions for keywords, functions, and types
- **Go-to-Definition**: Navigate to symbol definitions
- **Document Formatting**: Format GQL documents

### Slash Commands
- `/geode-lsp:status` - Check LSP installation and capabilities
- `/geode-lsp:examples` - Show GQL query examples for common patterns
- `/geode-lsp:syntax` - Quick reference for GQL syntax and keywords
- `/geode-lsp:query` - Help write, debug, or optimize GQL queries

## Supported File Extensions

- `.gql` - GQL files
- `.gcypher` - Geode Cypher variant
- `.cypher` - Cypher compatibility
- `.pgql` - Property Graph Query Language

## Installation

### Prerequisites

1. **Geode** must be installed and available in your PATH:
   ```bash
   # Build from source
   git clone https://github.com/geode-db/geode.git
   cd geode && make build
   export PATH="$PWD/zig-out/bin:$PATH"
   ```

### Test Plugin Locally

```bash
# Load plugin for testing (from geode repo root)
claude --plugin-dir ./claude-code-lsp-plugin
```

### Install from Marketplace (when published)

```bash
claude /plugin install geode-lsp@<marketplace-name>
```

## Usage

### LSP Features
Once loaded, the LSP server automatically starts when you open a supported file:
- Red squiggles for syntax errors
- Hover tooltips with documentation
- Completion suggestions as you type

### Slash Commands

```
/geode-lsp:status              # Check if LSP is working
/geode-lsp:examples            # Show common GQL patterns
/geode-lsp:examples vector     # Show vector search examples
/geode-lsp:syntax              # GQL syntax quick reference
/geode-lsp:syntax aggregation  # Aggregation function reference
/geode-lsp:query               # Help write a new query
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

```
claude-code-lsp-plugin/
├── .claude-plugin/
│   └── plugin.json       # Plugin metadata
├── .lsp.json             # LSP server configuration
├── commands/
│   ├── status.md         # /geode-lsp:status
│   ├── examples.md       # /geode-lsp:examples
│   ├── syntax.md         # /geode-lsp:syntax
│   └── query.md          # /geode-lsp:query
├── hooks/
│   ├── hooks.json        # Session start hook
│   └── check-geode.sh    # Installation check script
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

## Development

To modify this plugin:

1. Edit `.lsp.json` for LSP configuration
2. Add/edit commands in `commands/` directory
3. Edit `hooks/check-geode.sh` for installation checks
4. Test with `claude --plugin-dir ./claude-code-lsp-plugin`

## License

Apache License 2.0 - See [LICENSE](LICENSE) for details.
