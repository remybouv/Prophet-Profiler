using System.ComponentModel.DataAnnotations;

namespace ProphetProfiler.Api.Models;

public class Player
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    [StringLength(50)]
    public string Name { get; set; } = string.Empty;
    
    public string? PhotoUrl { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
    
    // Navigation properties
    public PlayerProfile Profile { get; set; } = null!;
    public ICollection<GameSession> Sessions { get; set; } = new List<GameSession>();
    public ICollection<Bet> Bets { get; set; } = new List<Bet>();
    public ICollection<PlayerStats> Stats { get; set; } = new List<PlayerStats>();
}

public class PlayerProfile
{
    [Key]
    public Guid PlayerId { get; set; }
    public Player Player { get; set; } = null!;
    
    // 4 axes de notation (1-5)
    public int Aggressivity { get; set; } = 3;  // 1-5
    public int Patience { get; set; } = 3;      // 1-5
    public int Analysis { get; set; } = 3;      // 1-5
    public int Bluff { get; set; } = 3;         // 1-5
}