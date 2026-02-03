using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProphetProfiler.Api.Models;

public class PlayerStats
{
    // Clé composite : PlayerId + BoardGameId (null = stats globales)
    public Guid PlayerId { get; set; }
    public Player Player { get; set; } = null!;
    
    public Guid? BoardGameId { get; set; }
    public BoardGame? BoardGame { get; set; }
    
    // Stats Champions (victoires)
    public int TotalGamesPlayed { get; set; } = 0;
    public int GamesWon { get; set; } = 0;
    
    [NotMapped]
    public double WinRate => TotalGamesPlayed > 0 
        ? (double)GamesWon / TotalGamesPlayed * 100 
        : 0;
    
    // Stats Oracles (prédictions)
    public int TotalBetsPlaced { get; set; } = 0;
    public int BetsCorrect { get; set; } = 0;
    
    [NotMapped]
    public double PredictionAccuracy => TotalBetsPlaced > 0 
        ? (double)BetsCorrect / TotalBetsPlaced * 100 
        : 0;
    
    public DateTime LastUpdated { get; set; } = DateTime.UtcNow;
    
    // Méthodes helpers
    public void RecordGamePlayed(bool won)
    {
        TotalGamesPlayed++;
        if (won) GamesWon++;
        LastUpdated = DateTime.UtcNow;
    }
    
    public void RecordBet(bool correct, int points = 0)
    {
        TotalBetsPlaced++;
        if (correct) BetsCorrect++;
        // Points gérés séparément
        LastUpdated = DateTime.UtcNow;
    }
}