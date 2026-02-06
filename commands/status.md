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
