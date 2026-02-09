using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Models;
using ProphetProfiler.Api.Services;

namespace ProphetProfiler.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SessionsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IBetManager _betManager;
    private readonly IRankingService _rankingService;
    
    public SessionsController(AppDbContext context, IBetManager betManager, IRankingService rankingService)
    {
        _context = context;
        _betManager = betManager;
        _rankingService = rankingService;
    }
    
    [HttpGet]
    public async Task<ActionResult<List<GameSession>>> GetAll()
    {
        var sessions = await _context.GameSessions
            .Include(s => s.BoardGame)
            .Include(s => s.Participants)
            .Include(s => s.Winner)
            .OrderByDescending(s => s.Date)
            .ToListAsync();
        return Ok(sessions);
    }
    
    [HttpGet("{id}")]
    public async Task<ActionResult<GameSession>> GetById(Guid id)
    {
        var session = await _context.GameSessions
            .Include(s => s.BoardGame)
            .Include(s => s.Participants)
            .Include(s => s.Bets)
            .ThenInclude(b => b.Bettor)
            .Include(s => s.Bets)
            .ThenInclude(b => b.PredictedWinner)
            .Include(s => s.Winner)
            .FirstOrDefaultAsync(s => s.Id == id);
        
        if (session == null) return NotFound();
        return Ok(session);
    }
    
    [HttpPost]
    public async Task<ActionResult<GameSession>> Create([FromBody] CreateSessionRequest request)
    {
        var game = await _context.BoardGames.FindAsync(request.BoardGameId);
        if (game == null) return NotFound("Jeu non trouvé");
        
        var players = await _context.Players
            .Where(p => request.PlayerIds.Contains(p.Id))
            .ToListAsync();
        
        if (players.Count != request.PlayerIds.Count)
            return BadRequest("Certains joueurs n'existent pas");
        
        var session = new GameSession
        {
            Date = request.Date ?? DateTime.UtcNow,
            Location = request.Location,
            Notes = request.Notes,
            BoardGameId = request.BoardGameId,
            Status = SessionStatus.Created
        };
        
        foreach (var player in players)
        {
            session.Participants.Add(player);
        }
        
        _context.GameSessions.Add(session);
        await _context.SaveChangesAsync();
        
        return CreatedAtAction(nameof(GetById), new { id = session.Id }, session);
    }
    
    [HttpGet("{id}/bets/summary")]
    public async Task<ActionResult<BetsSummary>> GetBetsSummary(Guid id)
    {
        try
        {
            var summary = await _betManager.GetBetsSummaryAsync(id);
            return Ok(summary);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(ex.Message);
        }
    }
    
    [HttpPost("{id}/transition")]
    public async Task<ActionResult> TransitionStatus(Guid id, [FromBody] TransitionRequest request)
    {
        var session = await _context.GameSessions
            .Include(s => s.Participants)
            .FirstOrDefaultAsync(s => s.Id == id);
        
        if (session == null) return NotFound("Session non trouvée");
        
        // Vérifier les transitions valides
        var validTransition = (session.Status, request.NewStatus) switch
        {
            (SessionStatus.Created, SessionStatus.Betting) => true,
            (SessionStatus.Betting, SessionStatus.Playing) => true,
            (SessionStatus.Playing, SessionStatus.Completed) => true,
            (SessionStatus.Created, SessionStatus.Cancelled) => true,
            (SessionStatus.Betting, SessionStatus.Cancelled) => true,
            _ => false
        };
        
        if (!validTransition)
            return BadRequest($"Transition invalide de {session.Status} vers {request.NewStatus}");
        
        // Vérifier minimum 2 joueurs pour Betting
        if (request.NewStatus == SessionStatus.Betting && session.Participants.Count < 2)
            return BadRequest("Minimum 2 joueurs requis pour activer les paris");
        
        session.Status = request.NewStatus;
        await _context.SaveChangesAsync();
        
        return NoContent();
    }
    
    [HttpPost("{id}/start-betting")]
    public async Task<ActionResult> StartBetting(Guid id)
    {
        var session = await _context.GameSessions
            .Include(s => s.Participants)
            .FirstOrDefaultAsync(s => s.Id == id);
        
        if (session == null) return NotFound();
        
        if (session.Status != SessionStatus.Created)
            return BadRequest("La session doit être en statut Created");
        
        // Vérifier minimum 2 joueurs pour Betting
        if (session.Participants.Count < 2)
            return BadRequest("Minimum 2 joueurs requis pour activer les paris");
        
        session.Status = SessionStatus.Betting;
        await _context.SaveChangesAsync();
        
        return NoContent();
    }
    
    [HttpPost("{id}/bets")]
    public async Task<ActionResult<Bet>> PlaceBet(Guid id, [FromBody] PlaceBetRequest request)
    {
        // Vérifier explicitement l'auto-pari interdit
        if (request.BettorId == request.PredictedWinnerId)
            return BadRequest("Auto-pari interdit : vous ne pouvez pas parier sur vous-même");
        
        try
        {
            var bet = await _betManager.PlaceBetAsync(id, request.BettorId, request.PredictedWinnerId);
            return Ok(bet);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }
    
    [HttpGet("{id}/pending-bettors")]
    public async Task<ActionResult<List<Player>>> GetPendingBettors(Guid id)
    {
        var pending = await _betManager.GetPendingBettorsAsync(id);
        return Ok(pending);
    }
    
    [HttpPost("{id}/complete")]
    public async Task<ActionResult> CompleteSession(Guid id, [FromBody] CompleteSessionRequest request)
    {
        var session = await _context.GameSessions
            .Include(s => s.Participants)
            .FirstOrDefaultAsync(s => s.Id == id);
        
        if (session == null) return NotFound();
        
        if (!session.Participants.Any(p => p.Id == request.WinnerId))
            return BadRequest("Le gagnant doit être un participant");
        
        // Résoudre les paris
        await _betManager.ResolveBetsAsync(id, request.WinnerId);
        
        // Mettre à jour la session
        session.WinnerId = request.WinnerId;
        session.Status = SessionStatus.Completed;
        session.CompletedAt = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        
        // Mettre à jour les stats
        await _rankingService.UpdateStatsAfterSessionAsync(id);
        
        return NoContent();
    }
}

public record CreateSessionRequest(
    Guid BoardGameId,
    List<Guid> PlayerIds,
    DateTime? Date,
    string? Location,
    string? Notes
);

public record PlaceBetRequest(Guid BettorId, Guid PredictedWinnerId);

public record TransitionRequest(SessionStatus NewStatus);

public record CompleteSessionRequest(Guid WinnerId);