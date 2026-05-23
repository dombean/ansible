# 🖥️ Personal Ubuntu Machine Setup with Ansible and Dotfiles

![CI](https://github.com/dombean/ansible/actions/workflows/ci.yml/badge.svg)
![ShellCheck](https://github.com/dombean/ansible/actions/workflows/shellcheck.yml/badge.svg)
![LazyVim Scripts](https://github.com/dombean/ansible/actions/workflows/lazyvim.yml/badge.svg)

This repository contains an Ansible playbook for setting up my personal Ubuntu machine,
complete with my preferred dotfiles. The playbook automates the process of setting up
my machine, making it easy to get started with a fresh Ubuntu installation or to
reset an existing system.

## 🚀 Quick Start

To set up my personal Ubuntu machine, follow these steps:

1. Run `setup.sh` to install Ansible and its dependencies.
2. Run `generate_ssh_github.sh` to generate an SSH key and add it to my GitHub account.
3. Run `download_appimages.sh` to download and configure necessary AppImages.

Note: Change GTK theme to `Arc-Dark` using `gnome-tweaks`.

## 🍏 Mac Setup

If I'm on a Mac, follow these steps:

1. Run `mac_scripts/setup_brew_mac.sh` to set up Homebrew and essential tools.
2. Run `generate_ssh_github.sh` to generate an SSH key and add it to my GitHub account.
3. Use GNU Stow to manage dotfiles:
    ```bash
    stow git -t $HOME/     # Apply git configuration
    stow nvim -t $HOME/    # Apply nvim configuration
    stow xre_zsh -t $HOME/ # Apply zsh configuration
    stow ghostty -t $HOME/ # Apply ghostty configuration
    stow aerospace -t $HOME/ # Apply aerospace configuration
    ```
4. Manually install Aliento applications.

### ⌨️ Keyboard Configuration

**Switch keyboard layout to US (if using a US keyboard)**

Use **US**, not **US International**. US International treats quote and apostrophe keys
as dead keys (they underline and wait for a follow-up keystroke), which breaks normal typing.

1. Go to **System Settings → Keyboard → Input Sources**
2. Click **+**, search for **English**, and select **US**
3. Click **Add**, then remove any other layouts (e.g. British, US International) using **−**

**Fix Vim key-repeat (disable press-and-hold accent picker)**

macOS intercepts held keys to show a diacritic popup, which breaks
held `j`/`k` navigation in Vim. Disable it with:

```bash
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
```

Restart VSCode after running. To revert:

```bash
defaults delete NSGlobalDomain ApplePressAndHoldEnabled
```

**Key repeat speed**

In **System Settings → Keyboard**, set:
- **Key Repeat Rate** → Fast
- **Delay Until Repeat** → Short

## ⚡ LazyVim Setup (Neovim)

The `lazyvim/` folder contains one-shot installers that set up
[LazyVim](https://www.lazyvim.org/) along with my personal customisations on a
fresh machine. Pick the script for my platform:

| Platform | Script | Package manager |
|---|---|---|
| macOS | `lazyvim/install_lazyvim_mac.sh` | Homebrew |
| Windows | `lazyvim/install_lazyvim_windows.ps1` | winget |

**What each script does:**

1. Installs Neovim and LazyVim's recommended dependencies (`git`, `ripgrep`,
   `fd`, `fzf`, `lazygit`, a C compiler, and a Nerd Font).
2. Backs up any existing Neovim config/state (timestamped `.bak.<date>`), so
   re-running never clobbers an existing setup.
3. Clones the [LazyVim starter](https://github.com/LazyVim/starter) into the
   config dir (`~/.config/nvim` on macOS, `%LOCALAPPDATA%\nvim` on Windows) and
   strips its `.git`.
4. Copies my custom plugin specs from `lazyvim/nvim/lua/plugins/` into the
   config.
5. Appends my auto-centring cursor keymaps (`lazyvim/keymaps-snippet.lua`) to
   `lua/config/keymaps.lua`, guarded by a marker comment so re-runs don't
   duplicate them.

**My customisations** (see each file in `lazyvim/nvim/lua/plugins/`):

- **auto-save.nvim** -- saves on leaving Insert mode / text change (1s debounce).
- **noice.nvim** -- disabled.
- **hardtime.nvim** -- enforces better Vim motion habits.
- **nvim-surround** -- add/change/delete surrounding brackets, quotes, tags.
- **Auto-centring keymaps** -- `zz` after `<C-d>`/`<C-u>`, `n`/`N`, `G`, `*`/`#`.
- **flash.nvim** -- built into LazyVim, no install needed (`s` to jump).

### Running it

**macOS:**

```bash
bash lazyvim/install_lazyvim_mac.sh
```

**Windows (PowerShell):**

```powershell
# If scripts are blocked, allow for the current session first:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
./lazyvim/install_lazyvim_windows.ps1
```

After running: launch `nvim`, let plugins install, then run `:Lazy sync`. Set
the terminal font to a Nerd Font so icons render.

### Testing

The `.github/workflows/lazyvim.yml` workflow tests both installers whenever
files under `lazyvim/` change (and on manual dispatch):

- **Lint** -- `shellcheck` on the macOS script and `PSScriptAnalyzer` on the
  Windows script (runs on Linux, fast).
- **Smoke test** -- actually runs each installer on macOS and Windows runners,
  performs a headless `:Lazy sync`, and verifies the custom plugins were cloned
  and the keymaps applied.

## 🐳 Local Testing with Docker

I can test the Ansible playbook locally using Docker. This allows me to ensure that
my playbook is working correctly before deploying it to my Ubuntu machine.

### 🏗️ Building the Docker Image

Build the Docker image with the following command:

```bash
docker build -t ansible-build -f Dockerfile .
```

If I need to build the image without using cache, I can use the `--no-cache` flag:

```bash
docker build -t ansible-build -f Dockerfile . --no-cache
```

### 🏃 Running the Docker Container

Run the Docker container in interactive mode with this command:

```bash
docker run -it ansible-build
```

This will allow me to explore the container and verify that the Ansible
playbook has been applied correctly.

## 🤖 Continuous Integration (CI)

The `.github/workflows/ci.yml` workflow is the CI gate for the Ansible setup.
It runs the same Docker-based test as above, but automatically in GitHub
Actions, so a broken playbook is caught before it ever reaches a real machine.

**What it does:**

1. Checks out the repository on an `ubuntu-24.04` runner.
2. Builds the Docker image from `Dockerfile`, passing the
   `VAULT_PASS` secret as a build argument (used to decrypt Ansible Vault files).
3. Runs the container, which executes `entrypoint.sh` and applies the full
   Ansible playbook (`main.yml` + everything under `tasks/`).

**What it checks:** that the image builds and the playbook runs to completion
without errors -- i.e. the dotfiles/tooling setup is still valid end to end.

**When it runs:** on every push to `main`, *except* when the only changes are
docs or platform-specific scripts (`README.md`, `lazyvim/**`, `mac_scripts/**`),
plus a manual `workflow_dispatch` button. This keeps the (relatively slow)
Docker build from running on changes that can't affect it.

> The `VAULT_PASS` secret must be configured in the repository's
> **Settings → Secrets and variables → Actions** for the build to succeed.

### 🐚 ShellCheck

The `.github/workflows/shellcheck.yml` workflow lints the repository's shell
scripts (`setup.sh`, `entrypoint.sh`, `download_appimages.sh`, and the
`mac_scripts/` scripts) with `shellcheck --severity=warning`. It runs whenever
one of those scripts changes. The LazyVim shell script is linted separately by
`lazyvim.yml`, and the Vault-encrypted `generate_ssh_github.sh` is skipped.

### 🤖 Dependabot

`.github/dependabot.yml` enables weekly Dependabot updates for the
`github-actions` ecosystem, so the action versions used across these workflows
(e.g. `actions/checkout`) stay current automatically.

## 📝 Ansible Usage Examples

### Decrypting a file with Ansible Vault

To decrypt a file that has been encrypted with Ansible Vault, use the following command:

```bash
ansible-vault decrypt generate_ssh_github.sh
```

You will be prompted for the vault password. After providing the correct password,
the file `generate_ssh_github.sh` will be decrypted.

## 🗂️ Repository Structure

- `entrypoint.sh`: Script that serves as the starting point for the Docker container.
- `generate_ssh_github.sh`: Script to generate an SSH key and add it to GitHub.
- `setup.sh`: Bash script to install Ansible and its dependencies on Ubuntu.
- `download_appimages.sh`: Script to download and configure AppImages.
- `main.yml`: Main Ansible playbook that automates the setup of the Ubuntu machine.
- `tasks/`: Ansible task files included by `main.yml` (core setup, miniconda, R, desktop, dotfiles, rust, deb-get).
- `README.md`: Documentation for the repository.
- `Dockerfile`: Dockerfile for building a Docker image of the setup (used locally and by CI).
- `secrets.yml`: Encrypted file containing sensitive information, managed with Ansible Vault.
- `mac_scripts/setup_brew_mac.sh`: Bash script to set up Homebrew and essential tools on macOS.
- `mac_scripts`: Folder containing scripts for macOS.
- `lazyvim/`: Folder with LazyVim installers and shared Neovim config.
- `lazyvim/install_lazyvim_mac.sh`: Installs Neovim + LazyVim + customisations on macOS via Homebrew.
- `lazyvim/install_lazyvim_windows.ps1`: Installs Neovim + LazyVim + customisations on Windows via winget.
- `lazyvim/nvim/lua/plugins/`: Custom LazyVim plugin specs copied into the Neovim config.
- `lazyvim/keymaps-snippet.lua`: Auto-centring cursor keymaps appended to `keymaps.lua`.
- `.github/workflows/ci.yml`: CI that builds the Docker image and runs the Ansible playbook end to end.
- `.github/workflows/shellcheck.yml`: CI that lints the repository's shell scripts with ShellCheck.
- `.github/workflows/lazyvim.yml`: CI that lints and smoke-tests the LazyVim installers.
- `.github/dependabot.yml`: Weekly Dependabot updates for GitHub Actions versions.

## 📝 Note

This repository is tailored to my personal preferences and is not intended for general use.
