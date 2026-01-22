---
description: Check Geode GQL LSP server status and installation
---

# GQL LSP Status Check

Check if the Geode GQL Language Server is properly installed and accessible.

Run this command to verify:
```bash
geode lsp --help
```

If geode is not found, provide installation instructions:

1. Build from source:
   ```bash
   git clone https://github.com/geode-db/geode.git
   cd geode && make build
   export PATH="$PWD/zig-out/bin:$PATH"
   ```

2. Verify installation:
   ```bash
   geode --version
   geode lsp --help
   ```

Report the LSP capabilities:
- Hover documentation for GQL keywords, functions, types
- Code completion with triggers: `.`, `:`, `$`
- Real-time syntax diagnostics
- Go-to-definition support
- Document formatting

Supported file extensions: `.gql`, `.gcypher`, `.cypher`, `.pgql`
