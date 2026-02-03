using System.ComponentModel.DataAnnotations;

namespace ProphetProfiler.Api.Models;

public class BoardGame
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    [StringLength(100)]
    public string Name { get; set; } = string.Empty;
    
    public string? Description { get; set; }
    public string? PhotoUrl { get; set; }
    
    // Nombre de joueurs
    public int MinPlayers { get; set; } = 2;
    public int MaxPlayers { get; set; } = 4;
    
    // Durée moyenne en minutes
    public int? AverageDuration { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    public GameProfile Profile { get; set; } = null!;
    public ICollection<GameSession> Sessions { get; set; } = new List<GameSession>();
}

public class GameProfile
{
    public Guid BoardGameId { get; set; }
    public BoardGame BoardGame { get; set; } = null!;
    
    // 4 axes requis par le jeu (1-5)
    public int Aggressivity { get; set; } // 1-5
    public int Patience { get; set; }     // 1-5
    public int Analysis { get; set; }     // 1-5
    public int Bluff { get; set; }        // 1-5
}