using ProphetProfiler.Api.Models;

namespace ProphetProfiler.Api.Services;

public interface IBetManager
{
    Task<Bet> PlaceBetAsync(Guid sessionId, Guid bettorId, Guid predictedWinnerId);
    Task<bool> ValidateBetAsync(Guid sessionId, Guid bettorId, Guid predictedWinnerId);
    Task<List<Bet>> ResolveBetsAsync(Guid sessionId, Guid actualWinnerId);
    Task<bool> AllPlayersHaveBetAsync(Guid sessionId);
    Task<List<Player>> GetPendingBettorsAsync(Guid sessionId);
}