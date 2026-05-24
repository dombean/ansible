#!/bin/bash
set -euo pipefail

# Install LazyVim on Ubuntu with a set of personal customisations.
# Uses apt-get for packages where possible; lazygit and the Nerd Font are
# fetched from upstream releases since they aren't in the apt repositories.
# Clones the LazyVim starter, then layers on the custom plugin/keymap files
# that live alongside this script.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG="$HOME/.config/nvim"
NVIM_DATA="$HOME/.local/share/nvim"
NVIM_STATE="$HOME/.local/state/nvim"
NVIM_CACHE="$HOME/.cache/nvim"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

# apt's default Neovim is frequently too old for LazyVim (which needs >= 0.9.0),
# so pull a current build from the official Neovim PPA.
echo "==> Adding the Neovim PPA"
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:neovim-ppa/unstable

echo "==> Installing Neovim and LazyVim dependencies (apt-get)"
sudo apt-get update
# build-essential provides the C compiler nvim-treesitter needs; the rest are
# LazyVim's recommended tools that exist in the apt repositories.
sudo apt-get install -y \
  neovim git curl unzip build-essential fontconfig \
  ripgrep fd-find fzf

# LazyVim/Telescope look for `fd`, but Ubuntu ships the binary as `fdfind`.
# Expose it as `fd` on the user's PATH.
mkdir -p "$HOME/.local/bin"
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# Detect CPU architecture for the upstream binary downloads.
case "$(uname -m)" in
  x86_64) LG_ARCH="x86_64" ;;
  aarch64 | arm64) LG_ARCH="arm64" ;;
  *) LG_ARCH="" ;;
esac

# lazygit isn't in the apt repos; install the latest release binary.
if ! command -v lazygit >/dev/null 2>&1; then
  if [ -n "$LG_ARCH" ]; then
    echo "==> Installing lazygit from GitHub releases"
    LG_VERSION="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest |
      grep -Po '"tag_name": *"v\K[^"]*')" || LG_VERSION=""
    if [ -n "$LG_VERSION" ] &&
      curl -fsSLo /tmp/lazygit.tar.gz \
        "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VERSION}/lazygit_${LG_VERSION}_Linux_${LG_ARCH}.tar.gz"; then
      tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
      sudo install /tmp/lazygit /usr/local/bin/lazygit
      rm -f /tmp/lazygit /tmp/lazygit.tar.gz
    else
      echo "    WARNING: could not download lazygit; install it manually if needed."
    fi
  fi
fi

# Nerd Font (not in apt): install JetBrainsMono Nerd Font for the current user.
FONT_DIR="$HOME/.local/share/fonts"
if ! find "$FONT_DIR" -iname 'JetBrainsMono*Nerd*' 2>/dev/null | grep -q .; then
  echo "==> Installing JetBrainsMono Nerd Font"
  mkdir -p "$FONT_DIR"
  if curl -fsSLo /tmp/JetBrainsMono.zip \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"; then
    unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR" >/dev/null
    rm -f /tmp/JetBrainsMono.zip
    fc-cache -f "$FONT_DIR" >/dev/null
  else
    echo "    WARNING: could not download the Nerd Font; install one manually if icons don't render."
  fi
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
  1. Ensure ~/.local/bin is on your PATH (for the 'fd' shim).
  2. Launch Neovim:  nvim
  3. Wait for plugins to install, then run:  :Lazy sync
  4. Set your terminal font to "JetBrainsMono Nerd Font" for icons.
EOF
