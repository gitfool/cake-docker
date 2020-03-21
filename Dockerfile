FROM mcr.microsoft.com/dotnet/core/sdk:3.1.101-bionic

ENV DOTNET_CLI_TELEMETRY_OPTOUT=true \
    DOTNET_ROLL_FORWARD_ON_NO_CANDIDATE_FX=2

# Install Cake tool
RUN dotnet tool install Cake.Tool --version 0.37.0 --tool-path /cake \
    && dotnet nuget locals all --clear \
    && chmod 755 /cake/dotnet-cake \
    && ln -s /cake/dotnet-cake /usr/local/bin/cake \
    && dotnet --info \
    && cake --info

ENV CAKE_SETTINGS_SHOWPROCESSCOMMANDLINE=true

# Install Docker client
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-19.03.8.tgz | tar -zxO docker/docker > /usr/local/bin/docker \
    && chmod +x /usr/local/bin/docker \
    && docker --version

# Install docker-compose
RUN curl -fsSL https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && docker-compose --version

# Install git ppa
RUN APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true apt-key adv --keyserver keyserver.ubuntu.com --recv-key E1DD270288B4E6030699E45FA1715D88E1DF1F24 2>&1 \
    && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu bionic main" | tee /etc/apt/sources.list.d/git.list \
    && apt-get update -y \
    && apt-get install --no-install-recommends -y git \
    && rm -rf /var/lib/apt/lists/* \
    && git --version
