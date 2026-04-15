# 🖥️ Personal Ubuntu Machine Setup with Ansible and Dotfiles

![Tests](https://github.com/dombean/ansible/actions/workflows/main.yml/badge.svg)

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
- `README.md`: Documentation for the repository.
- `Dockerfile`: Dockerfile for building a Docker image of the setup.
- `secrets.yml`: Encrypted file containing sensitive information, managed with Ansible Vault.
- `mac_scripts/setup_brew_mac.sh`: Bash script to set up Homebrew and essential tools on macOS.
- `mac_scripts`: Folder containing scripts for macOS.

## 📝 Note

This repository is tailored to my personal preferences and is not intended for general use.
