# Geode Claude Plugin — v2.1.0 Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resync the Geode Claude plugin with `geode v0.5.11`, expand it with agents and skills, and audit the marketplace integration so the plugin is current, complete, and installable.

**Architecture:** The plugin is a static configuration package read by Claude Code (no compiled code). It exposes a server stub via `.mcp.json`, an LSP stub via `.lsp.json`, slash commands under `commands/`, a session-start health hook under `hooks/`, plus the new `agents/` and `skills/` directories Claude Code auto-discovers. The plan splits work into (A) syncing existing files to match `geode v0.5.11`, (B) authoring new agents/skills, (C) wiring the parent `geode` monorepo's marketplace manifest, and (D) validation.

**Tech Stack:** Markdown (commands, agents, skills, docs); JSON (plugin/MCP/LSP manifests, marketplace); Bash (session-start hook); `jq`/`shellcheck`/`markdownlint` for validation; the `geode` CLI itself for runtime smoke tests.

---

## Working context for the implementer

Read these before starting:

- `/data/home/benji/src/devnw/codepros/geode/geode-claude-plugin/` — the plugin under edit (`pwd` for the working directory).
- `/data/home/benji/src/devnw/codepros/geode/geode/` — the `geode` source tree. Branch tip is `v0.5.11` (HEAD). Use this as the source of truth for CLI flags, MCP tool inventory, and serve options.
- `/data/home/benji/src/devnw/codepros/geode/geode/src/cli/cli_dispatcher.zig` — authoritative top-level command list and per-subcommand flag specs.
- `/data/home/benji/src/devnw/codepros/geode/geode/src/cli/main.zig` — authoritative help text strings for `serve`, `query`, `shell`.
- `/data/home/benji/src/devnw/codepros/geode/geode/src/mcp/{tools,resources,prompts}.zig` — authoritative MCP tool/resource/prompt inventory.
- The local `/usr/bin/geode` is **v0.3.8 and stale**. Trust the source tree, not the installed binary, for CLI behavior.

Repository facts the plan locks in:

- **`geode --help` lists**: `serve query shell lsp backup restore migrate auth login logout user role policy grant revoke completion mcp` plus the dispatcher also routes `fle`, `storage`, `apikey` (no `session`, no `authn`).
- **MCP tools (9)**: `query schema explain catalogs graphs validate complete hover diagnostics`.
- **MCP resources (3)**: `geode://default/default/schema`, `geode://default/default/stats`, `geode://config`. Resource templates exist for arbitrary `{catalog}/{graph}/...` URIs.
- **MCP prompts (7)**: `find_nodes find_relationships create_node create_relationship shortest_path graph_analysis pattern_match`.
- **`mcp serve` transports**: `--stdio` (default if no `--port`); `--port <int>` for HTTP. Endpoint flag is `-e/--endpoint host:port` — **no scheme prefix**.
- **`serve` flags exposed in help**: `--data-dir --listen --cert --key --log-level --idle-timeout --persist-interval`. The dispatcher additionally accepts `--listen-grpc <addr:port>` (hidden from help but real). Log levels are `debug|info|warn|error` (not `trace|critical`).
- **Audit flags (global)**: `--audit`, `--audit-syslog <host:port>`, `--audit-file <path>`, `--audit-eventlog [source]`.
- **DSN format**: `<scheme>://[user:pass@]host[:port][?key=value]`. Schemes: `quic://` (default, port 3141), `grpc://` (port 50051). Bare `host:port` defaults to QUIC.
- **Insecure flag**: `--insecure-tls-skip-verify` (canonical), `--insecure` (deprecated alias).
- **Output formats**: `query` accepts `json|table|csv|dot`; `shell` accepts `json|table|csv`.
- **Auth subcommands**: `login logout token init reseal verify` (the last three are offline graph-store ops requiring `--data-dir`).
- **Migrate subcommands**: `status run|up create sign`.
- **Backup subcommands**: `create list info cleanup`.
- **No `session` or `authn` top-level commands** (despite the v2.0.0 plugin claiming both).

---

## File Structure

### Files modified

| Path | Why |
|------|-----|
| `.claude-plugin/plugin.json` | Version bump 2.0.0 → 2.1.0, add `keywords`/`homepage` metadata. |
| `.lsp.json` | Verify args still match `geode lsp`; no semantic change expected. |
| `.mcp.json` | Switch `args` from `["mcp", "serve"]` to `["mcp", "--stdio"]` to match the documented stdio invocation. |
| `hooks/check-geode.sh` | Enforce minimum version `v0.5.11`; refresh installation hints (APT, Nix, Docker, source); use the modern command names. |
| `commands/status.md` | Replace stale CLI table (drop `session`/`authn`; reorder; correct log levels). |
| `commands/mcp-status.md` | Replace `mcp serve --http --port 8080` with `mcp serve --port 8080`; replace `-e quic://...` with `-e host:port`; document the stdio default and HTTP variant correctly. |
| `commands/syntax.md` | Add transaction control, comments, audit/log notes; align wire-protocol section with `quic://` + `grpc://` DSNs. |
| `commands/query.md` | Add output formats (`json\|table\|csv\|dot`), new flags (`--page-size --timeout --retry --graph --begin --commit --rollback`), DSN section, mTLS section. |
| `commands/examples.md` | Add a vector-search-by-cosine example, add an authenticated-DSN example, add a `migrate sign` example. |
| `README.md` | Major rewrite: APT/Nix/Docker install paths; new CLI table; DSN section; mTLS section; audit section; updated marketplace install. |
| `CHANGELOG.md` | Add `[2.1.0] - 2026-05-06` entry with grouped Added/Changed/Fixed bullets. |
| `docs/REQUIREMENTS.md` | Bump "Last Updated"; expand the implemented-features matrix to cover agents, skills, audit, DSN. |
| `docs/GAP_ANALYSIS.md` | Bump "Last Updated"; keep "no open gaps" if true after the sync. |

### Files created in plugin

| Path | Responsibility |
|------|----------------|
| `agents/gql-query-writer.md` | Subagent that composes GQL queries from a natural-language description. |
| `agents/gql-debugger.md` | Subagent that diagnoses GQL parse, runtime, and performance failures. |
| `agents/graph-schema-designer.md` | Subagent that reviews/proposes property graph schemas (labels, relationships, properties, indexes). |
| `skills/gql-syntax-reference/SKILL.md` | Progressive-disclosure deep reference of GQL syntax (keywords, operators, types, comments, transactions). |
| `skills/gql-query-patterns/SKILL.md` | Library of common GQL patterns (filters, aggregations, vector search, paths, MERGE, transactions, EXPLAIN/PROFILE). |
| `skills/geode-mcp-tools/SKILL.md` | How to use each Geode MCP tool effectively (when to use `validate` vs `diagnostics`, etc.). |

### Files created outside plugin

| Path | Responsibility |
|------|----------------|
| `../geode/.claude-plugin/marketplace.json` | Marketplace manifest in the `geode` monorepo so `claude plugin marketplace add ./geode` actually works. References this plugin by relative path. |

---

## No-skip rules for the implementer

These come from the user's instructions and constraints discovered above. Failing any one is a plan failure.

1. **Pin minimum geode version `v0.5.11`** in `hooks/check-geode.sh`. Older binaries must produce a clear error, not a silent pass.
2. **Do not invent CLI surface**. If a flag, subcommand, or output format is not in `geode <cmd> --help` (run against an up-to-date binary) or the `cli_dispatcher.zig` flag specs, do not reference it in plugin docs.
3. **Match the `mcp serve` interface from `geode/src/mcp/server.zig` and `cli_dispatcher.zig`.** Specifically: `--stdio` is the AI-client default; `--port <int>` is HTTP; `-e/--endpoint` takes `host:port`, not a DSN URL.
4. **One commit per task.** Do not batch.
5. **Run validation after every file change** that touches a JSON or shell file. (`jq empty`, `shellcheck`, `bash -n`).
6. **No new dependencies.** This plugin must remain installable from a single git clone with no `npm install` / `pip install` / `cargo build`.
7. **Frontmatter is required** on every command, agent, and skill markdown file (`description:` minimum).

---

### Task 1: Branch + plan checkpoint

**Files:**

- Modify: existing working tree (no file edit yet)

- [ ] **Step 1: Verify clean worktree**

Run: `git status`
Expected: `nothing to commit, working tree clean` (the plan file at `docs/superpowers/plans/2026-05-06-plugin-sync-v2.1.0.md` is already committed-tracked or will be by the end of this task).

- [ ] **Step 2: Create feature branch**

```bash
git checkout -b chore/sync-v2.1.0
```text

- [ ] **Step 3: Stage and commit the plan**

```bash
git add docs/superpowers/plans/2026-05-06-plugin-sync-v2.1.0.md
git commit -m "docs(plan): plugin v2.1.0 sync implementation plan"
```text

---

### Task 2: Bump `plugin.json` to v2.1.0

**Files:**

- Modify: `.claude-plugin/plugin.json`

- [ ] **Step 1: Write the failing assertion**

Run: `jq -e '.version == "2.1.0"' .claude-plugin/plugin.json`
Expected: exit 1 (current value is `"2.0.0"`).

- [ ] **Step 2: Update `.claude-plugin/plugin.json`**

Replace file contents with:

```json
{
  "name": "geode",
  "description": "Geode GQL/ISO 39075 Language Server, MCP tools, agents, and skills for property graph development",
  "version": "2.1.0",
  "author": {
    "name": "Developer Network",
    "url": "https://gitlab.com/devnw/codepros/geode"
  },
  "homepage": "https://geodedb.com",
  "repository": "https://gitlab.com/devnw/codepros/geode/geode-claude-plugin",
  "license": "Apache-2.0",
  "keywords": [
    "geode",
    "gql",
    "graph-database",
    "iso-39075",
    "cypher",
    "lsp",
    "mcp"
  ]
}
```text

- [ ] **Step 3: Validate JSON**

Run:

```bash
jq -e . .claude-plugin/plugin.json
jq -e '.version == "2.1.0" and .keywords | length >= 5' .claude-plugin/plugin.json
```text

Expected: prints the parsed object, exits 0.

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "chore: bump plugin to v2.1.0 with keywords and homepage"
```text

---

### Task 3: Update `hooks/check-geode.sh` to enforce v0.5.11+

**Files:**

- Modify: `hooks/check-geode.sh`

- [ ] **Step 1: Define the version comparison contract**

The script must:

1. Print `geode is available: <path>` and version when present.
2. **Fail (exit 2) with a clear error if version < 0.5.11.**
3. Treat unparseable version as "unknown — recommend upgrade" (warn, exit 0).
4. Refresh install hints: APT, Nix, Docker Hub (`codeprosorg/geode`), source build.

- [ ] **Step 2: Replace `hooks/check-geode.sh` with**

```bash
#!/usr/bin/env bash
# Check for geode installation and minimum supported version.

set -u

MIN_VERSION="0.5.11"
PLUGIN_VERSION="2.1.0"

# Compare two semver-ish strings: returns 0 if $1 >= $2, 1 otherwise.
version_ge() {
    # Strip leading 'v' and any -suffix.
    local a b
    a=${1#v}; a=${a%%-*}
    b=${2#v}; b=${b%%-*}
    [ "$(printf '%s\n%s\n' "$b" "$a" | sort -V | head -n1)" = "$b" ]
}

print_install_hints() {
    cat <<'EOF'

Geode installation options:

  APT (Debian/Ubuntu):
    curl -fsSL https://apt.geodedb.com/geodedb-keyring.gpg \
      | sudo tee /usr/share/keyrings/geodedb-archive-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/geodedb-archive-keyring.gpg] https://apt.geodedb.com/ stable main" \
      | sudo tee /etc/apt/sources.list.d/geodedb.list
    sudo apt update && sudo apt install geode

  Nix:
    nix run github:codeprosorg/geode -- --version

  Docker:
    docker run --rm codeprosorg/geode:latest --version

  Build from source (Zig 0.16.0+):
    git clone https://gitlab.com/devnw/codepros/geode/geode.git
    cd geode && make build
    export PATH="$PWD/zig-out/bin:$PATH"

After installation, ensure 'geode' is in your PATH and reports >= v$MIN_VERSION.
EOF
}

if ! command -v geode >/dev/null 2>&1; then
    echo "Geode is not installed."
    print_install_hints
    exit 1
fi

GEODE_BIN=$(command -v geode)
echo "geode is available: $GEODE_BIN"

VERSION_RAW=$(geode --version 2>/dev/null | head -n1 || true)
echo "Version: ${VERSION_RAW:-(unknown)}"

if [ -z "${VERSION_RAW:-}" ]; then
    echo "Warning: geode did not report a version. Plugin requires v$MIN_VERSION+." >&2
    exit 0
fi

# Extract the first dotted version token (e.g. "0.5.11" out of "geode v0.5.11").
PARSED=$(printf '%s\n' "$VERSION_RAW" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)

if [ -z "$PARSED" ]; then
    echo "Warning: could not parse geode version from '$VERSION_RAW'. Plugin requires v$MIN_VERSION+." >&2
    exit 0
fi

if ! version_ge "$PARSED" "$MIN_VERSION"; then
    echo "Error: geode v$PARSED is older than the plugin's minimum (v$MIN_VERSION)." >&2
    echo "       Plugin version: $PLUGIN_VERSION" >&2
    print_install_hints
    exit 2
fi

echo
echo "LSP support: $(geode lsp --help 2>/dev/null | head -1 || echo 'not available')"
echo "MCP support: $(geode mcp --help 2>/dev/null | head -1 || echo 'not available')"
echo "Serve command: $(geode serve --help 2>/dev/null | head -1 || echo 'not available')"
exit 0
```text

- [ ] **Step 3: Lint and dry-run**

Run:

```bash
bash -n hooks/check-geode.sh
shellcheck hooks/check-geode.sh || true   # warn but do not fail; document any remaining warnings inline
chmod +x hooks/check-geode.sh
bash hooks/check-geode.sh || true          # local /usr/bin/geode is v0.3.8 — exit 2 is expected proof the gate works
```text

Expected: `bash -n` exits 0; `shellcheck` reports zero errors (warnings tolerated); the manual run prints the `Error: geode v0.3.8 is older...` message and exits with code 2.

- [ ] **Step 4: Verify the version comparator with edge cases**

Run:

```bash
bash -c 'source hooks/check-geode.sh; declare -f version_ge >/dev/null && \
  version_ge 0.5.11 0.5.11 && echo eq-ok && \
  version_ge 0.6.0 0.5.11 && echo gt-ok && \
  ! version_ge 0.5.10 0.5.11 && echo lt-ok && \
  version_ge 1.0.0 0.5.11 && echo major-ok'
```text

Expected output (in order): `eq-ok`, `gt-ok`, `lt-ok`, `major-ok`. (The script does not export the function, so the `source` may early-exit on the binary check. If sourcing fails, copy the function into a tmp file for the spot test.)

- [ ] **Step 5: Commit**

```bash
git add hooks/check-geode.sh
git commit -m "feat(hooks): enforce geode v0.5.11 minimum and refresh install hints"
```text

---

### Task 4: Tighten `.mcp.json` invocation

**Files:**

- Modify: `.mcp.json`

- [ ] **Step 1: Write the failing assertion**

Run: `jq -e '.mcpServers.geode.args == ["mcp","--stdio"]' .mcp.json`
Expected: exit 1.

- [ ] **Step 2: Replace `.mcp.json` with**

```json
{
  "mcpServers": {
    "geode": {
      "command": "geode",
      "args": ["mcp", "--stdio"],
      "env": {},
      "description": "Geode GQL graph database — query, schema, validate, complete, hover, diagnostics, explain, catalogs, graphs"
    }
  }
}
```text

- [ ] **Step 3: Validate**

Run: `jq -e '.mcpServers.geode.args == ["mcp","--stdio"]' .mcp.json`
Expected: prints `true`, exits 0.

- [ ] **Step 4: Commit**

```bash
git add .mcp.json
git commit -m "fix(mcp): pin --stdio transport for Claude Code MCP launches"
```text

---

### Task 5: Verify `.lsp.json` and explicitly comment file extensions

**Files:**

- Modify: `.lsp.json`

- [ ] **Step 1: Write the failing assertion**

Run: `jq -e '.gql.extensionToLanguage | keys | sort == [".cypher",".gcypher",".gql",".pgql"]' .lsp.json`
Expected: prints `true` (no change required if already correct). If `false`, fix in step 2.

- [ ] **Step 2: Replace `.lsp.json` with**

```json
{
  "gql": {
    "command": "geode",
    "args": ["lsp"],
    "extensionToLanguage": {
      ".gql": "gql",
      ".gcypher": "gql",
      ".cypher": "gql",
      ".pgql": "gql"
    }
  }
}
```text

- [ ] **Step 3: Validate**

Run: `jq -e '.gql.command == "geode" and (.gql.args | length == 1)' .lsp.json`
Expected: prints `true`, exits 0.

- [ ] **Step 4: Commit (skip if no diff)**

```bash
git diff --quiet -- .lsp.json || (git add .lsp.json && git commit -m "chore(lsp): re-attest LSP launcher contract")
```text

---

### Task 6: Rewrite `commands/status.md` against `geode v0.5.11`

**Files:**

- Modify: `commands/status.md`

- [ ] **Step 1: Replace `commands/status.md` with**

```markdown
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
```text

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

```text
--data-dir <path>         Data directory (default: ./data)
--listen <addr:port>      QUIC/TLS listen address (default: 0.0.0.0:3141)
--listen-grpc <addr:port> gRPC listen address (advanced; off by default)
--cert <path>             TLS certificate path (auto-generated if missing)
--key <path>              TLS private key path (auto-generated if missing)
--log-level <level>       debug | info | warn | error (default: info)
--idle-timeout <ms>       QUIC idle timeout in ms (default: 300000)
--persist-interval <ms>   Background persistence interval (default: 100)
```text

## Global Flags

```text
-v, --verbose              Verbose output
--config <path>            Configuration file path
--json                     Force JSON output for all subcommands
--audit                    Enable audit logging
--audit-syslog <host:port> Send audit events to a syslog server
--audit-file <path>        Write audit events to a file
--audit-eventlog [source]  Enable Windows Event Log (default source: Geode)
```text

## Transport

| Protocol | Default Port | TLS | Notes |
|----------|--------------|-----|-------|
| QUIC | 3141 | Required (TLS 1.3) | Recommended; high-performance UDP. |
| gRPC | 50051 | Optional | Standard HTTP/2; enable with `--listen-grpc`. |

## DSN Connection Strings

```text
quic://localhost:3141                   # QUIC (default scheme if omitted)
grpc://localhost:50051                  # gRPC
quic://user:pass@host:3141              # With credentials
quic://host:3141?page_size=500          # With options
host:3141                               # Bare host:port — defaults to QUIC
```text

## LSP Capabilities

- Hover documentation for GQL keywords, functions, types
- Code completion with triggers `.`, `:`, `$`
- Real-time syntax diagnostics
- Go-to-definition
- Document formatting

Supported file extensions: `.gql`, `.gcypher`, `.cypher`, `.pgql`.

## MCP Capabilities

The Geode MCP server exposes 9 tools (`query`, `schema`, `explain`, `catalogs`, `graphs`, `validate`, `complete`, `hover`, `diagnostics`), 3 resources, 4 resource templates, and 7 query-template prompts. See `/geode:mcp-status` for the full inventory.

```text

- [ ] **Step 2: Lint markdown**

Run: `markdownlint commands/status.md || true`
Expected: zero errors (warnings tolerated).

- [ ] **Step 3: Commit**

```bash
git add commands/status.md
git commit -m "docs(commands): align /geode:status with v0.5.11 CLI surface"
```text

---

### Task 7: Rewrite `commands/mcp-status.md` to match the real `mcp` interface

**Files:**

- Modify: `commands/mcp-status.md`

- [ ] **Step 1: Replace `commands/mcp-status.md` with**

```markdown
---
description: Check Geode MCP server status and available tools
---

# Geode MCP Status Check

Verify that the Geode MCP (Model Context Protocol) server is installed and accessible.

```bash
geode mcp --help
```text

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
```text

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
```text

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

The MCP server enforces authentication by default (bearer token) so tool calls are never anonymous. Disable only for local development by setting the server's `auth_mode` to `none` (see `geode mcp --help`).

```text

- [ ] **Step 2: Lint and commit**

```bash
markdownlint commands/mcp-status.md || true
git add commands/mcp-status.md
git commit -m "docs(commands): correct /geode:mcp-status invocation, transports, and inventory"
```text

---

### Task 8: Refresh `commands/syntax.md`

**Files:**

- Modify: `commands/syntax.md`

- [ ] **Step 1: Replace `commands/syntax.md` with**

```markdown
---
description: Quick reference for GQL syntax and keywords
---

# GQL Syntax Reference

Provide a quick reference for GQL (ISO/IEC 39075:2024). Focus on: "$ARGUMENTS"

If no specific topic is provided, give the overview below.

## Keywords

### Query Clauses
- `MATCH` — find patterns in the graph
- `WHERE` — filter results
- `RETURN` — specify output
- `ORDER BY` — sort (`ASC`/`DESC`)
- `LIMIT` / `OFFSET` — pagination
- `WITH` — chain query parts

### Modification
- `CREATE` — create nodes / relationships
- `MERGE` — create if not exists
- `SET` — update properties
- `DELETE` / `DETACH DELETE` — remove data

### Aggregation
- `GROUP BY` / `HAVING`

### Transactions (per session)
- `BEGIN`
- `COMMIT`
- `ROLLBACK`

### Query Analysis
- `EXPLAIN` — logical operator tree
- `PROFILE` — execute and return per-operator metrics

### Comments
```gql
// single-line
/* block
   comment */
-- single-line (Geode extension)
```text

## Data Types

| Type | Example |
|------|---------|
| INTEGER | `42` |
| FLOAT | `3.14` |
| STRING | `'hello'` or `"hello"` |
| BOOLEAN | `TRUE`, `FALSE` |
| NULL | `NULL` |
| LIST | `[1, 2, 3]` |
| MAP | `{key: 'value'}` |
| VECTOR | `[0.1, 0.2, 0.3]` |

## Pattern Syntax

```text
(variable:Label {property: value})  -- Node
-[:RELATIONSHIP_TYPE]->             -- Directed relationship
<-[:TYPE]-                          -- Reverse direction
-[:TYPE]-                           -- Undirected
-[:TYPE*1..3]->                     -- Variable-length path
```text

## Functions

### Aggregation

`count()`, `sum()`, `avg()`, `min()`, `max()`, `collect()`

### String

`toLower()`, `toUpper()`, `trim()`, `substring()`, `replace()`

### List

`size()`, `head()`, `tail()`, `reverse()`, `range()`

### Math

`abs()`, `ceil()`, `floor()`, `round()`, `sqrt()`

### Vector (Geode extension)

`distance(vec, target, metric)`, `similarity()`, `cosine()`, `euclidean()`
Supported metrics: `'L2'`, `'cosine'`, `'dot'`, `'manhattan'`, `'chebyshev'`, `'hamming'`.

## Wire Protocol Messages

### Client → Server

| Message | Purpose |
|---------|---------|
| `HELLO` | Greeting (name, version, conformance) |
| `RUN_GQL` | Submit GQL with parameters |
| `PULL` | Request next page of results |
| `BEGIN` / `COMMIT` / `ROLLBACK` | Transaction demarcation |

### Server → Client

| Response | Description |
|----------|-------------|
| `SCHEMA` | Column descriptors (always first for a new statement) |
| `BINDINGS` | Result rows + ordering / pagination metadata |
| `EXPLAIN` | Logical operator array (JSON) |
| `PROFILE` | Per-operator metrics (JSON) |
| `ERROR` | ISO/IEC 39075 status code + detail |

## Transport

All messages travel over **QUIC+TLS 1.3** (default port 3141) or **gRPC** (port 50051). QUIC adds stream multiplexing and 0-RTT resumption.

## DSN Connection Strings

```text
quic://localhost:3141                        # QUIC (recommended)
grpc://localhost:50051                       # gRPC
quic://user:pass@localhost:3141              # With auth
quic://localhost:3141?page_size=500          # With options
localhost:3141                               # Scheme-less (defaults to QUIC)
```text

Provide detailed explanations based on the user's specific question.

```text

- [ ] **Step 2: Commit**

```bash
markdownlint commands/syntax.md || true
git add commands/syntax.md
git commit -m "docs(commands): refresh /geode:syntax with comments, vector metrics, DSN"
```text

---

### Task 9: Refresh `commands/query.md`

**Files:**

- Modify: `commands/query.md`

- [ ] **Step 1: Replace `commands/query.md` with**

```markdown
---
description: Help write or debug a GQL query
---

# GQL Query Assistant

Help the user write, debug, or optimize a GQL query.

User's request: "$ARGUMENTS"

## Triage

1. **Writing a new query**: ask about
   - desired output and shape
   - node labels / relationship types
   - filters
   - sort + pagination
2. **Debugging**: scan for
   - missing `RETURN`
   - bracket / parenthesis mismatch
   - type mismatch in `WHERE`
   - missing string quotes
   - variables defined in `MATCH` but unused / shadowed in `RETURN`
   - unclosed `BEGIN` (no `COMMIT` / `ROLLBACK`)
3. **Optimizing**:
   - add indexes for hot filter properties
   - filter early (`WHERE` before `WITH`)
   - use parameters (`$param`) instead of inline values
   - `EXPLAIN` for the logical plan
   - `PROFILE` for per-operator timing + memory

## Connecting to Geode

Clients use a unified DSN format:

```text

quic://localhost:3141                        # QUIC, default
grpc://localhost:50051                       # gRPC
quic://user:pass@geode.example.com:3141      # With credentials
quic://localhost:3141?page_size=500          # With options
localhost:3141                               # Bare host:port — defaults to QUIC

```text

| Protocol | Default Port | TLS | Notes |
|----------|--------------|-----|-------|
| QUIC | 3141 | Required (TLS 1.3) | High-performance UDP transport |
| gRPC | 50051 | Optional | Standard HTTP/2 |

## CLI Query Flags (`geode query`)

```text

--dsn <dsn>                Connection DSN (overrides --server / --grpc)
--server <addr:port>       Server address (default 127.0.0.1:3141)
--grpc                     Use gRPC transport
-g, --graph <name>         Auto-prepend USE GRAPH <name>
-f, --file <path>          Execute statements from a file
--format <fmt>             json | table | csv | dot (default: json)
--param <name> <value>     Add a query parameter (JSON literal); repeatable
--page-size <n>            Result page size (default: 128)
--timeout <secs>           Connection timeout (default: 30)
--retry <count>            Retry attempts on failure (default: 0)
--begin / --commit / --rollback  Transaction control
-U, --user / -P, --password      Authenticate with username + password
--no-saved-session         Don't auto-load saved session token
--insecure-tls-skip-verify Skip TLS verification (development only)
--ca-cert / --client-cert / --client-key  mTLS material

```text

## Transactions

```gql
BEGIN
-- multiple statements here
COMMIT      -- or ROLLBACK to abort
```text

## Query Analysis

```gql
EXPLAIN
MATCH (p:Person)-[:KNOWS]->(f:Person)
RETURN p.name, f.name
```text

`PROFILE` runs the query and returns per-operator metrics: rows in/out, wall clock, allocation, spill.

## GQL vs Cypher Differences

Geode implements ISO GQL (ISO/IEC 39075:2024) with Cypher compatibility:

- `MATCH`, `CREATE`, `RETURN` — same as Cypher
- Use `TRUE` / `FALSE` (uppercase)
- String concatenation with `||`
- Comments: `//`, `/* */`, plus `--` (Geode extension)

Provide working code examples and explain the syntax.

```text

- [ ] **Step 2: Commit**

```bash
markdownlint commands/query.md || true
git add commands/query.md
git commit -m "docs(commands): expand /geode:query with v0.5.11 CLI flags, DSN, transactions"
```text

---

### Task 10: Refresh `commands/examples.md`

**Files:**

- Modify: `commands/examples.md`

- [ ] **Step 1: Insert two new sections after the "Vector Search" section**

Section to add — **Authenticated DSN**:

```markdown
## Authenticated Connection (CLI)

```bash
# DSN with embedded credentials
geode query --dsn quic://alice:s3cret@graph.example.com:3141 \
  "MATCH (n:Person) RETURN n.name LIMIT 5"

# Reusable saved session
geode auth login -U alice --save-session
geode query "MATCH (n) RETURN count(n)"
```text

```text

Section to add — **Migrations & Backup**:

```markdown
## Migrations and Backup

```bash
# Create + sign a migration
geode migrate create add_unique_email_index
geode migrate sign migrations/2026_05_06_add_unique_email_index.gql

# Apply pending migrations
geode migrate up

# Backup + restore
geode backup create --output ./backup.gz
geode backup list
geode restore ./backup.gz --yes
```text

```text

- [ ] **Step 2: Add a cosine vector example before the existing L2 example**

```markdown
### Vector Search by Cosine Similarity

```gql
MATCH (doc:Document)
WHERE distance(doc.embedding, $query_vector, 'cosine') < 0.2
RETURN doc.title, doc.content
ORDER BY distance(doc.embedding, $query_vector, 'cosine')
LIMIT 5
```text

```text

- [ ] **Step 3: Commit**

```bash
markdownlint commands/examples.md || true
git add commands/examples.md
git commit -m "docs(commands): add authenticated DSN, cosine vector, migrate/backup examples"
```text

---

### Task 11: Major `README.md` rewrite

**Files:**

- Modify: `README.md`

- [ ] **Step 1: Rewrite the Installation section**

Replace the existing **Installation** section (currently lines ~64–96) with:

```markdown
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
```text

#### Nix

```bash
nix run github:codeprosorg/geode -- --version
```text

#### Docker

```bash
docker run --rm codeprosorg/geode:latest --version
docker run -p 3141:3141/udp codeprosorg/geode:latest serve
```text

#### Build from Source (Zig 0.16.0+)

```bash
git clone https://gitlab.com/devnw/codepros/geode/geode.git
cd geode && make build
export PATH="$PWD/zig-out/bin:$PATH"
```text

Verify:

```bash
geode --version    # must report v0.5.11 or newer
```text

### Install the plugin (Claude Code)

The `geode` monorepo ships a marketplace manifest at `.claude-plugin/marketplace.json` that lists this plugin.

```bash
# From the parent of the geode monorepo
claude plugin marketplace add ./geode
claude plugin install geode@geode --scope user
```text

Scopes:

- `--scope user` — all projects (`~/.claude/settings.json`)
- `--scope project` — shared with the team (`.claude/settings.json`)
- `--scope local` — this machine only (`.claude/settings.local.json`)

### Test the plugin without installing

```bash
# From the geode monorepo root
claude --plugin-dir ./geode-claude-plugin
```text

```text

- [ ] **Step 2: Replace the CLI Commands table**

Find the existing `### CLI Commands` table and replace with the same canonical 18-row table from Task 6 (`commands/status.md`).

- [ ] **Step 3: Add a new section "Authentication & DSN" right before "LSP Features"**

```markdown
## Authentication & Transport

### DSN

All clients (CLI, MCP, drivers) use a unified DSN:

```text

quic://[user:pass@]host[:port][?key=value]   # default scheme
grpc://[user:pass@]host[:port][?key=value]   # gRPC
host[:port]                                  # bare host:port → QUIC

```text

| Protocol | Default Port | TLS |
|----------|--------------|-----|
| QUIC | 3141 | Required (TLS 1.3) |
| gRPC | 50051 | Optional |

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
```text

### Mutual TLS

Provide enterprise PKI material on any client subcommand:

```bash
--ca-cert /etc/ssl/ca.crt
--client-cert /etc/ssl/client.crt
--client-key  /etc/ssl/client.key
```text

### Audit Logging

Global flags (apply to any subcommand):

```text
--audit                     Enable audit logging
--audit-file <path>         Append events to a file
--audit-syslog <host:port>  Send events to a syslog server
--audit-eventlog [source]   Windows Event Log (default source: Geode)
```text

```text

- [ ] **Step 4: Update the "Plugin Structure" tree**

Replace the existing tree with:

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

```text

- [ ] **Step 5: Commit**

```bash
markdownlint README.md || true
git add README.md
git commit -m "docs(readme): full sync for v2.1.0 — install paths, DSN, auth, audit, structure"
```text

---

### Task 12: Add `CHANGELOG.md` v2.1.0 entry

**Files:**

- Modify: `CHANGELOG.md`

- [ ] **Step 1: Replace the file body with**

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-05-06

### Added
- Three subagents: `gql-query-writer`, `gql-debugger`, `graph-schema-designer`.
- Three progressive-disclosure skills: `gql-syntax-reference`, `gql-query-patterns`, `geode-mcp-tools`.
- Marketplace manifest in the `geode` monorepo so `claude plugin marketplace add ./geode` works.
- Minimum-version gate (`v0.5.11`) in `hooks/check-geode.sh`.
- Documentation for DSN connection strings, mTLS, and audit logging.
- New examples: authenticated DSN, cosine vector search, migration signing, backup/restore.

### Changed
- `.mcp.json` now launches `geode mcp --stdio` explicitly (was `mcp serve`).
- `commands/status.md` rewritten against `geode v0.5.11` CLI surface.
- `commands/mcp-status.md` corrected: `--port` (no `--http`), `-e host:port` (no scheme prefix).
- `commands/syntax.md` adds transactions, `--` comments, expanded vector metrics, DSN section.
- `commands/query.md` adds `--page-size`, `--timeout`, `--retry`, `--graph`, transaction flags, mTLS.
- `README.md` rewritten: APT/Nix/Docker/source install paths; DSN + auth + audit; updated structure tree.

### Fixed
- Removed references to non-existent `session` and `authn` top-level subcommands.
- Removed false claim that `mcp serve` accepts `--http` and DSN-style endpoint URLs.
- Corrected `geode serve --log-level` choices to `debug|info|warn|error`.

## [2.0.0] - 2026-01-26

Initial release with MCP support and resolved gaps.
```text

- [ ] **Step 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs(changelog): record v2.1.0"
```text

---

### Task 13: Add agent `gql-query-writer`

**Files:**

- Create: `agents/gql-query-writer.md`

- [ ] **Step 1: Create the directory**

```bash
mkdir -p agents
```text

- [ ] **Step 2: Write `agents/gql-query-writer.md`**

```markdown
---
name: gql-query-writer
description: Use when the user wants to compose a GQL (ISO/IEC 39075:2024) query from a natural-language description. Writes runnable queries against Geode, prefers parameters over inline literals, and validates with the MCP `validate` tool when available.
tools: Read, Grep, Glob
---

# GQL Query Writer

You translate a natural-language request into a single runnable GQL query. You output the query and a one-paragraph justification — nothing else.

## Inputs you expect

- Goal (what to retrieve / mutate)
- Available labels and relationship types (ask if unknown)
- Filters, sort order, pagination
- Whether the query is read-only or mutating

## Discipline

1. **Parameters over literals.** Use `$paramName` for any user-supplied value. Pass them via `--param` at runtime.
2. **Filter early.** Push predicates into `MATCH`/`WHERE` rather than post-`RETURN` filters.
3. **Limit by default.** Read queries get a sensible `LIMIT` unless the user explicitly asks for all rows.
4. **No casing tricks.** Boolean literals are uppercase (`TRUE`, `FALSE`).
5. **Comments.** Add a `// purpose:` comment at the top.
6. **No multi-statement scripts** unless the user asked for a transaction. If they did, wrap in `BEGIN` / `COMMIT`.

## Validation

If the Geode MCP server is reachable, call its `validate` tool with the produced query and surface any diagnostics before returning. If validation fails, fix and re-validate up to twice.

## Output template

```text

// purpose: <one-line goal>
<query>

Parameters:
  $name = <example>

Notes: <one paragraph on tradeoffs / indexes / variants>

```text

## Anti-patterns to refuse

- Hard-coding secrets / PII into the query.
- Returning entire nodes when only specific properties are needed.
- Cartesian-product `MATCH (a), (b)` without a relationship pattern unless explicitly requested.
```text

- [ ] **Step 3: Commit**

```bash
git add agents/gql-query-writer.md
git commit -m "feat(agents): add gql-query-writer subagent"
```text

---

### Task 14: Add agent `gql-debugger`

**Files:**

- Create: `agents/gql-debugger.md`

- [ ] **Step 1: Write `agents/gql-debugger.md`**

```markdown
---
name: gql-debugger
description: Use when a GQL query is failing or behaving unexpectedly. Diagnoses parse, runtime, and performance issues against Geode v0.5.11+ and proposes a minimal fix. Prefers MCP tools (`validate`, `diagnostics`, `explain`) over speculation.
tools: Read, Grep, Glob, Bash
---

# GQL Debugger

You are a triage agent for failing GQL queries. You produce: (1) a hypothesis, (2) the evidence supporting it, (3) the smallest viable fix.

## Triage order

1. **Parse first.** Run the MCP `validate` tool (or `geode query --dsn ... '<query>'` with `--format json`) and read the diagnostic. Most failures stop here.
2. **Variable scope.** Confirm every variable used in `RETURN` / `WHERE` / `WITH` was bound in an earlier `MATCH` / `CREATE` / `WITH`.
3. **Pattern mismatch.** Verify the labels, relationship types, and direction match the schema (`schema` MCP tool).
4. **Type mismatch.** Confirm property types in `WHERE` match the data (e.g. `INTEGER` vs `STRING`). Cast with `toInteger()` / `toString()` only when justified.
5. **Transaction state.** If `BEGIN` was issued and never `COMMIT`/`ROLLBACK`-ed, all subsequent statements may stall.
6. **Performance.** Run `EXPLAIN` and inspect for full `AllNodesScan`, missing index hits, or large `Cartesian`. Add an index or rewrite.

## Output template

```text

Hypothesis: <one sentence>
Evidence:

- <signal 1>
- <signal 2>
Fix:
  <minimal patched query>

Why this works:
  <one paragraph>

```text

## Hard rules

- **Do not** rewrite the user's whole query when a one-token edit fixes it.
- **Do not** suggest schema changes (CREATE INDEX, etc.) without confirming the symptom requires one.
- **Cite the diagnostic** — paste the exact error code/message Geode returned, do not paraphrase.
```text

- [ ] **Step 2: Commit**

```bash
git add agents/gql-debugger.md
git commit -m "feat(agents): add gql-debugger subagent"
```text

---

### Task 15: Add agent `graph-schema-designer`

**Files:**

- Create: `agents/graph-schema-designer.md`

- [ ] **Step 1: Write `agents/graph-schema-designer.md`**

```markdown
---
name: graph-schema-designer
description: Use when the user is designing or reviewing a property graph schema for Geode. Produces a node-label / relationship-type / property / index plan that matches the user's queries — not a generic ERD.
tools: Read, Grep, Glob
---

# Graph Schema Designer

You design property graph schemas with the queries already in mind. A schema is wrong if the most-frequent query needs a sub-optimal traversal.

## Inputs you expect

- The 3–5 queries the schema must serve well.
- Read/write ratio.
- Cardinality estimates (rough is fine).
- Whether vector search is involved.

## Output sections (in order)

1. **Node labels** — one bullet per label with the property list (name, type, indexed?).
2. **Relationship types** — one bullet per type with direction, source, target, and any properties.
3. **Indexes** — explicit `CREATE INDEX` statements for the properties that filter the listed queries.
4. **Vector indexes** (only if applicable) — HNSW config (dimension, metric, M, efConstruction).
5. **Sample queries** — for each input query, paste the query that would actually run on this schema.
6. **Tradeoffs** — denormalization, write amplification, hot supernodes.

## Hard rules

- **Don't model what isn't queried.** A property without a query that uses it is a bug, not a feature.
- **Prefer relationships to JSON blobs.** If the data has structure the user will traverse, model the edges.
- **Time-series**: prefer many `:Event` nodes connected by `[:NEXT]` chains over giant `events` arrays on one node.
- **Vector dimensions** must come from the embedding model spec, not be guessed.
```text

- [ ] **Step 2: Commit**

```bash
git add agents/graph-schema-designer.md
git commit -m "feat(agents): add graph-schema-designer subagent"
```text

---

### Task 16: Add skill `gql-syntax-reference`

**Files:**

- Create: `skills/gql-syntax-reference/SKILL.md`

- [ ] **Step 1: Create the directory**

```bash
mkdir -p skills/gql-syntax-reference
```text

- [ ] **Step 2: Write `skills/gql-syntax-reference/SKILL.md`**

```markdown
---
name: gql-syntax-reference
description: Use when writing, reviewing, or debugging GQL (ISO/IEC 39075:2024) and you need an authoritative reference for keywords, operators, types, transactions, comments, vector functions, or wire-protocol behavior. Loaded on demand to avoid bloating the default context.
---

# GQL Syntax Reference

Geode implements **ISO/IEC 39075:2024 (GQL)** with Cypher compatibility.

## Statement structure

```text

<reading clauses> <projection> [<post-projection ops>]

reading      : MATCH | OPTIONAL MATCH | WITH <reading>
projection   : RETURN <expr-list>
post-proj    : ORDER BY <expr-list> | LIMIT <int> | OFFSET <int>
mutation     : CREATE | MERGE | SET | DELETE | DETACH DELETE

```text

## Patterns

```text

(v:Label {key: value})            # node binding
(v:Label1:Label2)                 # multi-label
-[:TYPE]->                        # outbound directed
<-[:TYPE]-                        # inbound
-[:TYPE]-                         # undirected
-[r:TYPE {prop: val}]->           # bound relationship variable
-[:TYPE*1..3]->                   # variable-length, hops 1..3
-[:TYPE*..]->                     # zero or more

```text

## Boolean and null logic

- `TRUE`, `FALSE`, `NULL` are uppercase.
- Three-valued logic: `NULL AND TRUE = NULL`, `NULL OR TRUE = TRUE`.
- Use `IS NULL` / `IS NOT NULL` — never `= NULL`.

## Comments

```gql
// line comment
/* block
   comment */
-- line comment (Geode extension)
```text

## Transactions

```gql
BEGIN
MATCH (a:Account {id: $from}) SET a.balance = a.balance - $amt
MATCH (b:Account {id: $to})   SET b.balance = b.balance + $amt
COMMIT      -- or ROLLBACK
```text

Geode uses MVCC + Serializable Snapshot Isolation (SSI). A transaction that contends will fail at `COMMIT` with an SSI error code; retry from `BEGIN`.

## Aggregations

```text
count(*)         total rows
count(x)         non-null x
count(DISTINCT x)
sum / avg / min / max / collect / stddev / percentileCont(x, p)
```text

`GROUP BY` is implicit on non-aggregated `RETURN` columns. `HAVING` filters groups.

## String / list / math

| Family | Examples |
|--------|----------|
| String | `toLower`, `toUpper`, `trim`, `substring(s, start, len)`, `replace(s, find, with)`, `split(s, sep)` |
| List   | `size`, `head`, `tail`, `reverse`, `range(start, end[, step])`, `[x IN list WHERE ...]` |
| Math   | `abs`, `ceil`, `floor`, `round`, `sqrt`, `log`, `pi()`, `rand()` |

## Vector (Geode extension)

```gql
distance(vec, target, metric)
similarity(vec, target, metric)        // 1 - distance
```text

Metrics: `'L2'`, `'cosine'`, `'dot'`, `'manhattan'`, `'chebyshev'`, `'hamming'`.

## EXPLAIN / PROFILE

```gql
EXPLAIN MATCH (n) RETURN n              -- logical plan only, no execution
PROFILE MATCH (n) RETURN n              -- runs and reports per-operator metrics
```text

`PROFILE` returns per-operator: rows in/out, wall ms, allocation bytes, spill bytes.

## Error codes (ISO/IEC 39075)

Errors use a five-letter SQLSTATE-style code, e.g. `42000` (syntax), `42P01` (undefined relation), `40001` (serialization failure). Geode-specific codes start with `G`.

## See also

- `skills/gql-query-patterns` for runnable templates
- `commands/syntax.md` for the at-a-glance summary

```text

- [ ] **Step 3: Commit**

```bash
markdownlint skills/gql-syntax-reference/SKILL.md || true
git add skills/gql-syntax-reference/SKILL.md
git commit -m "feat(skills): add gql-syntax-reference progressive-disclosure skill"
```text

---

### Task 17: Add skill `gql-query-patterns`

**Files:**

- Create: `skills/gql-query-patterns/SKILL.md`

- [ ] **Step 1: Create directory and write `skills/gql-query-patterns/SKILL.md`**

```bash
mkdir -p skills/gql-query-patterns
```text

```markdown
---
name: gql-query-patterns
description: Use when you need a runnable GQL template for a known shape — filtered scan, aggregation, variable-length path, MERGE upsert, vector kNN, transactional transfer, or EXPLAIN/PROFILE. Each template is parameterized.
---

# GQL Query Patterns

Each pattern is the smallest correct version. Adjust labels, relationship types, and parameters.

## 1. Filtered scan with projection

```gql
MATCH (p:Person)
WHERE p.age >= $minAge AND p.city = $city
RETURN p.name, p.age
ORDER BY p.age DESC
LIMIT $limit
```text

## 2. One-hop relationship

```gql
MATCH (a:Person {id: $id})-[:KNOWS]->(b:Person)
RETURN b.name
```text

## 3. Variable-length path

```gql
MATCH path = (a:Person {id: $id})-[:KNOWS*1..$maxHops]-(b:Person)
WHERE b.id <> $id
RETURN b.name, length(path) AS hops
ORDER BY hops
LIMIT $limit
```text

## 4. Aggregation with GROUP BY / HAVING

```gql
MATCH (p:Person)-[:LIVES_IN]->(c:City)
RETURN c.name, count(p) AS population, avg(p.age) AS avg_age
GROUP BY c.name
HAVING count(p) >= $minPop
ORDER BY population DESC
```text

## 5. MERGE upsert

```gql
MERGE (u:User {id: $id})
ON CREATE SET u.created = datetime(), u.email = $email
ON MATCH  SET u.last_seen = datetime()
RETURN u
```text

## 6. Vector kNN by cosine

```gql
MATCH (d:Document)
WHERE d.embedding IS NOT NULL
RETURN d.title, distance(d.embedding, $query, 'cosine') AS score
ORDER BY score
LIMIT $k
```text

## 7. Transactional transfer

```gql
BEGIN
MATCH (a:Account {id: $from})
WHERE a.balance >= $amount
SET a.balance = a.balance - $amount

MATCH (b:Account {id: $to})
SET b.balance = b.balance + $amount

RETURN a.balance AS from_balance, b.balance AS to_balance
COMMIT
```text

## 8. EXPLAIN / PROFILE

```gql
EXPLAIN
MATCH (p:Person)-[:KNOWS]->(f:Person)
WHERE p.age > $minAge
RETURN p.name, f.name
```text

```gql
PROFILE
MATCH (p:Person)-[:KNOWS]->(f:Person)
WHERE p.age > $minAge
RETURN p.name, f.name
```text

## 9. Detach delete (relationships first)

```gql
MATCH (n:Tombstone) DETACH DELETE n
```text

## 10. WITH chaining for staged filtering

```gql
MATCH (p:Person)-[:KNOWS]->(f:Person)
WITH p, count(f) AS friend_count
WHERE friend_count >= $minFriends
RETURN p.name, friend_count
ORDER BY friend_count DESC
LIMIT $limit
```text

## Cross-references

- See `skills/gql-syntax-reference` for keyword/operator/type definitions.
- See `commands/examples.md` for a smaller curated set.

```text

- [ ] **Step 2: Commit**

```bash
markdownlint skills/gql-query-patterns/SKILL.md || true
git add skills/gql-query-patterns
git commit -m "feat(skills): add gql-query-patterns template library"
```text

---

### Task 18: Add skill `geode-mcp-tools`

**Files:**

- Create: `skills/geode-mcp-tools/SKILL.md`

- [ ] **Step 1: Create directory and write file**

```bash
mkdir -p skills/geode-mcp-tools
```text

```markdown
---
name: geode-mcp-tools
description: Use when deciding which Geode MCP tool to call (validate vs diagnostics, query vs explain, schema vs catalogs/graphs) or when chaining tools to answer a graph question. Loaded on demand.
---

# Geode MCP Tools — Practical Guide

The Geode MCP server exposes 9 tools. They split into two groups:

| Group | Tools | Needs server? |
|-------|-------|---------------|
| Server-backed | `query`, `schema`, `explain`, `catalogs`, `graphs` | Yes (a running `geode serve`) |
| LSP-backed (offline) | `validate`, `complete`, `hover`, `diagnostics` | No |

## Tool selection cheatsheet

- **"Is this query syntactically valid?"** → `validate`. No server needed.
- **"Show me everything wrong with this query."** → `diagnostics` (alias of `validate`, returns the same shape but Claude tends to prefer `diagnostics` semantically when the user said "diagnose").
- **"Run it."** → `query`. Always check `validate` first if the cost of failure is high.
- **"How would the engine run this?"** → `explain`. Returns the logical operator tree only.
- **"What labels and properties exist?"** → `schema`.
- **"What graphs are in catalog X?"** → `graphs` (with `catalog`).
- **"What catalogs are there?"** → `catalogs`.
- **"What can I type next here?"** → `complete` with `query`/`line`/`column`.
- **"What does this token mean?"** → `hover` with `query`/`line`/`column`.

## Common chains

### "Is this query safe to run?"
1. `validate` — bail if errors.
2. `explain` — bail if the plan does an `AllNodesScan` larger than the user accepts.
3. `query` — execute.

### "Author a query against an unknown DB."
1. `catalogs` → pick one (default `default`).
2. `graphs` (with `catalog`) → pick one.
3. `schema` → see labels and relationships.
4. Compose query, `validate`, then `query`.

### "Why is this slow?"
1. `explain` — inspect the plan; flag full scans, large cartesian, unbounded variable-length paths.
2. If still mysterious, run with `PROFILE` from a CLI to get per-operator metrics (MCP `query` does not expose `PROFILE` output by default).

## Resources

| URI | Use |
|-----|-----|
| `geode://default/default/schema` | Snapshot of the schema for the default catalog/graph |
| `geode://default/default/stats`  | Node/relationship/index counts |
| `geode://config`                 | Server version + GQL conformance |

Templates exist for arbitrary `{catalog}/{graph}/{node|relationship}` URIs.

## Prompts

7 query-template prompts: `find_nodes`, `find_relationships`, `create_node`, `create_relationship`, `shortest_path`, `graph_analysis`, `pattern_match`. Use these when you want a starting query that the user will edit, not when you want a final answer.

## Error patterns

- `Error: Failed to initialize client` — server unreachable. Confirm `geode serve` is running and the endpoint matches.
- `Error: AuthenticationFailed` — the MCP server's bearer token is set but the client did not present it. Configure `GEODE_MCP_TOKEN` or run with `auth_mode=none` for local dev only.
- `validate` returning empty `diagnostics` array means the query parses cleanly — that is success, not "no information".
```text

- [ ] **Step 2: Commit**

```bash
markdownlint skills/geode-mcp-tools/SKILL.md || true
git add skills/geode-mcp-tools
git commit -m "feat(skills): add geode-mcp-tools selection guide"
```text

---

### Task 19: Create / update marketplace manifest in `../geode`

**Files:**

- Create: `../geode/.claude-plugin/marketplace.json`

- [ ] **Step 1: Confirm the parent monorepo state**

Run:

```bash
ls ../geode/.claude-plugin 2>/dev/null || echo "missing"
```text

If `missing`, create it:

```bash
mkdir -p ../geode/.claude-plugin
```text

- [ ] **Step 2: Write `../geode/.claude-plugin/marketplace.json`**

```json
{
  "name": "geode",
  "owner": {
    "name": "Developer Network",
    "url": "https://gitlab.com/devnw/codepros/geode"
  },
  "description": "Geode graph database marketplace — Claude Code plugins for GQL development.",
  "metadata": {
    "version": "1.0.0",
    "homepage": "https://geodedb.com"
  },
  "plugins": [
    {
      "name": "geode",
      "source": "./geode-claude-plugin",
      "description": "GQL Language Server, MCP tools, agents, and skills for Geode",
      "version": "2.1.0",
      "author": "Developer Network",
      "homepage": "https://gitlab.com/devnw/codepros/geode/geode-claude-plugin",
      "license": "Apache-2.0",
      "category": "database",
      "tags": ["gql", "graph", "iso-39075", "lsp", "mcp"]
    }
  ]
}
```text

- [ ] **Step 3: Validate**

Run:

```bash
jq -e '.plugins[0].source == "./geode-claude-plugin"' ../geode/.claude-plugin/marketplace.json
jq -e '.plugins[0].version == "2.1.0"' ../geode/.claude-plugin/marketplace.json
```text

Expected: each prints `true`.

- [ ] **Step 4: Commit in the geode monorepo**

```bash
( cd ../geode \
  && git add .claude-plugin/marketplace.json \
  && git commit -m "chore(plugins): add Claude Code marketplace manifest pointing at geode-claude-plugin v2.1.0" )
```text

> **Confirmation gate:** because this commit lands in a different repo than the plugin's, pause here and surface the diff to the user before proceeding. Do **not** push.

---

### Task 20: Refresh `docs/REQUIREMENTS.md` and `docs/GAP_ANALYSIS.md`

**Files:**

- Modify: `docs/REQUIREMENTS.md`
- Modify: `docs/GAP_ANALYSIS.md`

- [ ] **Step 1: Update `docs/REQUIREMENTS.md`**

Bump the `Last Updated` line to `2026-05-06`. Append three new tables (Agents, Skills, Marketplace) to the existing structure:

```markdown
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
```text

- [ ] **Step 2: Update `docs/GAP_ANALYSIS.md`**

Bump `Last Updated` to `2026-05-06`. Keep the body as "no open gaps" since the v2.1.0 sync resolves the staleness gap that motivated the plan.

- [ ] **Step 3: Commit**

```bash
git add docs/REQUIREMENTS.md docs/GAP_ANALYSIS.md
git commit -m "docs: refresh requirements + gap analysis for v2.1.0"
```text

---

### Task 21: End-to-end validation

**Files:**

- None (read-only checks)

- [ ] **Step 1: JSON schema sanity**

Run:

```bash
for f in .claude-plugin/plugin.json .lsp.json .mcp.json hooks/hooks.json ../geode/.claude-plugin/marketplace.json; do
  echo "== $f =="
  jq -e . "$f" >/dev/null && echo OK || { echo FAIL; exit 1; }
done
```text

Expected: each file prints `== ... ==` then `OK`.

- [ ] **Step 2: Shell hook sanity**

Run:

```bash
bash -n hooks/check-geode.sh
shellcheck hooks/check-geode.sh || true
```text

Expected: `bash -n` exits 0; shellcheck reports zero errors.

- [ ] **Step 3: Markdown lint (warnings tolerated)**

Run:

```bash
find commands agents skills docs -name '*.md' -print0 | xargs -0 -n1 markdownlint || true
markdownlint README.md CHANGELOG.md || true
```text

Expected: no errors above the project's existing baseline.

- [ ] **Step 4: Frontmatter audit**

Run:

```bash
for f in commands/*.md agents/*.md skills/*/SKILL.md; do
  awk 'NR==1 && /^---/{ok=1} NR<20 && /^description:/{got_desc=1} END{if(!ok||!got_desc){print FILENAME": missing frontmatter"; exit 1}}' "$f"
done
```text

Expected: no output (every file has frontmatter with a `description:` line). Any file printed is a failure — fix and rerun.

- [ ] **Step 5: Plugin loads in Claude Code**

Run (interactively):

```bash
claude --plugin-dir . --help-plugins 2>&1 | head -40
```text

Expected: the binary lists `geode` as an installed plugin and surfaces the slash commands. If `--help-plugins` is unavailable in the local Claude Code build, fall back to launching `claude --plugin-dir .` and confirming `/geode:status` is listed.

- [ ] **Step 6: Hook smoke test**

Run:

```bash
bash hooks/check-geode.sh; echo "exit=$?"
```text

Expected: with the local stale `geode v0.3.8`, exit code is `2` and the message includes `older than the plugin's minimum`. After upgrading to `v0.5.11+`, exit code is `0` with full LSP/MCP/serve summary lines.

- [ ] **Step 7: Commit any incidental fixes**

```bash
git status
# if anything turned up during validation:
git add -A && git commit -m "chore(validate): address findings from end-to-end validation"
```text

---

### Task 22: Final review + handoff

**Files:**

- None

- [ ] **Step 1: Diff against `main`**

Run:

```bash
git log --oneline main..HEAD
git diff --stat main..HEAD
```text

- [ ] **Step 2: Confirm cross-repo commit (if Task 19 ran)**

```bash
( cd ../geode && git log --oneline -3 )
```text

- [ ] **Step 3: Surface to the user**

Print a one-paragraph summary listing: bumped version, new agents (3), new skills (3), refreshed commands (5), updated hook with version gate, and the cross-repo marketplace commit. Ask whether to push and open MRs.

---

## Self-review notes

- **Spec coverage**: every change the user requested is locked to a task — sync ([Tasks 2–12, 20]), agents ([Tasks 13–15]), skills ([Tasks 16–18]), LSP ([Task 5]), MCP ([Tasks 4, 7, 18]), marketplace ([Task 19]).
- **No placeholders**: all step bodies contain runnable commands or full file contents. The only deliberately TODO-style content is inside the `commands/*.md` rewrites, which are user-facing prompt templates that interpolate `$ARGUMENTS` at runtime (this is intentional and matches the existing convention).
- **Type consistency**: agent/skill names are referenced identically in `README.md` (Task 11), `docs/REQUIREMENTS.md` (Task 20), `CHANGELOG.md` (Task 12), and the file system; the marketplace manifest version `2.1.0` matches `plugin.json` (Tasks 2, 19).
- **Anti-pattern guard**: no task adds a script with new third-party dependencies, no task touches the `geode` source tree, and the cross-repo commit in Task 19 is gated on user confirmation rather than auto-pushed.
