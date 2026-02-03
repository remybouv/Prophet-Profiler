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
            
            // Calcul des points
            if (bet.IsCorrect == true)
            {
                bet.PointsEarned = 10; // Base
                if (bet.BettorId == actualWinnerId)
                    bet.PointsEarned += 5; // Bonus auto-pari gagnant
            }
            else if (bet.BettorId == bet.PredictedWinnerId)
            {
                bet.PointsEarned = -2; // Pénalité auto-pari perdant
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
}