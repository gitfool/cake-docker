FROM mcr.microsoft.com/dotnet/core/sdk:3.1.100-bionic

ENV DOTNET_CLI_TELEMETRY_OPTOUT=true \
    DOTNET_ROLL_FORWARD_ON_NO_CANDIDATE_FX=2 \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true

# Install Cake tool
ENV CAKE_VERSION=0.36.0-alpha0074

RUN dotnet tool install Cake.Tool --version $CAKE_VERSION --tool-path /cake --add-source https://pkgs.dev.azure.com/cake-build/Cake/_packaging/cake%40Local/nuget/v3/index.json \
    && dotnet nuget locals all --clear \
    && chmod 755 /cake/dotnet-cake \
    && ln -s /cake/dotnet-cake /usr/local/bin/cake \
    && dotnet --info \
    && cake --info

# Install Docker client
ENV DOCKER_VERSION=19.03.5

RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz | tar -xzO docker/docker > /usr/local/bin/docker \
    && chmod +x /usr/local/bin/docker \
    && docker --version

# Install docker-compose
ENV DOCKER_COMPOSE_VERSION=1.25.0

RUN curl -fsSL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && docker-compose --version

# Install git ppa
RUN APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true apt-key adv --keyserver keyserver.ubuntu.com --recv-key E1DD270288B4E6030699E45FA1715D88E1DF1F24 2>&1 \
    && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu bionic main" | tee /etc/apt/sources.list.d/git.list \
    && apt-get update -y \
    && apt-get install --no-install-recommends -y git \
    && rm -rf /var/lib/apt/lists/* \
    && git --version
