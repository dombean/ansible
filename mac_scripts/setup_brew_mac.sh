#!/bin/bash

# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install essential tools and utilities with Homebrew

# Update and upgrade Homebrew
brew update && brew upgrade

# Install CLI tools
brew install git                                  # Version control system
brew install bitwarden-cli                        # Command-line tool for Bitwarden password manager
brew install neovim                               # Modern Vim-based text editor
brew install eza                                  # Enhanced ls command
brew install bat                                  # A cat clone with syntax highlighting and Git integration
brew install mpv                                  # Command-line media player
brew install coreutils                            # GNU core utilities for macOS
brew install wget                                 # Network downloader
brew install yazi                                 # Terminal file manager
brew install ffmpeg                               # Multimedia framework for video and audio processing
brew install sevenzip                             # 7zip archiver
brew install jq                                   # Command-line JSON processor
brew install poppler                              # PDF utilities
brew install fd                                   # Faster alternative to find
brew install ripgrep                              # Fast search tool
brew install fzf                                  # Command-line fuzzy finder
brew install zoxide                               # Smart directory jumper
brew install imagemagick                          # Image manipulation tool
brew install font-symbols-only-nerd-font          # Symbol font for terminal
brew install --cask font-sauce-code-pro-nerd-font # Nerd font for coding
brew install --cask font-arimo                    # Arimo font
brew install --cask font-fira-code                # Fira Code font
brew install stow                                 # GNU Stow for managing dotfiles

# Install GPG and pinentry
brew install pinentry-mac gpg2 gnupg # For secure encryption and signing
brew install --cask gpg-suite        # GUI tools for GPG management

# Install GUI apps with Homebrew Cask
brew install --cask alt-tab                   # Window manager to switch between apps
brew install --cask hiddenbar                 # Menu bar organization
brew install --cask devtoys                   # Developer toolbox
brew install --cask miniconda                 # Python environment manager
brew install --cask veracrypt                 # Disk encryption tool
brew install --cask betterdisplay             # Display management tool
brew install --cask latest                    # App update checker
brew install --cask ghostty                   # Terminal emulator
brew install --cask vlc                       # Media player
brew install --cask visual-studio-code        # Code editor
brew install --cask whatsapp                  # Messaging application
brew install --cask proton-mail               # Proton Mail app
brew install --cask zen-browser               # Zen web browser
brew install --cask brave-browser             # Brave web browser
brew install --cask raycast                   # Productivity launcher
brew install --cask spotify                   # Music streaming application
brew install --cask nikitabobko/tap/aerospace # Tiling window manager
brew install --cask protonvpn                 # VPN client

# Use GNU Stow to manage dotfiles
stow git -t $HOME/     # Apply git configuration
stow nvim -t $HOME/    # Apply nvim configuration
stow xre_zsh -t $HOME/ # Apply zsh configuration

# Clean up outdated versions
brew cleanup

echo "Installation complete. Please restart your terminal for changes to take effect."
