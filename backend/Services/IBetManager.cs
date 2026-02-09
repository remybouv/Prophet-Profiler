using ProphetProfiler.Api.Models;

namespace ProphetProfiler.Api.Services;

public interface IBetManager
{
    Task<Bet> PlaceBetAsync(Guid sessionId, Guid bettorId, Guid predictedWinnerId);
    Task<bool> ValidateBetAsync(Guid sessionId, Guid bettorId, Guid predictedWinnerId);
    Task<List<Bet>> ResolveBetsAsync(Guid sessionId, Guid actualWinnerId);
    Task<bool> AllPlayersHaveBetAsync(Guid sessionId);
    Task<List<Player>> GetPendingBettorsAsync(Guid sessionId);
    Task<BetsSummary> GetBetsSummaryAsync(Guid sessionId);
}

public record BetsSummary
{
    public Guid SessionId { get; init; }
    public SessionStatus SessionStatus { get; init; }
    public int TotalParticipants { get; init; }
    public int TotalBetsPlaced { get; init; }
    public List<BetDetail> Bets { get; init; } = new();
    public List<PlayerSummary> PendingBettors { get; init; } = new();
}

public record BetDetail
{
    public Guid BetId { get; init; }
    public Guid BettorId { get; init; }
    public string BettorName { get; init; } = string.Empty;
    public Guid PredictedWinnerId { get; init; }
    public string PredictedWinnerName { get; init; } = string.Empty;
    public DateTime PlacedAt { get; init; }
    public bool? IsCorrect { get; init; }
    public int PointsEarned { get; init; }
}

public record PlayerSummary
{
    public Guid Id { get; init; }
    public string Name { get; init; } = string.Empty;
    public string? PhotoUrl { get; init; }
}