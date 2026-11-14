FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY App.Neo4j.Api/App.Neo4j.Api.csproj App.Neo4j.Api/
RUN dotnet restore App.Neo4j.Api/App.Neo4j.Api.csproj
COPY App.Neo4j.Api/ App.Neo4j.Api/
RUN dotnet publish App.Neo4j.Api/App.Neo4j.Api.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "App.Neo4j.Api.dll"]
