#!/usr/bin/env bash
set -euo pipefail

# Codex Cloud Environment Setup Script for crypto_market
# This script should be added to the "Setup Script" field in Codex Environment settings
# Prepares Flutter/Dart development environment in the universal container

echo "=== Codex Cloud Environment Setup for crypto_market ==="

# === Configuration ===
FLUTTER_VERSION="3.35.1"         # Pin to match CI Flutter version
FLUTTER_SDK_DIR="$HOME/flutter"
# Optional language support toggles (keep false for fast default setup)
CODEX_SETUP_MOTOKO="${CODEX_SETUP_MOTOKO:-false}"
CODEX_SETUP_RUST="${CODEX_SETUP_RUST:-false}"
# Codex Cloud mounts the repo to current directory, not a fixed path
PROJECT_DIR="$(pwd)"

# Check if we have crypto_market subdirectory (common structure)
if [[ -f "crypto_market/pubspec.yaml" ]]; then
    PROJECT_DIR="$(pwd)/crypto_market"
elif [[ ! -f "pubspec.yaml" ]]; then
    echo "Warning: No pubspec.yaml found in current directory or crypto_market/ subdirectory"
fi

echo "Project directory: $PROJECT_DIR"

# Verify Node.js/NPM availability (required for tooling)
if command -v node >/dev/null 2>&1; then
  echo "Node: $(node --version)"
else
  echo "⚠ Node.js not found (expected ≥ v18)"
fi
if command -v npm >/dev/null 2>&1; then
  echo "npm: $(npm --version)"
else
  echo "⚠ npm not found"
fi

# === Optional system deps (uncomment if needed) ===
# if command -v apt-get >/dev/null 2>&1; then
#   apt-get update -y && apt-get install -y curl xz-utils git ca-certificates
# fi

# Install Flutter if not present
if [[ ! -d "$FLUTTER_SDK_DIR" ]]; then
  echo "Installing Flutter ${FLUTTER_VERSION} to ${FLUTTER_SDK_DIR}..."
  FLUTTER_TARBALL_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  mkdir -p "$HOME"
  curl -sL "$FLUTTER_TARBALL_URL" | tar -xJ -C "$HOME"
  echo "✓ Flutter ${FLUTTER_VERSION} installed"
else
  echo "✓ Flutter SDK already present at ${FLUTTER_SDK_DIR}"
fi

# Add flutter to PATH for session and persist in shell rc
SHELL_RC="$HOME/.bashrc"
if ! grep -q 'flutter/bin' "$SHELL_RC" 2>/dev/null; then
  echo 'export PATH="$HOME/flutter/bin:$PATH"' >> "$SHELL_RC"
  echo "✓ Added Flutter to ~/.bashrc"
fi
export PATH="$HOME/flutter/bin:$PATH"

# Verify Flutter installation
echo "Verifying Flutter installation..."
flutter --version || { echo "❌ Flutter not available on PATH"; exit 1; }
if command -v dart >/dev/null 2>&1; then
  echo "✓ Dart: $(dart --version)"
fi

# === Optional: Motoko/DFX setup ===
if [[ "$CODEX_SETUP_MOTOKO" == "true" ]]; then
  DFX_BIN="$HOME/.local/share/dfx/bin"
  if ! command -v dfx >/dev/null 2>&1; then
    echo "Installing DFX (includes Motoko)..."
    DFX_VERSION="${DFX_VERSION:-0.15.8}"
    curl -fsSL https://internetcomputer.org/install.sh | DFX_VERSION="$DFX_VERSION" sh -s -- >/tmp/dfx-install.log 2>&1 || { echo "❌ DFX install failed"; cat /tmp/dfx-install.log; exit 1; }
  else
    echo "✓ DFX already installed: $(dfx --version)"
  fi
  if ! grep -q "$DFX_BIN" "$SHELL_RC" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/share/dfx/bin:$PATH"' >> "$SHELL_RC"
  fi
  export PATH="$DFX_BIN:$PATH"
  if command -v dfx >/dev/null 2>&1; then
    echo "✓ DFX: $(dfx --version)"
  fi
  if command -v moc >/dev/null 2>&1; then
    echo "✓ Motoko: $(moc --version)"
  fi
fi

# === Optional: Rust toolchain setup ===
if [[ "$CODEX_SETUP_RUST" == "true" ]]; then
  if ! command -v rustc >/dev/null 2>&1; then
    echo "Installing Rust toolchain..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path >/tmp/rust-install.log 2>&1 || { echo "❌ Rust install failed"; cat /tmp/rust-install.log; exit 1; }
  else
    echo "✓ Rust already installed: $(rustc --version)"
  fi
  if ! grep -q '.cargo/bin' "$SHELL_RC" 2>/dev/null; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$SHELL_RC"
  fi
  export PATH="$HOME/.cargo/bin:$PATH"
  if command -v rustc >/dev/null 2>&1; then
    echo "✓ Rust: $(rustc --version)"
  fi
  if command -v cargo >/dev/null 2>&1; then
    echo "✓ Cargo: $(cargo --version)"
  fi
fi

# Run Flutter doctor for environment check
echo "Running Flutter doctor..."
flutter doctor || echo "⚠ Flutter doctor found some issues (may not affect development)"

# Minimal precache to speed up common commands (keep minimal to avoid long setup)
echo "Pre-caching Flutter components..."
flutter precache --linux --no-web --no-ios --no-android --no-windows --no-macos || echo "⚠ Precache had issues"

# Setup project dependencies
if [[ -d "$PROJECT_DIR" && -f "$PROJECT_DIR/pubspec.yaml" ]]; then
  cd "$PROJECT_DIR"
  echo "Installing project dependencies in ${PROJECT_DIR}..."
  flutter pub get || { echo "❌ flutter pub get failed"; exit 1; }
  echo "✓ Dependencies installed"
  
  # Verify development tools work
  echo "Verifying development tools..."
  
  echo "Testing dart format..."
  if dart format --output=none --set-exit-if-changed . >/dev/null 2>&1; then
      echo "✓ Code formatting OK"
  else
      echo "⚠ Code formatting issues detected (will be fixed during development)"
  fi
  
  echo "Testing flutter analyze..."
  if flutter analyze --fatal-infos --fatal-warnings >/dev/null 2>&1; then
      echo "✓ Analysis OK"
  else
      echo "⚠ Analysis issues detected (may need resolution during development)"
  fi
  
  echo "Testing flutter test..."
  if flutter test --no-pub >/dev/null 2>&1; then
      echo "✓ Tests passing"
  else
      echo "⚠ Some tests failing (may need fixing during development)"
  fi
else
  echo "⚠ No Flutter project found at $PROJECT_DIR"
fi

echo ""
echo "=== Codex Cloud Environment Ready ==="
echo "Flutter: $(flutter --version | head -n1)"
echo "Dart: $(dart --version)"
if command -v node >/dev/null 2>&1; then
  echo "Node: $(node --version)"
fi
if [[ "$CODEX_SETUP_MOTOKO" == "true" ]]; then
  if command -v dfx >/dev/null 2>&1; then
    echo "DFX: $(dfx --version)"
  fi
  if command -v moc >/dev/null 2>&1; then
    echo "Motoko: $(moc --version)"
  fi
fi
if [[ "$CODEX_SETUP_RUST" == "true" ]]; then
  if command -v rustc >/dev/null 2>&1; then
    echo "Rust: $(rustc --version)"
  fi
  if command -v cargo >/dev/null 2>&1; then
    echo "Cargo: $(cargo --version)"
  fi
fi
echo "Project: $PROJECT_DIR"
echo "Ready for agent development!"
