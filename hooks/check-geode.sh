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

VERSION_RAW=$(geode --version 2>&1 | head -n1 || true)
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
