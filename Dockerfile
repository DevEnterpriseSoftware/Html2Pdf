ARG DEBIAN_FRONTEND=noninteractive

FROM mcr.microsoft.com/dotnet/aspnet:9.0-noble AS aspnet

# https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu
RUN apt-get update && apt-get install -y wget && \
    wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && apt-get install -y --no-install-recommends \
    powershell && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

ENV ASPNETCORE_ENVIRONMENT=Production
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
ENV DOTNET_NOLOGO=true
ENV DOTNET_CLI_TELEMETRY_OPTOUT=true
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_ENABLEDIAGNOSTICS=0
ENV COMPlus_EnableDiagnostics=0
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

WORKDIR /app
COPY . .
RUN chown -R $APP_UID:$APP_UID .

RUN mkdir /ms-playwright && pwsh ./playwright.ps1 install --with-deps chromium && chmod -R 777 /ms-playwright && \
    apt-get remove wget powershell -y

USER $APP_UID
EXPOSE 5000

ENTRYPOINT ["dotnet", "DevEnterprise.Html2Pdf.Service.dll"]
