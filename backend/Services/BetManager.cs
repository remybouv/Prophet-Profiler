using Microsoft.EntityFrameworkCore;
using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Models;

namespace ProphetProfiler.Api.Services;

public class BetManager : IBetManager
{
    private readonly AppDbContext _context;
    
    public BetManager(AppDbContext context)
    {
        _context = context;
    }
    
    public async Task<bool> ValidateBetAsync(Guid sessionId, Guid bettorId, Guid predictedWinnerId)
    {
        var session = await _context.GameSessions
            .Include(gs => gs.Participants)
            .Include(gs => gs.Bets)
            .FirstOrDefaultAsync(gs => gs.Id == sessionId);
        
        if (session == null) return false;
        if (session.Status != SessionStatus.Betting) return false;
        if (!session.Participants.Any(p => p.Id == bettorId)) return false;
        if (!session.Participants.Any(p => p.Id == predictedWinnerId)) return false;
        if (session.Bets.Any(b => b.BettorId == bettorId)) return false; // Déjà parié
        
        // Auto-pari interdit selon les specs MVP
        if (bettorId == predictedWinnerId) return false;
        
        return true;
    }
    
    public async Task<Bet> PlaceBetAsync(Guid sessionId, Guid bettorId, Guid predictedWinnerId)
    {
        if (!await ValidateBetAsync(sessionId, bettorId, predictedWinnerId))
            throw new InvalidOperationException("Pari non valide");
        
        var bet = new Bet
        {
            GameSessionId = sessionId,
            BettorId = bettorId,
            PredictedWinnerId = predictedWinnerId,
            Type = BetType.Winner,
            IsAutoBet = false, // Auto-pari interdit
            PlacedAt = DateTime.UtcNow
        };
        
        _context.Bets.Add(bet);
        await _context.SaveChangesAsync();
        
        return bet;
    }
    
    public async Task<List<Bet>> ResolveBetsAsync(Guid sessionId, Guid actualWinnerId)
    {
        var session = await _context.GameSessions
            .Include(gs => gs.Bets)
            .ThenInclude(b => b.Bettor)
            .Include(gs => gs.Bets)
            .ThenInclude(b => b.PredictedWinner)
            .FirstOrDefaultAsync(gs => gs.Id == sessionId);
        
        if (session == null) throw new InvalidOperationException("Session introuvable");
        
        foreach (var bet in session.Bets)
        {
            bet.IsCorrect = bet.PredictedWinnerId == actualWinnerId;
            
            // Calcul des points selon specs MVP: +10 correct, -2 incorrect
            if (bet.IsCorrect == true)
            {
                bet.PointsEarned = 10;
            }
            else
            {
                bet.PointsEarned = -2;
            }
        }
        
        await _context.SaveChangesAsync();
        return session.Bets.ToList();
    }
    
    public async Task<bool> AllPlayersHaveBetAsync(Guid sessionId)
    {
        var pending = await GetPendingBettorsAsync(sessionId);
        return pending.Count == 0;
    }
    
    public async Task<List<Player>> GetPendingBettorsAsync(Guid sessionId)
    {
        var session = await _context.GameSessions
            .Include(gs => gs.Participants)
            .Include(gs => gs.Bets)
            .FirstOrDefaultAsync(gs => gs.Id == sessionId);
        
        if (session == null) return new List<Player>();
        
        var bettorIds = session.Bets.Select(b => b.BettorId).ToHashSet();
        return session.Participants
            .Where(p => !bettorIds.Contains(p.Id))
            .ToList();
    }
    
    public async Task<BetsSummary> GetBetsSummaryAsync(Guid sessionId)
    {
        var session = await _context.GameSessions
            .Include(gs => gs.Participants)
            .Include(gs => gs.Bets)
            .ThenInclude(b => b.Bettor)
            .Include(gs => gs.Bets)
            .ThenInclude(b => b.PredictedWinner)
            .FirstOrDefaultAsync(gs => gs.Id == sessionId);
        
        if (session == null)
            throw new InvalidOperationException("Session introuvable");
        
        var bettorIds = session.Bets.Select(b => b.BettorId).ToHashSet();
        var pendingBettors = session.Participants
            .Where(p => !bettorIds.Contains(p.Id))
            .Select(p => new PlayerSummary 
            { 
                Id = p.Id, 
                Name = p.Name, 
                PhotoUrl = p.PhotoUrl 
            })
            .ToList();
        
        return new BetsSummary
        {
            SessionId = session.Id,
            SessionStatus = session.Status,
            TotalParticipants = session.Participants.Count,
            TotalBetsPlaced = session.Bets.Count,
            Bets = session.Bets.Select(b => new BetDetail
            {
                BetId = b.Id,
                BettorId = b.BettorId,
                BettorName = b.Bettor.Name,
                PredictedWinnerId = b.PredictedWinnerId,
                PredictedWinnerName = b.PredictedWinner.Name,
                PlacedAt = b.PlacedAt,
                IsCorrect = b.IsCorrect,
                PointsEarned = b.PointsEarned
            }).ToList(),
            PendingBettors = pendingBettors
        };
    }
}