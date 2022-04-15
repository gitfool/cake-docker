FROM mcr.microsoft.com/dotnet/sdk:6.0.202-focal

LABEL org.opencontainers.image.source=https://github.com/gitfool/cake-docker

# Configure dotnet sdk
ENV DOTNET_CLI_TELEMETRY_OPTOUT=true \
    DOTNET_NOLOGO=true \
    DOTNET_ROLL_FORWARD=Major

RUN dotnet --info

# Install packages
RUN apt-get update \
    && apt-get install --no-install-recommends -y bash-completion ca-certificates curl gnupg2 sudo unzip vim zip zstd \
    && APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true apt-key adv --keyserver keyserver.ubuntu.com --recv-key E1DD270288B4E6030699E45FA1715D88E1DF1F24 2>&1 \
    && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu focal main" | tee /etc/apt/sources.list.d/git.list \
    && apt-get update \
    && apt-get install --no-install-recommends -y git \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/bash_completion.d

# Install cake tool
# renovate: datasource=nuget depName=cake.tool
RUN version=2.2.0 \
    && dotnet tool install cake.tool --version $version --tool-path /tools \
    && dotnet nuget locals all --clear \
    && chmod 755 /tools/dotnet-cake \
    && ln -s /tools/dotnet-cake /usr/local/bin/cake \
    && cake --info

ENV CAKE_SETTINGS_ENABLESCRIPTCACHE=true \
    CAKE_SETTINGS_SHOWPROCESSCOMMANDLINE=true

# Install docker cli
# renovate: datasource=github-releases depName=docker packageName=moby/moby
RUN version=20.10.14 \
    && curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-$version.tgz -o docker.tgz \
    && tar -xzf docker.tgz --directory /usr/local/bin --no-same-owner --strip=1 docker/docker \
    && rm -f docker.tgz \
    && docker --version

# Install docker-compose
# renovate: datasource=github-releases depName=docker-compose packageName=docker/compose
RUN version=2.4.1 \
    && curl -fsSL https://github.com/docker/compose/releases/download/v$version/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && docker-compose --version

# Add non-root user
RUN groupadd --gid 1000 user \
    && useradd --uid 1000 --gid 1000 --shell /bin/bash -m user \
    && groupadd docker \
    && usermod --append --groups docker user \
    && echo "user ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/user \
    && chmod 0440 /etc/sudoers.d/user

USER user

RUN echo "alias l='ls -aF'" >> ~/.bash_aliases \
    && echo "alias ll='ls -ahlF'" >> ~/.bash_aliases \
    && echo "alias ls='ls --color=auto --group-directories-first'" >> ~/.bash_aliases

USER root
