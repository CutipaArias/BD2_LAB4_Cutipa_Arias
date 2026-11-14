using App.Neo4j.Api.Models;
using App.Neo4j.Api.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace App.Neo4j.Api.Controllers;

[ApiController]
[Route("movie")]
public class MoviesController : Controller
{
    private readonly IMovieRepository _movieRepository;

    public MoviesController(IMovieRepository movieRepository)
    {
        _movieRepository = movieRepository;
    }

    [Route("{title}")]
    [HttpGet]
    public Task<Movie?> GetMovieDetails([FromRoute] string title)
    {
        return _movieRepository.FindByTitle(title);
    }

    [Route("{title}/vote")]
    [HttpPost]
    public Task<int> VoteInMovie([FromRoute] string title)
    {
        return _movieRepository.VoteByTitle(title);
    }

    [Route("search")]
    [HttpGet]
    public Task<List<Movie>> SearchMovies([FromQuery(Name = "q")] string search)
    {
        return _movieRepository.Search(search);
    }

    [Route("graph")]
    [HttpGet]
    public Task<D3Graph> FetchD3Graph([FromQuery] int limit)
    {
        return _movieRepository.FetchD3Graph(limit <= 0 ? 50 : limit);
    }
}
