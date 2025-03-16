ARG DEBIAN_FRONTEND=noninteractive

FROM mcr.microsoft.com/dotnet/aspnet:9.0-noble AS aspnet

ENV ASPNETCORE_ENVIRONMENT=Production \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    DOTNET_NOLOGO=true \
    DOTNET_CLI_TELEMETRY_OPTOUT=true \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_ENABLEDIAGNOSTICS=0 \
    COMPlus_EnableDiagnostics=0 \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    # Add Microsoft repository (https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu)
    wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    # Update again after adding the repository
    apt-get update && \
    apt-get install -y --no-install-recommends powershell && \
    apt-get upgrade -y && \
    # Clean package lists to reduce layer size
    rm -rf /var/lib/apt/lists/*

COPY --chown=$APP_UID:$APP_UID . .

RUN mkdir /ms-playwright && \
    pwsh ./playwright.ps1 install --with-deps chromium && \
    chmod -R 777 /ms-playwright && \
    # Clean up to reduce image size
    apt-get update && \
    apt-get remove wget powershell -y && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER $APP_UID
EXPOSE 5000

ENTRYPOINT ["dotnet", "DevEnterprise.Html2Pdf.Service.dll"]
