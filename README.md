# Using Ansible to Setup Personal Machine

Use Docker to test Ansible.

# Docker Build

```
docker build -t ansible-build -f Dockerfile .
```

```
docker build -t ansible-build -f Dockerfile . --no-cache
```

# Docker Run

```
docker run -it ansible-build
```

# Notes

Run `setup.sh` and then `generate_ssh_github.sh` and then `download_appimages.sh`


