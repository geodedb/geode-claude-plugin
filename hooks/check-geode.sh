#!/bin/bash
# Check for geode installation and provide installation guidance

# Check if geode is in PATH
if command -v geode &> /dev/null; then
    echo "geode LSP is available: $(command -v geode)"
    geode lsp --help 2>/dev/null | head -1 || true
    exit 0
fi

# Check common installation paths
COMMON_PATHS=(
    "$HOME/.local/bin/geode"
    "/usr/local/bin/geode"
    "/opt/geode/bin/geode"
    "./zig-out/bin/geode"
    "./geode"
)

for path in "${COMMON_PATHS[@]}"; do
    if [[ -x "$path" ]]; then
        echo "geode found at: $path"
        echo "Add to your PATH: export PATH=\"$(dirname "$path"):\$PATH\""
        exit 0
    fi
done

echo "Geode is not installed."
echo ""
echo "Installation options:"
echo "  1. Build from source:"
echo "     git clone https://github.com/geode-db/geode.git"
echo "     cd geode && make build"
echo "     export PATH=\"\$PWD/zig-out/bin:\$PATH\""
echo ""
echo "  2. Install via package manager (when available):"
echo "     brew install geode  # macOS"
echo "     cargo install geode # Rust-based installer"
echo ""
echo "After installation, ensure 'geode' is in your PATH."
exit 1
