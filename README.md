# Using Ansible to Setup Personal Ubuntu Machine with Dotfiles

![Tests](https://github.com/dombean/ansible/actions/workflows/main.yml/badge.svg)


# Run Notes

Run `setup.sh` and then `generate_ssh_github.sh` and then `download_appimages.sh`


# Local Ansible Playbook Testing with Docker

Use Docker locally to test Ansible Playbook.

## Docker Build

```
docker build -t ansible-build -f Dockerfile .
```

```
docker build -t ansible-build -f Dockerfile . --no-cache
```

## Docker Run

```
docker run -it ansible-build
```