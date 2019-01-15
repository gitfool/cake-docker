FROM microsoft/dotnet:2.2.102-sdk-bionic

# Install Cake tool
ENV CAKE_VERSION=0.33.0-alpha0034

RUN dotnet tool install Cake.Tool --version $CAKE_VERSION --tool-path /cake --add-source https://www.myget.org/F/cake/api/v3/index.json \
    && chmod 755 /cake/dotnet-cake \
    && ln -s /cake/dotnet-cake /usr/local/bin/cake \
    && dotnet --info \
    && cake --info

# Install Docker client
ENV DOCKER_VERSION=18.09.1

RUN curl -sSL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz | tar -xzO docker/docker > /usr/bin/docker \
    && chmod +x /usr/bin/docker \
    && docker --version \
    && useradd -m -u 1001 vsts_azpcontainer \
    && groupadd docker \
    && usermod -a -G docker vsts_azpcontainer
