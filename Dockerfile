# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/sdk:6.0.301-jammy

LABEL org.opencontainers.image.source=https://github.com/gitfool/cake-docker

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
    apt-get install --no-install-recommends -y git
    rm -rf /var/lib/apt/lists/*
    mkdir -p /etc/bash_completion.d
EOF

# Install cake tool
# renovate: datasource=nuget depName=cake.tool
RUN <<EOF
    set -ex
    version=2.2.0
    dotnet tool install cake.tool --version $version --tool-path /tools
    dotnet nuget locals all --clear
    chmod 755 /tools/dotnet-cake
    ln -s /tools/dotnet-cake /usr/local/bin/cake
    cake --info
EOF

ENV CAKE_SETTINGS_ENABLESCRIPTCACHE=true \
    CAKE_SETTINGS_SHOWPROCESSCOMMANDLINE=true

# Install docker cli
# renovate: datasource=github-releases depName=docker packageName=moby/moby
RUN <<EOF
    set -ex
    version=20.10.17
    curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-$version.tgz -o docker.tgz
    tar -xzf docker.tgz --directory /usr/local/bin --no-same-owner --strip=1 docker/docker
    rm -f docker.tgz
    docker --version
EOF

# Install docker-compose
# renovate: datasource=github-releases depName=docker-compose packageName=docker/compose
RUN <<EOF
    set -ex
    version=2.6.0
    curl -fsSL https://github.com/docker/compose/releases/download/v$version/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
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
