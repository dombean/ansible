#!/bin/bash
set -euo pipefail

# Install LazyVim on macOS with a set of personal customisations.
# Uses Homebrew to install Neovim and LazyVim's recommended dependencies,
# clones the LazyVim starter, then layers on the custom plugin/keymap files
# that live alongside this script.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG="$HOME/.config/nvim"
NVIM_DATA="$HOME/.local/share/nvim"
NVIM_STATE="$HOME/.local/state/nvim"
NVIM_CACHE="$HOME/.cache/nvim"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

echo "==> Installing Homebrew (if not already installed)"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Make brew available in this session (Apple Silicon vs Intel paths)
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

echo "==> Installing Neovim and LazyVim dependencies"
brew update
brew install neovim git ripgrep fd fzf lazygit
# A Nerd Font so icons render correctly in the terminal.
brew install --cask font-sauce-code-pro-nerd-font || true
# C compiler for nvim-treesitter: clang ships with the Xcode Command Line Tools.
if ! xcode-select -p >/dev/null 2>&1; then
  echo "==> Installing Xcode Command Line Tools (provides clang for treesitter)"
  xcode-select --install || true
fi

# Back up any existing Neovim configuration / state so nothing is lost.
backup_if_exists() {
  local path="$1"
  if [ -e "$path" ]; then
    echo "==> Backing up $path -> ${path}.bak.${TIMESTAMP}"
    mv "$path" "${path}.bak.${TIMESTAMP}"
  fi
}

echo "==> Backing up existing Neovim config/state (if any)"
backup_if_exists "$NVIM_CONFIG"
backup_if_exists "$NVIM_DATA"
backup_if_exists "$NVIM_STATE"
backup_if_exists "$NVIM_CACHE"

echo "==> Cloning the LazyVim starter"
git clone https://github.com/LazyVim/starter "$NVIM_CONFIG"
rm -rf "$NVIM_CONFIG/.git"

echo "==> Copying custom plugin files"
mkdir -p "$NVIM_CONFIG/lua/plugins"
cp "$SCRIPT_DIR"/nvim/lua/plugins/*.lua "$NVIM_CONFIG/lua/plugins/"

echo "==> Adding auto-centring cursor keymaps"
KEYMAPS_FILE="$NVIM_CONFIG/lua/config/keymaps.lua"
mkdir -p "$(dirname "$KEYMAPS_FILE")"
touch "$KEYMAPS_FILE"
if grep -q "custom: auto-centring cursor" "$KEYMAPS_FILE"; then
  echo "    keymaps already present, skipping"
else
  printf '\n' >>"$KEYMAPS_FILE"
  cat "$SCRIPT_DIR/keymaps-snippet.lua" >>"$KEYMAPS_FILE"
fi

cat <<'EOF'

==> Done!

LazyVim is installed with your customisations:
  - auto-save.nvim
  - noice.nvim disabled
  - hardtime.nvim
  - nvim-surround
  - auto-centring cursor keymaps

Next steps:
  1. Launch Neovim:  nvim
  2. Wait for plugins to install, then run:  :Lazy sync
  3. Set your terminal font to "SauceCodePro Nerd Font" for icons.
EOF
