using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Models;
using ProphetProfiler.Api.Models.Dtos;
using ProphetProfiler.Api.Services;

namespace ProphetProfiler.Api.Controllers;

/// <summary>
/// Contrôleur pour la création et gestion des sessions de paris
/// Page "Création Paris" - Workflow unifié
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class BetCreationController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IBetManager _betManager;
    private readonly ILogger<BetCreationController> _logger;

    public BetCreationController(
        AppDbContext context, 
        IBetManager betManager,
        ILogger<BetCreationController> logger)
    {
        _context = context;
        _betManager = betManager;
        _logger = logger;
    }

    /// <summary>
    /// Récupère la liste des joueurs disponibles pour une nouvelle session
    /// GET /api/betcreation/available-players
    /// </summary>
    [HttpGet("available-players")]
    public async Task<ActionResult<AvailablePlayersResponse>> GetAvailablePlayers()
    {
        var players = await _context.Players
            .Include(p => p.Sessions)
            .OrderBy(p => p.Name)
            .Select(p => new PlayerSummaryDto
            {
                Id = p.Id,
                Name = p.Name,
                PhotoUrl = p.PhotoUrl,
                TotalSessions = p.Sessions.Count,
                TotalWins = _context.PlayerStats
                    .Where(ps => ps.PlayerId == p.Id)
                    .Sum(ps => ps.GamesWon)
            })
            .ToListAsync();

        return Ok(new AvailablePlayersResponse
        {
            Players = players,
            TotalCount = players.Count()
        });
    }

    /// <summary>
    /// Crée une nouvelle session de paris avec participants
    /// POST /api/betcreation/create-session
    /// </summary>
    [HttpPost("create-session")]
    public async Task<ActionResult<GameSession>> CreateBetSession([FromBody] CreateBetSessionRequest request)
    {
        // Validation: Vérifier le jeu
        var game = await _context.BoardGames.FindAsync(request.BoardGameId);
        if (game == null)
        {
            _logger.LogWarning("Tentative de création avec jeu inexistant: {GameId}", request.BoardGameId);
            return NotFound(new { error = "Jeu non trouvé", gameId = request.BoardGameId });
        }

        // Validation: Minimum 2 joueurs
        if (request.PlayerIds == null || request.PlayerIds.Count < 2)
        {
            return BadRequest(new { error = "Minimum 2 joueurs requis pour créer une session de paris" });
        }

        // Validation: Vérifier que tous les joueurs existent
        var players = await _context.Players
            .Where(p => request.PlayerIds.Contains(p.Id))
            .ToListAsync();

        if (players.Count != request.PlayerIds.Count)
        {
            var foundIds = players.Select(p => p.Id).ToHashSet();
            var missingIds = request.PlayerIds.Where(id => !foundIds.Contains(id)).ToList();
            return BadRequest(new { error = "Certains joueurs n'existent pas", missingIds });
        }

        // Validation: Vérifier doublons dans PlayerIds
        var uniqueIds = request.PlayerIds.Distinct().Count();
        if (uniqueIds != request.PlayerIds.Count)
        {
            return BadRequest(new { error = "Un joueur ne peut pas être ajouté plusieurs fois à la même session" });
        }

        // Création de la session
        var session = new GameSession
        {
            Date = request.Date ?? DateTime.UtcNow,
            Location = request.Location,
            Notes = request.Notes,
            BoardGameId = request.BoardGameId,
            Status = SessionStatus.Betting, // Directement en mode Betting
            CreatedAt = DateTime.UtcNow
        };

        // Ajouter les participants
        foreach (var player in players)
        {
            session.Participants.Add(player);
        }

        _context.GameSessions.Add(session);
        await _context.SaveChangesAsync();

        _logger.LogInformation(
            "Session de paris créée: {SessionId} avec {PlayerCount} joueurs sur {GameName}",
            session.Id, players.Count, game.Name);

        // Recharger avec les relations pour la réponse
        var createdSession = await _context.GameSessions
            .Include(s => s.BoardGame)
            .Include(s => s.Participants)
            .FirstAsync(s => s.Id == session.Id);

        return CreatedAtAction(
            nameof(GetSessionDetails), 
            new { id = session.Id }, 
            createdSession);
    }

    /// <summary>
    /// Récupère les détails d'une session créée
    /// GET /api/betcreation/session/{id}
    /// </summary>
    [HttpGet("session/{id:guid}")]
    public async Task<ActionResult<SessionActiveDetails>> GetSessionDetails(Guid id)
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

        if (session == null)
            return NotFound(new { error = "Session non trouvée", sessionId = id });

        // Construire les infos participants avec statut pari
        var bettorInfoMap = session.Bets.ToDictionary(
            b => b.BettorId, 
            b => new { b.PredictedWinnerId, b.PredictedWinner.Name, b.PlacedAt });

        var participants = session.Participants.Select(p => new ParticipantBetInfo
        {
            PlayerId = p.Id,
            Name = p.Name,
            PhotoUrl = p.PhotoUrl,
            HasPlacedBet = bettorInfoMap.ContainsKey(p.Id),
            BetOnPlayerId = bettorInfoMap.TryGetValue(p.Id, out var info) ? info.PredictedWinnerId : null,
            BetOnPlayerName = bettorInfoMap.TryGetValue(p.Id, out var info2) ? info2.Name : null,
            BetPlacedAt = bettorInfoMap.TryGetValue(p.Id, out var info3) ? info3.PlacedAt : null
        }).ToList();

        // Construire les détails des paris
        var bets = session.Bets.Select(b => new BetDetailDto
        {
            BetId = b.Id,
            BettorId = b.BettorId,
            BettorName = b.Bettor.Name,
            BettorPhotoUrl = b.Bettor.PhotoUrl,
            PredictedWinnerId = b.PredictedWinnerId,
            PredictedWinnerName = b.PredictedWinner.Name,
            PlacedAt = b.PlacedAt,
            IsCorrect = b.IsCorrect,
            PointsEarned = b.PointsEarned
        }).ToList();

        var details = new SessionActiveDetails
        {
            SessionId = session.Id,
            BoardGameName = session.BoardGame.Name,
            Status = session.Status,
            Date = session.Date,
            Location = session.Location,
            Participants = participants,
            Bets = bets,
            CurrentWinnerId = session.WinnerId,
            CurrentWinnerName = session.Winner?.Name,
            TotalPointsInPlay = session.Bets.Count * 10, // 10 pts potentiels par pari gagnant
            AllPlayersHaveBet = participants.All(p => p.HasPlacedBet),
            CanStartPlaying = participants.All(p => p.HasPlacedBet) && session.Status == SessionStatus.Betting
        };

        return Ok(details);
    }

    /// <summary>
    /// Place un pari pour un joueur
    /// POST /api/betcreation/session/{id}/place-bet
    /// </summary>
    [HttpPost("session/{id:guid}/place-bet")]
    public async Task<ActionResult<Bet>> PlaceBet(Guid id, [FromBody] PlaceBetRequest request)
    {
        // Vérifier auto-pari
        if (request.BettorId == request.PredictedWinnerId)
            return BadRequest(new { error = "Auto-pari interdit : vous ne pouvez pas parier sur vous-même" });

        try
        {
            var bet = await _betManager.PlaceBetAsync(id, request.BettorId, request.PredictedWinnerId);
            _logger.LogInformation(
                "Pari placé: Session {SessionId}, Bettor {BettorId} -> {WinnerId}",
                id, request.BettorId, request.PredictedWinnerId);
            return Ok(bet);
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning("Échec placement pari: {Error}", ex.Message);
            return BadRequest(new { error = ex.Message });
        }
    }

    /// <summary>
    /// Définit le gagnant et résout les paris
    /// POST /api/betcreation/session/{id}/set-winner
    /// </summary>
    [HttpPost("session/{id:guid}/set-winner")]
    public async Task<ActionResult<SetWinnerResponse>> SetWinner(
        Guid id, 
        [FromBody] SetWinnerRequest request,
        [FromServices] IRankingService rankingService)
    {
        var session = await _context.GameSessions
            .Include(s => s.Participants)
            .Include(s => s.Bets)
            .ThenInclude(b => b.Bettor)
            .Include(s => s.BoardGame)
            .FirstOrDefaultAsync(s => s.Id == id);

        if (session == null)
            return NotFound(new { error = "Session non trouvée" });

        // Vérifier que le gagnant est un participant
        if (!session.Participants.Any(p => p.Id == request.WinnerId))
            return BadRequest(new { error = "Le gagnant doit être un participant de la session" });

        // Vérifier le statut actuel
        if (session.Status != SessionStatus.Betting && session.Status != SessionStatus.Playing)
            return BadRequest(new { error = $"Impossible de définir un gagnant depuis le statut {session.Status}" });

        // Résoudre les paris
        var resolvedBets = await _betManager.ResolveBetsAsync(id, request.WinnerId);

        // Mettre à jour la session
        session.WinnerId = request.WinnerId;
        session.Status = SessionStatus.Completed;
        session.CompletedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        // Mettre à jour les statistiques
        await rankingService.UpdateStatsAfterSessionAsync(id);

        // Construire la réponse
        var resolutions = resolvedBets.Select(b => new BetResolutionDto
        {
            BettorId = b.BettorId,
            BettorName = b.Bettor.Name,
            BettorPhotoUrl = b.Bettor.PhotoUrl,
            PredictedWinnerId = b.PredictedWinnerId,
            IsCorrect = b.IsCorrect ?? false,
            PointsEarned = b.PointsEarned,
            ResultEmoji = b.IsCorrect == true ? "🎯" : "❌"
        }).ToList();

        var winner = session.Participants.First(p => p.Id == request.WinnerId);

        _logger.LogInformation(
            "Session {SessionId} terminée. Gagnant: {WinnerName}. {CorrectCount}/{TotalCount} paris corrects",
            id, winner.Name, resolutions.Count(r => r.IsCorrect), resolutions.Count);

        return Ok(new SetWinnerResponse
        {
            SessionId = session.Id,
            WinnerId = request.WinnerId,
            WinnerName = winner.Name,
            NewStatus = SessionStatus.Completed,
            BetResolutions = resolutions,
            TotalPointsAwarded = resolutions.Where(r => r.IsCorrect).Sum(r => r.PointsEarned),
            TotalPointsDeducted = resolutions.Where(r => !r.IsCorrect).Sum(r => r.PointsEarned)
        });
    }

    /// <summary>
    /// Démarrer la partie (transition Betting -> Playing)
    /// POST /api/betcreation/session/{id}/start-playing
    /// </summary>
    [HttpPost("session/{id:guid}/start-playing")]
    public async Task<ActionResult> StartPlaying(Guid id)
    {
        var session = await _context.GameSessions
            .Include(s => s.Bets)
            .Include(s => s.Participants)
            .FirstOrDefaultAsync(s => s.Id == id);

        if (session == null)
            return NotFound();

        if (session.Status != SessionStatus.Betting)
            return BadRequest(new { error = $"Transition invalide depuis {session.Status}" });

        // Optionnel: vérifier que tous ont parié
        var bettorIds = session.Bets.Select(b => b.BettorId).ToHashSet();
        var allHaveBet = session.Participants.All(p => bettorIds.Contains(p.Id));

        session.Status = SessionStatus.Playing;
        await _context.SaveChangesAsync();

        _logger.LogInformation("Session {SessionId} démarrée (Playing)", id);

        return Ok(new { message = "Partie démarrée", allPlayersHaveBet = allHaveBet });
    }
}

public record PlaceBetRequest(Guid BettorId, Guid PredictedWinnerId);
