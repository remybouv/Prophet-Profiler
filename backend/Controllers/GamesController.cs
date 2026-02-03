using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Models;
using ProphetProfiler.Api.Services;

namespace ProphetProfiler.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class GamesController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IMatchScoreCalculator _matchScoreCalculator;
    
    public GamesController(AppDbContext context, IMatchScoreCalculator matchScoreCalculator)
    {
        _context = context;
        _matchScoreCalculator = matchScoreCalculator;
    }
    
    [HttpGet]
    public async Task<ActionResult<List<BoardGame>>> GetAll()
    {
        var games = await _context.BoardGames
            .Include(g => g.Profile)
            .ToListAsync();
        return Ok(games);
    }
    
    [HttpGet("{id}")]
    public async Task<ActionResult<BoardGame>> GetById(Guid id)
    {
        var game = await _context.BoardGames
            .Include(g => g.Profile)
            .FirstOrDefaultAsync(g => g.Id == id);
        
        if (game == null) return NotFound();
        return Ok(game);
    }
    
    [HttpPost]
    public async Task<ActionResult<BoardGame>> Create([FromBody] CreateGameRequest request)
    {
        var game = new BoardGame
        {
            Name = request.Name,
            Description = request.Description,
            PhotoUrl = request.PhotoUrl,
            MinPlayers = request.MinPlayers,
            MaxPlayers = request.MaxPlayers,
            AverageDuration = request.AverageDuration,
            Profile = new GameProfile
            {
                Aggressivity = request.Aggressivity,
                Patience = request.Patience,
                Analysis = request.Analysis,
                Bluff = request.Bluff
            }
        };
        
        _context.BoardGames.Add(game);
        await _context.SaveChangesAsync();
        
        return CreatedAtAction(nameof(GetById), new { id = game.Id }, game);
    }
    
    [HttpPost("match-score")]
    public async Task<ActionResult<MatchScore>> CalculateMatchScore([FromBody] MatchScoreRequest request)
    {
        var players = await _context.Players
            .Include(p => p.Profile)
            .Where(p => request.PlayerIds.Contains(p.Id))
            .ToListAsync();
        
        if (players.Count != request.PlayerIds.Count)
            return BadRequest("Certains joueurs n'existent pas");
        
        if (request.GameId.HasValue)
        {
            var game = await _context.BoardGames
                .Include(g => g.Profile)
                .FirstOrDefaultAsync(g => g.Id == request.GameId.Value);
            
            if (game == null) return NotFound("Jeu non trouvé");
            
            var score = _matchScoreCalculator.CalculateScore(players, game);
            return Ok(score);
        }
        else
        {
            var bestMatch = await _matchScoreCalculator.FindBestMatchAsync(players);
            if (bestMatch == null) return NotFound("Aucun jeu disponible");
            return Ok(bestMatch);
        }
    }
    
    [HttpPost("rank")]
    public async Task<ActionResult<List<MatchScore>>> RankGames([FromBody] List<Guid> playerIds)
    {
        var players = await _context.Players
            .Include(p => p.Profile)
            .Where(p => playerIds.Contains(p.Id))
            .ToListAsync();
        
        if (players.Count != playerIds.Count)
            return BadRequest("Certains joueurs n'existent pas");
        
        var rankings = await _matchScoreCalculator.RankAllGamesAsync(players);
        return Ok(rankings);
    }
}

public record CreateGameRequest(
    string Name,
    string? Description,
    string? PhotoUrl,
    int MinPlayers = 2,
    int MaxPlayers = 4,
    int? AverageDuration = null,
    int Aggressivity = 3,
    int Patience = 3,
    int Analysis = 3,
    int Bluff = 3
);

public record MatchScoreRequest(List<Guid> PlayerIds, Guid? GameId);