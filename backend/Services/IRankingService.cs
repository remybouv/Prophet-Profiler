using ProphetProfiler.Api.Models;

namespace ProphetProfiler.Api.Services;

public interface IRankingService
{
    Task<List<RankingEntry>> GetChampionsGlobalAsync(int top = 10);
    Task<List<RankingEntry>> GetChampionsByGameAsync(Guid boardGameId, int top = 10);
    Task<List<RankingEntry>> GetOraclesGlobalAsync(int top = 10);
    Task<List<RankingEntry>> GetOraclesByGameAsync(Guid boardGameId, int top = 10);
    Task UpdateStatsAfterSessionAsync(Guid sessionId);
}

public record RankingEntry
{
    public required Guid PlayerId { get; init; }
    public required string PlayerName { get; init; }
    public string? PlayerPhotoUrl { get; init; }
    public int Rank { get; init; }
    public double Score { get; init; } // WinRate ou PredictionAccuracy
    public int TotalGames { get; init; }
}