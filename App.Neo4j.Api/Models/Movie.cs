namespace App.Neo4j.Api.Models;

public record Movie(string Title, IEnumerable<Person>? Cast = null, long? Released = null, string? Tagline = null,
    long? Votes = null);
