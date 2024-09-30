# little-red-riding-hood-tooling
Docker tool container to easily attend hand's on little red hood lab

This project builds a docker container with the following tools:
- kubectl
- helm
- linkerd
- boundary
- jq
- git
- bind-tools (nslookup, dig)
- vim
- curl
- wget

## How to use it

### Build the container

```bash
docker build -t little-red-hood-tooling .
```

### Run the container

```bash
export REPO_ROOT_DIR=<path to the root of the hand\'s on repository>
export KUBECONFIG=<path to the kubeconfig file>
docker run --rm -v $KUBECONFIG:/home/tooling/.kube/config -v $REPO_ROOT_DIR/labs/:/apps -it ghcr.io/ddrugeon/little-red-riding-hood-tooling:latest
```

### Run the container with a shell

```bash
export REPO_ROOT_DIR=<path to the root of the hand\'s on repository>
export KUBECONFIG=<path to the kubeconfig file>
docker run --rm -v $KUBECONFIG:/home/tooling/.kube/config -v $REPO_ROOT_DIR/labs/:/apps -it ghcr.io/ddrugeon/little-red-riding-hood-tooling:latest /bin/bash
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
