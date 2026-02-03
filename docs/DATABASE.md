# DATABASE.md - Prophet & Profiler

## Vue d'ensemble

- **SGBD** : SQLite (fichier local au backend)
- **ORM** : Entity Framework Core 8
- **Pattern** : Code-First avec Migrations
- **Fichier** : `prophet.db` dans le répertoire de l'API

La base de données est gérée **exclusivement par le backend .NET API**. Le frontend Flutter communique via l'API REST, jamais directement avec la DB.

```
Flutter App        HTTP/JSON        .NET API         EF Core        SQLite
    │───────────────────────────────►│               │               │
    │                                │──────────────►│               │
    │                                │               │──────────────►│
    │                                │               │◄──────────────│
    │                                │◄──────────────│               │
    │◄───────────────────────────────│               │               │
```

---

## Schéma Entité-Relation

```
┌──────────────────────────────────────────────────────────────────────────┐
│                              PLAYERS                                     │
├──────────────────────────────────────────────────────────────────────────┤
│ PK  Id              : TEXT (GUID)                                        │
│     Name            : TEXT NOT NULL                                      │
│     PhotoPath       : TEXT NULL                                          │
│     Profile_Agressivity : INTEGER DEFAULT 3 CHECK(1-5)                   │
│     Profile_Patience    : INTEGER DEFAULT 3 CHECK(1-5)                   │
│     Profile_Analysis    : INTEGER DEFAULT 3 CHECK(1-5)                   │
│     Profile_Bluff       : INTEGER DEFAULT 3 CHECK(1-5)                   │
│     CreatedAt       : TEXT (ISO8601)                                     │
└──────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ 1
                                    │
                                    ▼ N
┌──────────────────────────────────────────────────────────────────────────┐
│                         SESSION_PARTICIPANTS                             │
├──────────────────────────────────────────────────────────────────────────┤
│ FK  GameSessionId   : TEXT → GAME_SESSIONS.Id                            │
│ FK  PlayerId        : TEXT → PLAYERS.Id                                  │
│ PK  (GameSessionId, PlayerId)                                            │
└──────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ N
                                    │
                                    ▼ 1
┌──────────────────────────────────────────────────────────────────────────┐
│                           GAME_SESSIONS                                  │
├──────────────────────────────────────────────────────────────────────────┤
│ PK  Id              : TEXT                                               │
│     Date            : TEXT                                               │
│ FK  BoardGameId     : TEXT → BOARD_GAMES.Id                              │
│     Status          : INTEGER (0=Created, 1=Betting, 2=Playing,          │
│                              3=Completed, 4=Cancelled)                   │
│ FK  WinnerId        : TEXT NULL → PLAYERS.Id                             │
│     CreatedAt       : TEXT                                               │
│     CompletedAt     : TEXT NULL                                          │
└──────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ 1
                                    │
                                    ▼ N
┌──────────────────────────────────────────────────────────────────────────┐
│                               BETS                                       │
├──────────────────────────────────────────────────────────────────────────┤
│ PK  Id              : TEXT                                               │
│ FK  GameSessionId   : TEXT                                               │
│ FK  BettorId        : TEXT                                               │
│ FK  PredictedWinnerId : TEXT                                             │
│     PlacedAt        : TEXT                                               │
│     IsCorrect       : INTEGER NULL (0=false, 1=true, NULL=unresolved)    │
└──────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                           BOARD_GAMES                                    │
├──────────────────────────────────────────────────────────────────────────┤
│ PK  Id              : TEXT                                               │
│     Name            : TEXT NOT NULL                                      │
│     PhotoPath       : TEXT NULL                                          │
│     Profile_Agressivity : INTEGER DEFAULT 3                              │
│     Profile_Patience    : INTEGER DEFAULT 3                              │
│     Profile_Analysis    : INTEGER DEFAULT 3                              │
│     Profile_Bluff       : INTEGER DEFAULT 3                              │
│     MinPlayers      : INTEGER DEFAULT 2                                  │
│     MaxPlayers      : INTEGER DEFAULT 4                                  │
│     EstimatedDuration : INTEGER NULL                                     │
│     CreatedAt       : TEXT                                               │
└──────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                           PLAYER_STATS                                   │
├──────────────────────────────────────────────────────────────────────────┤
│ PK  PlayerId        : TEXT → PLAYERS.Id                                  │
│ PK  BoardGameId     : TEXT NULL → BOARD_GAMES.Id (NULL = stats globaux)  │
│     TotalGamesPlayed : INTEGER DEFAULT 0                                 │
│     GamesWon        : INTEGER DEFAULT 0                                  │
│     TotalBetsPlaced : INTEGER DEFAULT 0                                  │
│     BetsWon         : INTEGER DEFAULT 0                                  │
│     LastUpdated     : TEXT                                               │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Configuration EF Core

### DbContext

```csharp
// Infrastructure/Data/AppDbContext.cs

using Microsoft.EntityFrameworkCore;
using ProphetProfiler.Domain.Models;

namespace ProphetProfiler.Infrastructure.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Player> Players => Set<Player>();
    public DbSet<BoardGame> BoardGames => Set<BoardGame>();
    public DbSet<GameSession> GameSessions => Set<GameSession>();
    public DbSet<Bet> Bets => Set<Bet>();
    public DbSet<PlayerStats> PlayerStats => Set<PlayerStats>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        ConfigurePlayers(modelBuilder);
        ConfigureBoardGames(modelBuilder);
        ConfigureGameSessions(modelBuilder);
        ConfigureBets(modelBuilder);
        ConfigurePlayerStats(modelBuilder);
    }

    private void ConfigurePlayers(ModelBuilder mb)
    {
        mb.Entity<Player>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.Property(e => e.PhotoPath).HasMaxLength(500);
            entity.HasIndex(e => e.Name);
            
            // Owned entity Profile
            entity.OwnsOne(e => e.Profile, profile =>
            {
                profile.Property(p => p.Agressivity).HasColumnName("Profile_Agressivity");
                profile.Property(p => p.Patience).HasColumnName("Profile_Patience");
                profile.Property(p => p.Analysis).HasColumnName("Profile_Analysis");
                profile.Property(p => p.Bluff).HasColumnName("Profile_Bluff");
            });
        });
    }

    private void ConfigureBoardGames(ModelBuilder mb)
    {
        mb.Entity<BoardGame>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(150);
            entity.HasIndex(e => e.Name);
            
            entity.OwnsOne(e => e.Profile, profile =>
            {
                profile.Property(p => p.Agressivity).HasColumnName("Profile_Agressivity");
                profile.Property(p => p.Patience).HasColumnName("Profile_Patience");
                profile.Property(p => p.Analysis).HasColumnName("Profile_Analysis");
                profile.Property(p => p.Bluff).HasColumnName("Profile_Bluff");
            });
        });
    }

    private void ConfigureGameSessions(ModelBuilder mb)
    {
        mb.Entity<GameSession>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.HasOne(e => e.BoardGame)
                  .WithMany(g => g.Sessions)
                  .HasForeignKey(e => e.BoardGameId)
                  .OnDelete(DeleteBehavior.Cascade);
            
            entity.HasOne(e => e.Winner)
                  .WithMany()
                  .HasForeignKey(e => e.WinnerId)
                  .OnDelete(DeleteBehavior.SetNull);
            
            // Relation many-to-many Participants
            entity.HasMany(e => e.Participants)
                  .WithMany(p => p.Participations)
                  .UsingEntity<Dictionary<string, object>>(
                      "SessionParticipants",
                      j => j.HasOne<Player>().WithMany().HasForeignKey("PlayerId"),
                      j => j.HasOne<GameSession>().WithMany().HasForeignKey("GameSessionId"));
            
            entity.HasIndex(e => e.Date);
            entity.HasIndex(e => e.Status);
        });
    }

    private void ConfigureBets(ModelBuilder mb)
    {
        mb.Entity<Bet>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.HasOne(e => e.GameSession)
                  .WithMany(s => s.Bets)
                  .HasForeignKey(e => e.GameSessionId)
                  .OnDelete(DeleteBehavior.Cascade);
            
            entity.HasOne(e => e.Bettor)
                  .WithMany(p => p.BetsPlaced)
                  .HasForeignKey(e => e.BettorId)
                  .OnDelete(DeleteBehavior.Cascade);
            
            entity.HasOne(e => e.PredictedWinner)
                  .WithMany(p => p.BetsOnMe)
                  .HasForeignKey(e => e.PredictedWinnerId)
                  .OnDelete(DeleteBehavior.Cascade);
            
            // Contrainte: un seul pari par joueur par session
            entity.HasIndex(e => new { e.GameSessionId, e.BettorId }).IsUnique();
        });
    }

    private void ConfigurePlayerStats(ModelBuilder mb)
    {
        mb.Entity<PlayerStats>(entity =>
        {
            // Clé composite
            entity.HasKey(e => new { e.PlayerId, e.BoardGameId });
            
            entity.HasOne(e => e.Player)
                  .WithMany()
                  .HasForeignKey(e => e.PlayerId)
                  .OnDelete(DeleteBehavior.Cascade);
            
            entity.HasOne(e => e.BoardGame)
                  .WithMany()
                  .HasForeignKey(e => e.BoardGameId)
                  .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
```

---

## Configuration API (Program.cs)

```csharp
// Program.cs
using Microsoft.EntityFrameworkCore;
using ProphetProfiler.Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);

// Chemin de la base SQLite
var dbPath = Path.Combine(
    builder.Environment.ContentRootPath, 
    "prophet.db");

builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseSqlite($"Data Source={dbPath}");
    
#if DEBUG
    options.EnableSensitiveDataLogging();
    options.EnableDetailedErrors();
#endif
});

// Migrations auto en dev
if (builder.Environment.IsDevelopment())
{
    using var scope = builder.Services.BuildServiceProvider().CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.Migrate();
}
```

---

## Migrations Entity Framework

### Workflow

```bash
# 1. Créer une migration après modification des models
dotnet ef migrations add NomMigration \
    --project src/ProphetProfiler.Infrastructure \
    --startup-project src/ProphetProfiler.Api

# 2. Appliquer les migrations
dotnet ef database update \
    --project src/ProphetProfiler.Infrastructure \
    --startup-project src/ProphetProfiler.Api

# 3. Générer script SQL
dotnet ef migrations script \
    --project src/ProphetProfiler.Infrastructure \
    --startup-project src/ProphetProfiler.Api \
    --output scripts/migration.sql
```

### Migration Initiale (exemple)

```csharp
// Migrations/20240203000000_InitialCreate.cs

public partial class InitialCreate : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "BoardGames",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "TEXT", nullable: false),
                Name = table.Column<string>(type: "TEXT", maxLength: 150, nullable: false),
                PhotoPath = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true),
                Profile_Agressivity = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 3),
                Profile_Patience = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 3),
                Profile_Analysis = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 3),
                Profile_Bluff = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 3),
                MinPlayers = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 2),
                MaxPlayers = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 4),
                EstimatedDuration = table.Column<int>(type: "INTEGER", nullable: true),
                CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_BoardGames", x => x.Id);
            });

        migrationBuilder.CreateTable(
            name: "Players",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "TEXT", nullable: false),
                Name = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                PhotoPath = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true),
                Profile_Agressivity = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 3),
                Profile_Patience = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 3),
                Profile_Analysis = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 3),
                Profile_Bluff = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 3),
                CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Players", x => x.Id);
            });

        // ... autres tables (GameSessions, Bets, PlayerStats, SessionParticipants)

        migrationBuilder.CreateIndex(
            name: "IX_Players_Name",
            table: "Players",
            column: "Name");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(name: "SessionParticipants");
        migrationBuilder.DropTable(name: "Bets");
        migrationBuilder.DropTable(name: "PlayerStats");
        migrationBuilder.DropTable(name: "GameSessions");
        migrationBuilder.DropTable(name: "BoardGames");
        migrationBuilder.DropTable(name: "Players");
    }
}
```

---

## Repository Pattern (simplifié)

Avec EF Core et une API REST, on peut utiliser le DbContext directement dans les services ou créer des repositories légers :

```csharp
// Domain/Interfaces/IPlayerRepository.cs
public interface IPlayerRepository
{
    Task<Player?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task<IReadOnlyList<Player>> GetAllAsync(CancellationToken ct = default);
    Task<Player> AddAsync(Player player, CancellationToken ct = default);
    Task UpdateAsync(Player player, CancellationToken ct = default);
    Task DeleteAsync(Guid id, CancellationToken ct = default);
    Task<bool> ExistsAsync(Guid id, CancellationToken ct = default);
}

// Infrastructure/Repositories/PlayerRepository.cs
public class PlayerRepository : IPlayerRepository
{
    private readonly AppDbContext _context;
    
    public PlayerRepository(AppDbContext context) => _context = context;
    
    public async Task<Player?> GetByIdAsync(Guid id, CancellationToken ct = default)
    {
        return await _context.Players
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.Id == id, ct);
    }
    
    public async Task<IReadOnlyList<Player>> GetAllAsync(CancellationToken ct = default)
    {
        return await _context.Players
            .AsNoTracking()
            .OrderBy(p => p.Name)
            .ToListAsync(ct);
    }
    
    public async Task<Player> AddAsync(Player player, CancellationToken ct = default)
    {
        _context.Players.Add(player);
        await _context.SaveChangesAsync(ct);
        return player;
    }
    
    public async Task UpdateAsync(Player player, CancellationToken ct = default)
    {
        _context.Players.Update(player);
        await _context.SaveChangesAsync(ct);
    }
    
    public async Task DeleteAsync(Guid id, CancellationToken ct = default)
    {
        var player = await _context.Players.FindAsync(new object[] { id }, ct);
        if (player != null)
        {
            _context.Players.Remove(player);
            await _context.SaveChangesAsync(ct);
        }
    }
    
    public async Task<bool> ExistsAsync(Guid id, CancellationToken ct = default)
    {
        return await _context.Players.AnyAsync(p => p.Id == id, ct);
    }
}
```

---

## Requêtes Fréquentes

### Classement Champions (API)

```csharp
// Dans RankingService
public async Task<IReadOnlyList<RankingEntry>> GetChampionsGlobalAsync(int top = 10)
{
    return await _context.PlayerStats
        .AsNoTracking()
        .Where(s => s.BoardGameId == null)  // Stats globaux
        .Where(s => s.TotalGamesPlayed >= 3)  // Min 3 parties
        .OrderByDescending(s => (double)s.GamesWon / s.TotalGamesPlayed)
        .Take(top)
        .Select(s => new RankingEntry
        {
            PlayerId = s.PlayerId,
            PlayerName = s.Player.Name,
            Score = (double)s.GamesWon / s.TotalGamesPlayed,
            TotalGames = s.TotalGamesPlayed
        })
        .ToListAsync();
}
```

### Session avec détails (API)

```csharp
// Dans SessionService
public async Task<GameSession?> GetSessionWithDetailsAsync(Guid id, CancellationToken ct)
{
    return await _context.GameSessions
        .AsNoTracking()
        .Include(s => s.BoardGame)
        .Include(s => s.Participants)
        .Include(s => s.Bets)
            .ThenInclude(b => b.Bettor)
        .Include(s => s.Bets)
            .ThenInclude(b => b.PredictedWinner)
        .Include(s => s.Winner)
        .FirstOrDefaultAsync(s => s.Id == id, ct);
}
```

---

## Backup & Maintenance

```csharp
// API Controller pour backup
[ApiController]
[Route("api/[controller]")]
public class AdminController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly string _dbPath;
    
    [HttpPost("backup")]
    public IActionResult CreateBackup()
    {
        var backupName = $"backup_{DateTime.Now:yyyyMMdd_HHmmss}.db";
        var backupPath = Path.Combine("backups", backupName);
        Directory.CreateDirectory("backups");
        System.IO.File.Copy(_dbPath, backupPath);
        return Ok(new { backupPath });
    }
    
    [HttpPost("recalculate-stats")]
    public async Task<IActionResult> RecalculateStats()
    {
        // Recalcule toutes les stats depuis l'historique
        var sessions = await _context.GameSessions
            .Where(s => s.Status == SessionStatus.Completed)
            .Include(s => s.Participants)
            .Include(s => s.Bets)
            .ToListAsync();
            
        // ... logique de recalcule
        
        return Ok(new { message = "Stats recalculées" });
    }
}
```
