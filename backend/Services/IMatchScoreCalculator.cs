using ProphetProfiler.Api.Models;

namespace ProphetProfiler.Api.Services;

public interface IMatchScoreCalculator
{
    MatchScore CalculateScore(List<Player> players, BoardGame boardGame);
    Task<MatchScore?> FindBestMatchAsync(List<Player> players);
    Task<List<MatchScore>> RankAllGamesAsync(List<Player> players);
}

public record MatchScore
{
    public required BoardGame BoardGame { get; init; }
    public required double Score { get; init; } // 0-100
    
    public MatchQuality Quality => Score switch
    {
        >= 90 => MatchQuality.Perfect,
        >= 75 => MatchQuality.Great,
        >= 60 => MatchQuality.Good,
        >= 40 => MatchQuality.Average,
        >= 25 => MatchQuality.Poor,
        _ => MatchQuality.Avoid
    };
    
    public Dictionary<GameAxis, double> AxisScores { get; init; } = new();
    
    public string Recommendation => Quality switch
    {
        MatchQuality.Perfect => "🎯 Parfait pour ce groupe !",
        MatchQuality.Great => "✨ Excellent choix",
        MatchQuality.Good => "👍 Bonne idée",
        MatchQuality.Average => "🤷 Ça peut marcher",
        MatchQuality.Poor => "⚠️ Pas idéal",
        MatchQuality.Avoid => "❌ À éviter avec ce groupe",
        _ => string.Empty
    };
}