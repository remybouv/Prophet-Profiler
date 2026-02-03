using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Models;

namespace ProphetProfiler.Api.Services;

public class MatchScoreCalculator : IMatchScoreCalculator
{
    private readonly AppDbContext _context;
    
    public MatchScoreCalculator(AppDbContext context)
    {
        _context = context;
    }
    
    public MatchScore CalculateScore(List<Player> players, BoardGame boardGame)
    {
        if (players.Count == 0)
            throw new ArgumentException("Au moins un joueur requis", nameof(players));
        
        // Vérification nombre de joueurs
        var playerCount = players.Count;
        var playerCountScore = playerCount >= boardGame.MinPlayers && 
                               playerCount <= boardGame.MaxPlayers 
                               ? 1.0 
                               : 0.5; // Pénalité si hors range
        
        // Profil moyen du groupe
        var avgAggressivity = players.Average(p => p.Profile.Aggressivity);
        var avgPatience = players.Average(p => p.Profile.Patience);
        var avgAnalysis = players.Average(p => p.Profile.Analysis);
        var avgBluff = players.Average(p => p.Profile.Bluff);
        
        // Distance euclidienne normalisée (0-1)
        var distance = Math.Sqrt(
            Math.Pow(avgAggressivity - boardGame.Profile.Aggressivity, 2) +
            Math.Pow(avgPatience - boardGame.Profile.Patience, 2) +
            Math.Pow(avgAnalysis - boardGame.Profile.Analysis, 2) +
            Math.Pow(avgBluff - boardGame.Profile.Bluff, 2)
        ) / (4 * 4); // Max distance = 4 axes * 4 points
        
        var profileScore = 1.0 - Math.Min(distance, 1.0);
        
        // Score final pondéré : 70% profil, 30% nombre de joueurs
        var finalScore = (profileScore * 0.7 + playerCountScore * 0.3) * 100;
        
        // Scores par axe
        var axisScores = new Dictionary<GameAxis, double>
        {
            [GameAxis.Aggressivity] = CalculateAxisScore(avgAggressivity, boardGame.Profile.Aggressivity),
            [GameAxis.Patience] = CalculateAxisScore(avgPatience, boardGame.Profile.Patience),
            [GameAxis.Analysis] = CalculateAxisScore(avgAnalysis, boardGame.Profile.Analysis),
            [GameAxis.Bluff] = CalculateAxisScore(avgBluff, boardGame.Profile.Bluff)
        };
        
        return new MatchScore
        {
            BoardGame = boardGame,
            Score = Math.Round(finalScore, 1),
            AxisScores = axisScores
        };
    }
    
    private double CalculateAxisScore(double avgPlayerValue, int gameValue)
    {
        var distance = Math.Abs(avgPlayerValue - gameValue);
        return Math.Max(0, 1.0 - (distance / 4.0)) * 100;
    }
    
    public async Task<MatchScore?> FindBestMatchAsync(List<Player> players)
    {
        var games = _context.BoardGames.ToList();
        if (!games.Any()) return null;
        
        var scores = games
            .Select(g => CalculateScore(players, g))
            .OrderByDescending(s => s.Score)
            .FirstOrDefault();
        
        return scores;
    }
    
    public async Task<List<MatchScore>> RankAllGamesAsync(List<Player> players)
    {
        var games = _context.BoardGames.ToList();
        return games
            .Select(g => CalculateScore(players, g))
            .OrderByDescending(s => s.Score)
            .ToList();
    }
}