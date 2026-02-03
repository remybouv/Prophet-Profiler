using Microsoft.EntityFrameworkCore;
using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Models;

namespace ProphetProfiler.Api.Services;

public class RankingService : IRankingService
{
    private readonly AppDbContext _context;
    
    public RankingService(AppDbContext context)
    {
        _context = context;
    }
    
    public async Task<List<RankingEntry>> GetChampionsGlobalAsync(int top = 10)
    {
        var stats = await _context.PlayerStats
            .Where(ps => ps.BoardGameId == null && ps.TotalGamesPlayed >= 3)
            .Include(ps => ps.Player)
            .OrderByDescending(ps => (double)ps.GamesWon / ps.TotalGamesPlayed)
            .ThenByDescending(ps => ps.TotalGamesPlayed)
            .Take(top)
            .ToListAsync();
        
        return stats.Select((ps, index) => new RankingEntry
        {
            PlayerId = ps.PlayerId,
            PlayerName = ps.Player.Name,
            PlayerPhotoUrl = ps.Player.PhotoUrl,
            Rank = index + 1,
            Score = ps.TotalGamesPlayed > 0 ? (double)ps.GamesWon / ps.TotalGamesPlayed * 100 : 0,
            TotalGames = ps.TotalGamesPlayed
        }).ToList();
    }
    
    public async Task<List<RankingEntry>> GetChampionsByGameAsync(Guid boardGameId, int top = 10)
    {
        var stats = await _context.PlayerStats
            .Where(ps => ps.BoardGameId == boardGameId && ps.TotalGamesPlayed >= 3)
            .Include(ps => ps.Player)
            .OrderByDescending(ps => (double)ps.GamesWon / ps.TotalGamesPlayed)
            .ThenByDescending(ps => ps.TotalGamesPlayed)
            .Take(top)
            .ToListAsync();
        
        return stats.Select((ps, index) => new RankingEntry
        {
            PlayerId = ps.PlayerId,
            PlayerName = ps.Player.Name,
            PlayerPhotoUrl = ps.Player.PhotoUrl,
            Rank = index + 1,
            Score = ps.TotalGamesPlayed > 0 ? (double)ps.GamesWon / ps.TotalGamesPlayed * 100 : 0,
            TotalGames = ps.TotalGamesPlayed
        }).ToList();
    }
    
    public async Task<List<RankingEntry>> GetOraclesGlobalAsync(int top = 10)
    {
        var stats = await _context.PlayerStats
            .Where(ps => ps.BoardGameId == null && ps.TotalBetsPlaced >= 5)
            .Include(ps => ps.Player)
            .OrderByDescending(ps => (double)ps.BetsCorrect / ps.TotalBetsPlaced)
            .ThenByDescending(ps => ps.TotalBetsPlaced)
            .Take(top)
            .ToListAsync();
        
        return stats.Select((ps, index) => new RankingEntry
        {
            PlayerId = ps.PlayerId,
            PlayerName = ps.Player.Name,
            PlayerPhotoUrl = ps.Player.PhotoUrl,
            Rank = index + 1,
            Score = ps.TotalBetsPlaced > 0 ? (double)ps.BetsCorrect / ps.TotalBetsPlaced * 100 : 0,
            TotalGames = ps.TotalBetsPlaced
        }).ToList();
    }
    
    public async Task<List<RankingEntry>> GetOraclesByGameAsync(Guid boardGameId, int top = 10)
    {
        var stats = await _context.PlayerStats
            .Where(ps => ps.BoardGameId == boardGameId && ps.TotalBetsPlaced >= 5)
            .Include(ps => ps.Player)
            .OrderByDescending(ps => (double)ps.BetsCorrect / ps.TotalBetsPlaced)
            .ThenByDescending(ps => ps.TotalBetsPlaced)
            .Take(top)
            .ToListAsync();
        
        return stats.Select((ps, index) => new RankingEntry
        {
            PlayerId = ps.PlayerId,
            PlayerName = ps.Player.Name,
            PlayerPhotoUrl = ps.Player.PhotoUrl,
            Rank = index + 1,
            Score = ps.TotalBetsPlaced > 0 ? (double)ps.BetsCorrect / ps.TotalBetsPlaced * 100 : 0,
            TotalGames = ps.TotalBetsPlaced
        }).ToList();
    }
    
    public async Task UpdateStatsAfterSessionAsync(Guid sessionId)
    {
        var session = await _context.GameSessions
            .Include(gs => gs.Participants)
            .Include(gs => gs.Bets)
            .Include(gs => gs.BoardGame)
            .FirstOrDefaultAsync(gs => gs.Id == sessionId);
        
        if (session?.WinnerId == null) return;
        
        foreach (var participant in session.Participants)
        {
            // Stats globales
            var globalStats = await GetOrCreateStatsAsync(participant.Id, null);
            globalStats.RecordGamePlayed(participant.Id == session.WinnerId);
            
            // Stats par jeu
            var gameStats = await GetOrCreateStatsAsync(participant.Id, session.BoardGameId);
            gameStats.RecordGamePlayed(participant.Id == session.WinnerId);
        }
        
        // Stats Oracles (prédictions)
        foreach (var bet in session.Bets)
        {
            var globalStats = await GetOrCreateStatsAsync(bet.BettorId, null);
            globalStats.RecordBet(bet.IsCorrect == true, bet.PointsEarned);
            
            var gameStats = await GetOrCreateStatsAsync(bet.BettorId, session.BoardGameId);
            gameStats.RecordBet(bet.IsCorrect == true, bet.PointsEarned);
        }
        
        await _context.SaveChangesAsync();
    }
    
    private async Task<PlayerStats> GetOrCreateStatsAsync(Guid playerId, Guid? boardGameId)
    {
        var stats = await _context.PlayerStats
            .FirstOrDefaultAsync(ps => ps.PlayerId == playerId && ps.BoardGameId == boardGameId);
        
        if (stats == null)
        {
            stats = new PlayerStats
            {
                PlayerId = playerId,
                BoardGameId = boardGameId
            };
            _context.PlayerStats.Add(stats);
        }
        
        return stats;
    }
}