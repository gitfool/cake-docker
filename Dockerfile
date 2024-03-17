# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/sdk:8.0.203-jammy

LABEL org.opencontainers.image.source=https://github.com/gitfool/cake-docker

# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETARCH

# Configure dotnet sdk
ENV DOTNET_CLI_TELEMETRY_OPTOUT=true \
    DOTNET_NOLOGO=true \
    DOTNET_ROLL_FORWARD=Major

RUN dotnet --info

# Install packages
RUN <<EOF
    set -ex
    apt-get update
    apt-get install --no-install-recommends -y bash-completion ca-certificates curl gnupg sudo unzip vim zip zstd
    curl -fsSL 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xe1dd270288b4e6030699e45fa1715d88e1df1f24' | gpg --dearmor -o /usr/share/keyrings/git-ppa.gpg
    echo 'deb [signed-by=/usr/share/keyrings/git-ppa.gpg] https://ppa.launchpadcontent.net/git-core/ppa/ubuntu jammy main' | tee /etc/apt/sources.list.d/git-ppa.list
    apt-get update
    apt-get install --no-install-recommends -y git git-lfs
    rm -rf /var/lib/apt/lists/*
    mkdir -p /etc/bash_completion.d
EOF

# Install cake tool
# renovate: datasource=nuget depName=cake.tool
RUN <<EOF
    set -ex
    version=4.0.0
    dotnet tool install cake.tool --version $version --tool-path /tools
    dotnet nuget locals all --clear
    chmod 755 /tools/dotnet-cake
    ln -s /tools/dotnet-cake /usr/local/bin/cake
    cake --info
EOF

ENV Cake_Settings_EnableScriptCache=true \
    Cake_Settings_ShowProcessCommandLine=true

# Install docker cli
# renovate: datasource=github-releases depName=docker packageName=moby/moby
RUN <<EOF
    set -ex
    [ "$TARGETARCH" = "amd64" ] && arch="x86_64" || arch="aarch64"
    version=25.0.4
    curl -fsSL https://download.docker.com/linux/static/stable/$arch/docker-$version.tgz -o docker.tgz
    tar -xzf docker.tgz --directory /usr/local/bin --no-same-owner --strip=1 docker/docker
    rm -f docker.tgz
    mkdir -p /usr/local/lib/docker/cli-plugins
    docker completion bash > /etc/bash_completion.d/docker
    docker --version
EOF

# Install docker buildx plugin; https://docs.docker.com/buildx/working-with-buildx/#manual-download
# renovate: datasource=github-releases depName=docker-buildx packageName=docker/buildx
RUN <<EOF
    set -ex
    [ "$TARGETARCH" = "amd64" ] && arch="amd64" || arch="arm64"
    version=0.13.1
    curl -fsSL https://github.com/docker/buildx/releases/download/v$version/buildx-v$version.linux-$arch -o /usr/local/lib/docker/cli-plugins/docker-buildx
    chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx
    docker buildx version
EOF

# Install docker compose plugin; https://docs.docker.com/compose/install/compose-plugin/#install-the-plugin-manually
# renovate: datasource=github-releases depName=docker-compose packageName=docker/compose
RUN <<EOF
    set -ex
    [ "$TARGETARCH" = "amd64" ] && arch="x86_64" || arch="aarch64"
    version=2.25.0
    curl -fsSL https://github.com/docker/compose/releases/download/v$version/docker-compose-linux-$arch -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
    docker compose version
EOF

# Install docker compose switch; https://github.com/docker/compose-switch#installation
# renovate: datasource=github-releases depName=docker-compose-switch packageName=docker/compose-switch
RUN <<EOF
    set -ex
    [ "$TARGETARCH" = "amd64" ] && arch="amd64" || arch="arm64"
    version=1.0.5
    curl -fsSL https://github.com/docker/compose-switch/releases/download/v$version/docker-compose-linux-$arch -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    docker-compose --version
EOF

# Add non-root user
RUN <<EOF
    set -ex
    groupadd --gid 1000 user
    useradd --uid 1000 --gid 1000 --shell /bin/bash -m user
    groupadd docker
    usermod --append --groups docker user
    echo "user ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/user
    chmod 0440 /etc/sudoers.d/user
EOF

USER user

RUN <<EOF
    set -ex
    echo "alias l='ls -aF'" >> ~/.bash_aliases
    echo "alias ll='ls -ahlF'" >> ~/.bash_aliases
    echo "alias ls='ls --color=auto --group-directories-first'" >> ~/.bash_aliases
EOF

USER root
