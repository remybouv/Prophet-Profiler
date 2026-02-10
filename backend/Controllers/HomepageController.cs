using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Models;
using ProphetProfiler.Api.Models.Dtos;

namespace ProphetProfiler.Api.Controllers;

/// <summary>
/// Contrôleur pour les données de la Homepage
/// Regroupe toutes les informations nécessaires pour l'écran d'accueil
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class HomepageController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ILogger<HomepageController> _logger;

    public HomepageController(AppDbContext context, ILogger<HomepageController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Récupère toutes les données pour la homepage
    /// GET /api/homepage/data
    /// </summary>
    [HttpGet("data")]
    public async Task<ActionResult<HomepageDataResponse>> GetHomepageData()
    {
        // Récupérer la session active (Betting ou Playing)
        var activeSession = await _context.GameSessions
            .Include(s => s.BoardGame)
            .Include(s => s.Participants)
            .Include(s => s.Bets)
            .Where(s => s.Status == SessionStatus.Betting || s.Status == SessionStatus.Playing)
            .OrderByDescending(s => s.CreatedAt)
            .Select(s => new ActiveSessionInfo
            {
                SessionId = s.Id,
                BoardGameName = s.BoardGame.Name,
                Status = s.Status,
                Date = s.Date,
                ParticipantCount = s.Participants.Count,
                BetsPlacedCount = s.Bets.Count,
                HasActiveSession = true
            })
            .FirstOrDefaultAsync();

        // Compter les totaux
        var totalPlayers = await _context.Players.CountAsync();
        var totalGames = await _context.BoardGames.CountAsync();

        // Sessions récentes (5 dernières)
        var recentSessions = await _context.GameSessions
            .Include(s => s.BoardGame)
            .Include(s => s.Winner)
            .OrderByDescending(s => s.Date)
            .Take(5)
            .Select(s => new RecentSessionDto
            {
                SessionId = s.Id,
                BoardGameName = s.BoardGame.Name,
                Date = s.Date,
                Status = s.Status,
                WinnerName = s.Winner != null ? s.Winner.Name : null
            })
            .ToListAsync();

        _logger.LogInformation(
            "Homepage data loaded. Active session: {HasActive}, Players: {Players}, Games: {Games}",
            activeSession?.HasActiveSession ?? false, totalPlayers, totalGames);

        return Ok(new HomepageDataResponse
        {
            ActiveSession = activeSession,
            TotalPlayers = totalPlayers,
            TotalGames = totalGames,
            RecentSessions = recentSessions
        });
    }

    /// <summary>
    /// Vérifie s'il existe une session active
    /// GET /api/homepage/has-active-session
    /// </summary>
    [HttpGet("has-active-session")]
    public async Task<ActionResult<object>> HasActiveSession()
    {
        var hasActiveSession = await _context.GameSessions
            .AnyAsync(s => s.Status == SessionStatus.Betting || s.Status == SessionStatus.Playing);

        var activeSessionId = hasActiveSession
            ? await _context.GameSessions
                .Where(s => s.Status == SessionStatus.Betting || s.Status == SessionStatus.Playing)
                .OrderByDescending(s => s.CreatedAt)
                .Select(s => (Guid?)s.Id)
                .FirstOrDefaultAsync()
            : null;

        return Ok(new { hasActiveSession, activeSessionId });
    }

    /// <summary>
    /// Récupère les statistiques rapides pour les tuiles de la homepage
    /// GET /api/homepage/quick-stats
    /// </summary>
    [HttpGet("quick-stats")]
    public async Task<ActionResult<object>> GetQuickStats()
    {
        var totalPlayers = await _context.Players.CountAsync();
        var totalGames = await _context.BoardGames.CountAsync();
        var totalSessions = await _context.GameSessions.CountAsync();
        var completedSessions = await _context.GameSessions.CountAsync(s => s.Status == SessionStatus.Completed);
        
        var totalBets = await _context.Bets.CountAsync();
        var correctBets = await _context.Bets.CountAsync(b => b.IsCorrect == true);
        var winRate = totalBets > 0 ? (double)correctBets / totalBets * 100 : 0;

        return Ok(new
        {
            TotalPlayers = totalPlayers,
            TotalGames = totalGames,
            TotalSessions = totalSessions,
            CompletedSessions = completedSessions,
            TotalBets = totalBets,
            CorrectBets = correctBets,
            GlobalWinRate = Math.Round(winRate, 1)
        });
    }
}
