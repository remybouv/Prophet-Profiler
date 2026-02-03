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