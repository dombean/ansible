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