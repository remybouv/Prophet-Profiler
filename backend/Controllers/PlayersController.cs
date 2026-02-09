using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Models;
using ProphetProfiler.Api.Services;

namespace ProphetProfiler.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PlayersController : ControllerBase
{
    private readonly AppDbContext _context;
    
    public PlayersController(AppDbContext context)
    {
        _context = context;
    }
    
    [HttpGet]
    public async Task<ActionResult<List<Player>>> GetAll()
    {
        var players = await _context.Players
            .Include(p => p.Profile)
            .ToListAsync();
        return Ok(players);
    }
    
    [HttpGet("{id}")]
    public async Task<ActionResult<Player>> GetById(Guid id)
    {
        var player = await _context.Players
            .Include(p => p.Profile)
            .FirstOrDefaultAsync(p => p.Id == id);
        
        if (player == null) return NotFound();
        return Ok(player);
    }
    
    [HttpPost]
    public async Task<ActionResult<Player>> Create([FromBody] CreatePlayerRequest request)
    {
        var player = new Player
        {
            Name = request.Name,
            PhotoUrl = request.PhotoUrl,
            Profile = new PlayerProfile
            {
                Aggressivity = request.Aggressivity,
                Patience = request.Patience,
                Analysis = request.Analysis,
                Bluff = request.Bluff
            }
        };
        
        _context.Players.Add(player);
        await _context.SaveChangesAsync();
        
        return CreatedAtAction(nameof(GetById), new { id = player.Id }, player);
    }
    
    [HttpPut("{id}")]
    public async Task<ActionResult> Update(Guid id, [FromBody] UpdatePlayerRequest request)
    {
        var player = await _context.Players
            .Include(p => p.Profile)
            .FirstOrDefaultAsync(p => p.Id == id);
        
        if (player == null) return NotFound();
        
        player.Name = request.Name ?? player.Name;
        player.PhotoUrl = request.PhotoUrl ?? player.PhotoUrl;
        player.UpdatedAt = DateTime.UtcNow;
        
        if (request.Aggressivity.HasValue) player.Profile.Aggressivity = request.Aggressivity.Value;
        if (request.Patience.HasValue) player.Profile.Patience = request.Patience.Value;
        if (request.Analysis.HasValue) player.Profile.Analysis = request.Analysis.Value;
        if (request.Bluff.HasValue) player.Profile.Bluff = request.Bluff.Value;
        
        await _context.SaveChangesAsync();
        return NoContent();
    }
    
    [HttpDelete("{id}")]
    public async Task<ActionResult> Delete(Guid id)
    {
        var player = await _context.Players.FindAsync(id);
        if (player == null) return NotFound();
        
        _context.Players.Remove(player);
        await _context.SaveChangesAsync();
        return NoContent();
    }
    
    [HttpGet("{id}/bets/history")]
    public async Task<ActionResult<BetHistoryResponse>> GetBetHistory(
        Guid id, 
        [FromQuery] int page = 1, 
        [FromQuery] int pageSize = 10)
    {
        var player = await _context.Players.FindAsync(id);
        if (player == null) return NotFound("Joueur non trouvé");
        
        if (page < 1) page = 1;
        if (pageSize < 1 || pageSize > 100) pageSize = 10;
        
        var query = _context.Bets
            .Where(b => b.BettorId == id)
            .Include(b => b.GameSession)
            .ThenInclude(gs => gs.BoardGame)
            .Include(b => b.PredictedWinner)
            .OrderByDescending(b => b.PlacedAt);
        
        var totalCount = await query.CountAsync();
        var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);
        
        var bets = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
        
        var betHistoryItems = bets.Select(b => new BetHistoryItem
        {
            BetId = b.Id,
            SessionId = b.GameSessionId,
            BoardGameName = b.GameSession.BoardGame.Name,
            PredictedWinnerId = b.PredictedWinnerId,
            PredictedWinnerName = b.PredictedWinner.Name,
            PlacedAt = b.PlacedAt,
            IsCorrect = b.IsCorrect,
            PointsEarned = b.PointsEarned
        }).ToList();
        
        return Ok(new BetHistoryResponse
        {
            Bets = betHistoryItems,
            TotalCount = totalCount,
            Page = page,
            PageSize = pageSize,
            TotalPages = totalPages
        });
    }
}

public record BetHistoryResponse
{
    public List<BetHistoryItem> Bets { get; init; } = new();
    public int TotalCount { get; init; }
    public int Page { get; init; }
    public int PageSize { get; init; }
    public int TotalPages { get; init; }
}

public record BetHistoryItem
{
    public Guid BetId { get; init; }
    public Guid SessionId { get; init; }
    public string BoardGameName { get; init; } = string.Empty;
    public Guid PredictedWinnerId { get; init; }
    public string PredictedWinnerName { get; init; } = string.Empty;
    public DateTime PlacedAt { get; init; }
    public bool? IsCorrect { get; init; }
    public int PointsEarned { get; init; }
}

public record CreatePlayerRequest(
    string Name,
    string? PhotoUrl,
    int Aggressivity = 3,
    int Patience = 3,
    int Analysis = 3,
    int Bluff = 3
);

public record UpdatePlayerRequest(
    string? Name,
    string? PhotoUrl,
    int? Aggressivity,
    int? Patience,
    int? Analysis,
    int? Bluff
);