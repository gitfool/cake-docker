FROM mcr.microsoft.com/dotnet/core/sdk:3.0.100-bionic

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_ROLL_FORWARD_ON_NO_CANDIDATE_FX=2 \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

# Install Cake tool
ENV CAKE_VERSION=0.35.0

RUN dotnet tool install Cake.Tool --version $CAKE_VERSION --tool-path /cake --add-source https://www.myget.org/F/cake/api/v3/index.json \
    && dotnet nuget locals all --clear \
    && chmod 755 /cake/dotnet-cake \
    && ln -s /cake/dotnet-cake /usr/local/bin/cake \
    && dotnet --info \
    && cake --info

# Install Docker client
ENV DOCKER_VERSION=19.03.2

RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz | tar -xzO docker/docker > /usr/local/bin/docker \
    && chmod +x /usr/local/bin/docker \
    && docker --version

# Install docker-compose
ENV DOCKER_COMPOSE_VERSION=1.24.1

RUN curl -fsSL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && docker-compose --version
