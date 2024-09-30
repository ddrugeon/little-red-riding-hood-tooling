# Inspiré du projet https://github.com/alpine-docker/k8s
# Stage de construction
FROM alpine:latest AS builder

ARG HELM_VERSION=3.15.1
ARG KUBECTL_VERSION=1.31.1
ARG BOUNDARY_VERSION=0.12.1
ARG LINKERD_VERSION=24.8.2
ARG KUSTOMIZE_VERSION=v5.4.2
ARG ARCH

# Déterminer l'architecture
RUN case $(uname -m) in \
    x86_64) ARCH=amd64 LINKERD_SCRIPT=linkerd2-cli-edge-${LINKERD_VERSION}-linux-${ARCH} ;; \
    aarch64) ARCH=arm64 LINKERD_SCRIPT=linkerd2-cli-edge-${LINKERD_VERSION}-linux-${ARCH} ;; \
    *) echo "Unsupported architecture"; exit 1; ;; \
    esac && \
    echo "export ARCH=${ARCH}" > /envfile && \
    echo "export LINKERD_SCRIPT=${LINKERD_SCRIPT}" >> /envfile && \
    cat /envfile

# Installer les outils nécessaires
RUN apk add --no-cache curl ca-certificates openssl openssh unzip bash tar && \
    . /envfile && echo "${ARCH}" && \
#
# Installation de kubectl
    curl -sLO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl && \
#
# Installation de helm
    apk add --update --no-cache curl ca-certificates bash git && \
    curl -sL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz | tar -xvz && \
    mv linux-${ARCH}/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-${ARCH} && \
#
# Install kustomize (latest release)
    curl -sLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
    tar xvf kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
    mv kustomize /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize && \
#
# Installation de boundary
    curl -sLO "https://releases.hashicorp.com/boundary/${BOUNDARY_VERSION}/boundary_${BOUNDARY_VERSION}_linux_${ARCH}.zip" && \
    unzip boundary_${BOUNDARY_VERSION}_linux_${ARCH}.zip && \
    rm boundary_${BOUNDARY_VERSION}_linux_${ARCH}.zip && \
    mv boundary /usr/bin/boundary && \
    chmod +x /usr/bin/boundary && \
#
# Installation de linkerd
    curl -sLO "https://github.com/linkerd/linkerd2/releases/download/${LINKERD_SCRIPT}" && \
    mv ${LINKERD_SCRIPT} /usr/bin/linkerd

# Stage d'exécution
FROM alpine:latest

LABEL org.opencontainers.image.source=https://github.com/ddrugeon/little-red-riding-hood-tooling.git

# Ajouter les utilisateurs
RUN addgroup -S tooling && adduser -S tooling -G tooling -h /home/tooling

# Installer les packages requis
RUN apk add --no-cache ca-certificates bash bash-completion jq yq gettext git bind-tools vim curl

# Copier les binaires du builder
COPY --from=builder /usr/bin/kubectl /usr/bin/
COPY --from=builder /usr/bin/kustomize /usr/bin/
COPY --from=builder /usr/bin/helm /usr/bin/
COPY --from=builder /usr/bin/boundary /usr/bin/
COPY --from=builder /usr/bin/linkerd /usr/bin/

# add helm-diff
RUN helm plugin install https://github.com/databus23/helm-diff && rm -rf /tmp/helm-*

USER tooling
WORKDIR /apps
ENTRYPOINT ["/bin/bash"]
