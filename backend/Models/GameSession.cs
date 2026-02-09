using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProphetProfiler.Api.Models;

public class GameSession
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    public DateTime Date { get; set; } = DateTime.UtcNow;
    public string? Location { get; set; }
    public string? Notes { get; set; }
    
    public SessionStatus Status { get; set; } = SessionStatus.Created;
    
    // Foreign keys
    public Guid BoardGameId { get; set; }
    public BoardGame BoardGame { get; set; } = null!;
    
    // Gagnant(s) - nullable jusqu'à la fin de la session
    public Guid? WinnerId { get; set; }
    public Player? Winner { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? CompletedAt { get; set; }
    
    // Navigation properties
    public ICollection<Player> Participants { get; set; } = new List<Player>();
    public ICollection<Bet> Bets { get; set; } = new List<Bet>();
}

public class Bet
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    public Guid GameSessionId { get; set; }
    public GameSession GameSession { get; set; } = null!;
    
    // Qui parie
    public Guid BettorId { get; set; }
    public Player Bettor { get; set; } = null!;
    
    // Sur qui il parie
    public Guid PredictedWinnerId { get; set; }
    public Player PredictedWinner { get; set; } = null!;
    
    // Type de pari (Winner uniquement pour MVP)
    public BetType Type { get; set; } = BetType.Winner;
    
    // Indique si c'est un auto-pari (pari sur soi-même) - interdit selon les specs MVP
    public bool IsAutoBet { get; set; } = false;
    
    // Résultat
    public bool? IsCorrect { get; set; }
    
    public DateTime PlacedAt { get; set; } = DateTime.UtcNow;
    
    // Points gagnés (calculé à la résolution): +10 correct, -2 incorrect
    public int PointsEarned { get; set; } = 0;
}