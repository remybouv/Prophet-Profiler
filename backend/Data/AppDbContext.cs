using Microsoft.EntityFrameworkCore;
using ProphetProfiler.Api.Models;

namespace ProphetProfiler.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
    
    public DbSet<Player> Players { get; set; } = null!;
    public DbSet<PlayerProfile> PlayerProfiles { get; set; } = null!;
    public DbSet<BoardGame> BoardGames { get; set; } = null!;
    public DbSet<GameProfile> GameProfiles { get; set; } = null!;
    public DbSet<GameSession> GameSessions { get; set; } = null!;
    public DbSet<Bet> Bets { get; set; } = null!;
    public DbSet<PlayerStats> PlayerStats { get; set; } = null!;
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // Player - PlayerProfile (1:1)
        modelBuilder.Entity<Player>()
            .HasOne(p => p.Profile)
            .WithOne()
            .HasForeignKey<PlayerProfile>(pp => pp.PlayerId)
            .OnDelete(DeleteBehavior.Cascade);

        // BoardGame - GameProfile (1:1)
        modelBuilder.Entity<BoardGame>()
            .HasOne(bg => bg.Profile)
            .WithOne(gp => gp.BoardGame)
            .HasForeignKey<GameProfile>(gp => gp.BoardGameId);
        
        // GameSession - Participants (N:N)
        modelBuilder.Entity<GameSession>()
            .HasMany(gs => gs.Participants)
            .WithMany(p => p.Sessions)
            .UsingEntity(j => j.ToTable("SessionParticipants"));
        
        // PlayerStats - Clé composite
        modelBuilder.Entity<PlayerStats>()
            .HasKey(ps => new { ps.PlayerId, ps.BoardGameId });
        
        // Bet - Relations explicites vers Player (Bettor et PredictedWinner)
        modelBuilder.Entity<Bet>()
            .HasOne(b => b.Bettor)
            .WithMany()
            .HasForeignKey(b => b.BettorId)
            .OnDelete(DeleteBehavior.Restrict);
        
        modelBuilder.Entity<Bet>()
            .HasOne(b => b.PredictedWinner)
            .WithMany()
            .HasForeignKey(b => b.PredictedWinnerId)
            .OnDelete(DeleteBehavior.Restrict);
        
        // GameSession - Relation Winner vers Player
        modelBuilder.Entity<GameSession>()
            .HasOne(gs => gs.Winner)
            .WithMany()
            .HasForeignKey(gs => gs.WinnerId)
            .OnDelete(DeleteBehavior.SetNull);
        
        // Contraintes sur les axes (1-5)
        modelBuilder.Entity<PlayerProfile>()
            .HasCheckConstraint("CK_PlayerProfile_Aggressivity", "[Aggressivity] BETWEEN 1 AND 5")
            .HasCheckConstraint("CK_PlayerProfile_Patience", "[Patience] BETWEEN 1 AND 5")
            .HasCheckConstraint("CK_PlayerProfile_Analysis", "[Analysis] BETWEEN 1 AND 5")
            .HasCheckConstraint("CK_PlayerProfile_Bluff", "[Bluff] BETWEEN 1 AND 5");
        
        // Index pour performances
        modelBuilder.Entity<Player>()
            .HasIndex(p => p.Name)
            .IsUnique();
        
        modelBuilder.Entity<BoardGame>()
            .HasIndex(bg => bg.Name)
            .IsUnique();
    }
}