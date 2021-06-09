FROM mcr.microsoft.com/dotnet/sdk:5.0.301-focal

# Configure .NET SDK
ENV DOTNET_CLI_TELEMETRY_OPTOUT=true \
    DOTNET_NOLOGO=true \
    DOTNET_ROLL_FORWARD=Major

# Install packages
RUN apt-get update \
    && apt-get install --no-install-recommends -y bash-completion ca-certificates curl unzip vim zip zstd \
    && mkdir -p /etc/bash_completion.d \
    && rm -rf /var/lib/apt/lists/*

# Install Cake tool
RUN version=1.1.0 \
    && dotnet tool install cake.tool --version $version --tool-path /cake \
    && dotnet nuget locals all --clear \
    && chmod 755 /cake/dotnet-cake \
    && ln -s /cake/dotnet-cake /usr/local/bin/cake \
    && dotnet --info \
    && cake --info

ENV CAKE_SETTINGS_SHOWPROCESSCOMMANDLINE=true

# Install Docker client
RUN version=20.10.7 \
    && curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-$version.tgz -o docker.tgz \
    && tar -xzf docker.tgz --directory /usr/local/bin --no-same-owner --strip=1 docker/docker \
    && rm -f docker.tgz \
    && docker --version

# Install docker-compose
RUN version=1.29.2 \
    && curl -fsSL https://github.com/docker/compose/releases/download/$version/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && docker-compose --version

# Install git ppa
RUN apt-get update \
    && apt-get install --no-install-recommends -y gnupg2 \
    && APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true apt-key adv --keyserver keyserver.ubuntu.com --recv-key E1DD270288B4E6030699E45FA1715D88E1DF1F24 2>&1 \
    && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu focal main" | tee /etc/apt/sources.list.d/git.list \
    && apt-get update \
    && apt-get install --no-install-recommends -y git \
    && rm -rf /var/lib/apt/lists/* \
    && git --version

# Add non-root user
RUN groupadd --gid 1000 user \
    && useradd --uid 1000 --gid 1000 --shell /bin/bash -m user \
    && groupadd docker \
    && usermod --append --groups docker user \
    && apt-get update \
    && apt-get install --no-install-recommends -y sudo \
    && rm -rf /var/lib/apt/lists/* \
    && echo "user ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/user \
    && chmod 0440 /etc/sudoers.d/user
