# Personal Ubuntu Machine Setup with Ansible and Dotfiles

![Tests](https://github.com/dombean/ansible/actions/workflows/main.yml/badge.svg)

This repository contains an Ansible playbook for setting up my personal Ubuntu machine, complete with my preferred dotfiles. The playbook automates the process of setting up my machine, making it easy to get started with a fresh Ubuntu installation or to reset an existing system.

## Quick Start

To set up my personal Ubuntu machine, follow these steps:

1. Run `setup.sh` to install Ansible and its dependencies.
2. Run `generate_ssh_github.sh` to generate an SSH key and add it to my GitHub account.
3. Run `download_appimages.sh` to download and configure necessary AppImages.

## Local Testing with Docker

I can test the Ansible playbook locally using Docker. This allows me to ensure that my playbook is working correctly before deploying it to my Ubuntu machine.

### Building the Docker Image

Build the Docker image with the following command:

```bash
docker build -t ansible-build -f Dockerfile .
```

If I need to build the image without using cache, I can use the `--no-cache` flag:

```bash
docker build -t ansible-build -f Dockerfile . --no-cache
```

### Running the Docker Container

Run the Docker container in interactive mode with this command:

```bash
docker run -it ansible-build
```

This will allow me to explore the container and verify that the Ansible playbook has been applied correctly.

## Note

This repository is tailored to my personal preferences and is not intended for general use. 
