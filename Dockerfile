FROM mcr.microsoft.com/dotnet/core/sdk:2.2.401-bionic

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

# Install Cake tool
ENV CAKE_VERSION=0.34.1

RUN dotnet tool install Cake.Tool --version $CAKE_VERSION --tool-path /cake --add-source https://www.myget.org/F/cake/api/v3/index.json \
    && dotnet nuget locals all --clear \
    && chmod 755 /cake/dotnet-cake \
    && ln -s /cake/dotnet-cake /usr/local/bin/cake \
    && dotnet --info \
    && cake --info

# Install Docker client
ENV DOCKER_VERSION=19.03.1

RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz | tar -xzO docker/docker > /usr/local/bin/docker \
    && chmod +x /usr/local/bin/docker \
    && docker --version
