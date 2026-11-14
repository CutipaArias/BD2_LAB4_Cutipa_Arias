using App.Neo4j.Api.Repositories;
using Neo4j.Driver;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddScoped<IMovieRepository, MovieRepository>();
builder.Services.AddSingleton(GraphDatabase.Driver(
    builder.Configuration.GetSection("neo4jdb")["NEO4J_URI"] ?? "neo4j+s://demo.neo4jlabs.com",
    AuthTokens.Basic(
        builder.Configuration.GetSection("neo4jdb")["NEO4J_USER"] ?? "movies",
        builder.Configuration.GetSection("neo4jdb")["NEO4J_PASSWORD"] ?? "movies"
    )
));

var app = builder.Build();

app.UseDefaultFiles();
app.UseStaticFiles();
app.MapControllers();

app.Run();
