FROM microsoft/dotnet:2.2.102-sdk-bionic

ENV CAKE_VERSION=0.33.0-alpha0024

RUN dotnet tool install Cake.Tool --version $CAKE_VERSION --tool-path /cake --add-source https://www.myget.org/F/cake/api/v3/index.json \
    && chmod 755 /cake/dotnet-cake \
    && ln -s /cake/dotnet-cake /usr/local/bin/cake \
    && dotnet --info \
    && cake --info
