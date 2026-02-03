# MODELS.md - Prophet & Profiler

## Structure des Modèles

Avec la séparation Backend/Frontend, on définit :
- **Domain Models** (C#) : Entités EF Core côté API
- **DTOs** (C#) : Contrats de l'API REST
- **Dart Models** : Miroir des DTOs côté Flutter

```
Backend (.NET)                          Frontend (Flutter)
┌──────────────────┐                    ┌──────────────────┐
│   Domain Models  │◄── EF Core ──► DB  │   Dart Models    │
│   (Entities)     │                    │   (JsonSerializable)
└────────┬─────────┘                    └────────┬─────────┘
         │                                       │
         ▼                                       │
┌──────────────────┐                             │
│   DTOs/Contracts │◄────── HTTP/JSON ──────────┘
│   (API Surface)  │
└──────────────────┘
```

---

## Backend : Domain Models (C#)

Entités pures utilisées par Entity Framework Core.

```csharp
// Domain/Models/Player.cs
namespace ProphetProfiler.Domain.Models;

public class Player
{
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required, MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(500)]
    public string? PhotoPath { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Owned entity pour le profil
    public PlayerProfile Profile { get; set; } = new();
    
    // Navigation
    public ICollection<GameSession> Participations { get; set; } = [];
    public ICollection<Bet> BetsPlaced { get; set; } = [];
    public ICollection<Bet> BetsOnMe { get; set; } = [];
}

public class PlayerProfile
{
    [Range(1, 5)]
    public int Agressivity { get; set; } = 3;
    
    [Range(1, 5)]
    public int Patience { get; set; } = 3;
    
    [Range(1, 5)]
    public int Analysis { get; set; } = 3;
    
    [Range(1, 5)]
    public int Bluff { get; set; } = 3;
}

// Domain/Models/BoardGame.cs
public class BoardGame
{
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required, MaxLength(150)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(500)]
    public string? PhotoPath { get; set; }
    
    public GameProfile Profile { get; set; } = new();
    
    [Range(1, 20)]
    public int MinPlayers { get; set; } = 2;
    
    [Range(1, 20)]
    public int MaxPlayers { get; set; } = 4;
    
    public int? EstimatedDuration { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public ICollection<GameSession> Sessions { get; set; } = [];
}

public class GameProfile
{
    [Range(1, 5)]
    public int Agressivity { get; set; } = 3;
    
    [Range(1, 5)]
    public int Patience { get; set; } = 3;
    
    [Range(1, 5)]
    public int Analysis { get; set; } = 3;
    
    [Range(1, 5)]
    public int Bluff { get; set; } = 3;
}

// Domain/Models/GameSession.cs
public class GameSession
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public DateTime Date { get; set; } = DateTime.UtcNow;
    
    public Guid BoardGameId { get; set; }
    public BoardGame BoardGame { get; set; } = null!;
    
    public SessionStatus Status { get; set; } = SessionStatus.Created;
    
    public Guid? WinnerId { get; set; }
    public Player? Winner { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? CompletedAt { get; set; }
    
    public ICollection<Player> Participants { get; set; } = [];
    public ICollection<Bet> Bets { get; set; } = [];
}

public enum SessionStatus
{
    Created = 0,
    Betting = 1,
    Playing = 2,
    Completed = 3,
    Cancelled = 4
}

// Domain/Models/Bet.cs
public class Bet
{
    public Guid Id { get; set; } = Guid.NewGuid();
    
    public Guid GameSessionId { get; set; }
    public GameSession GameSession { get; set; } = null!;
    
    public Guid BettorId { get; set; }
    public Player Bettor { get; set; } = null!;
    
    public Guid PredictedWinnerId { get; set; }
    public Player PredictedWinner { get; set; } = null!;
    
    public DateTime PlacedAt { get; set; } = DateTime.UtcNow;
    public bool? IsCorrect { get; set; }
}

// Domain/Models/PlayerStats.cs
public class PlayerStats
{
    public Guid PlayerId { get; set; }
    public Player Player { get; set; } = null!;
    
    public Guid? BoardGameId { get; set; }
    public BoardGame? BoardGame { get; set; }
    
    public int TotalGamesPlayed { get; set; }
    public int GamesWon { get; set; }
    public int TotalBetsPlaced { get; set; }
    public int BetsWon { get; set; }
    public DateTime LastUpdated { get; set; } = DateTime.UtcNow;
    
    // Calculés
    public double WinRate => TotalGamesPlayed > 0 ? (double)GamesWon / TotalGamesPlayed : 0;
    public double PredictionAccuracy => TotalBetsPlaced > 0 ? (double)BetsWon / TotalBetsPlaced : 0;
}
```

---

## Backend : DTOs / API Contracts

Les DTOs définissent exactement ce qui transite via l'API REST.

```csharp
// Application/DTOs/PlayerDtos.cs
namespace ProphetProfiler.Application.DTOs;

// ===== REQUESTS =====

public record CreatePlayerRequest
{
    [Required, MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    public PlayerProfileDto Profile { get; set; } = new();
}

public record UpdatePlayerRequest
{
    [Required, MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    public PlayerProfileDto Profile { get; set; } = new();
}

// ===== RESPONSES =====

public record PlayerResponse
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? PhotoUrl { get; set; }
    public PlayerProfileDto Profile { get; set; } = new();
    public DateTime CreatedAt { get; set; }
}

public record PlayerProfileDto
{
    [Range(1, 5)]
    [JsonPropertyName("agressivity")]
    public int Agressivity { get; set; } = 3;
    
    [Range(1, 5)]
    [JsonPropertyName("patience")]
    public int Patience { get; set; } = 3;
    
    [Range(1, 5)]
    [JsonPropertyName("analysis")]
    public int Analysis { get; set; } = 3;
    
    [Range(1, 5)]
    [JsonPropertyName("bluff")]
    public int Bluff { get; set; } = 3;
}

// Application/DTOs/BoardGameDtos.cs

public record CreateGameRequest
{
    [Required, MaxLength(150)]
    public string Name { get; set; } = string.Empty;
    
    public GameProfileDto Profile { get; set; } = new();
    
    [Range(1, 20)]
    public int MinPlayers { get; set; } = 2;
    
    [Range(1, 20)]
    public int MaxPlayers { get; set; } = 4;
    
    public int? EstimatedDuration { get; set; }
}

public record BoardGameResponse
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? PhotoUrl { get; set; }
    public GameProfileDto Profile { get; set; } = new();
    public int MinPlayers { get; set; }
    public int MaxPlayers { get; set; }
    public int? EstimatedDuration { get; set; }
}

public record GameProfileDto
{
    [JsonPropertyName("agressivity")]
    public int Agressivity { get; set; } = 3;
    
    [JsonPropertyName("patience")]
    public int Patience { get; set; } = 3;
    
    [JsonPropertyName("analysis")]
    public int Analysis { get; set; } = 3;
    
    [JsonPropertyName("bluff")]
    public int Bluff { get; set; } = 3;
}

// Application/DTOs/SessionDtos.cs

public record CreateSessionRequest
{
    [Required]
    public Guid BoardGameId { get; set; }
    
    [MinLength(2), MaxLength(20)]
    public List<Guid> PlayerIds { get; set; } = [];
}

public record SessionResponse
{
    public Guid Id { get; set; }
    public DateTime Date { get; set; }
    public BoardGameSummaryResponse BoardGame { get; set; } = null!;
    public string Status { get; set; } = string.Empty;
    public PlayerSummaryResponse? Winner { get; set; }
    public List<PlayerSummaryResponse> Participants { get; set; } = [];
    public List<BetResponse> Bets { get; set; } = [];
    public DateTime CreatedAt { get; set; }
}

public record PlayerSummaryResponse
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? PhotoUrl { get; set; }
}

public record BoardGameSummaryResponse
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
}

public record PlaceBetRequest
{
    [Required]
    public Guid PredictedWinnerId { get; set; }
}

public record BetResponse
{
    public Guid Id { get; set; }
    public PlayerSummaryResponse Bettor { get; set; } = null!;
    public PlayerSummaryResponse PredictedWinner { get; set; } = null!;
    public DateTime PlacedAt { get; set; }
    public bool? IsCorrect { get; set; }
}

public record CompleteSessionRequest
{
    [Required]
    public Guid WinnerId { get; set; }
}

// Application/DTOs/MatchDtos.cs

public record MatchRequest
{
    [MinLength(1)]
    public List<Guid> PlayerIds { get; set; } = [];
}

public record MatchScoreResponse
{
    public BoardGameResponse BoardGame { get; set; } = null!;
    public double Score { get; set; }
    public string Quality { get; set; } = string.Empty;  // "perfect", "great", etc.
    public string Recommendation { get; set; } = string.Empty;
    public Dictionary<string, double> AxisScores { get; set; } = [];
    public string? MainConcern { get; set; }
}

// Application/DTOs/RankingDtos.cs

public record RankingEntryResponse
{
    public int Rank { get; set; }
    public PlayerSummaryResponse Player { get; set; } = null!;
    public double Score { get; set; }  // 0.0 - 1.0
    public int TotalGames { get; set; }
}

public record PlayerStatsResponse
{
    public PlayerResponse Player { get; set; } = null!;
    
    // Global
    public int TotalGamesPlayed { get; set; }
    public int GamesWon { get; set; }
    public double WinRate { get; set; }
    public int TotalBetsPlaced { get; set; }
    public int BetsWon { get; set; }
    public double PredictionAccuracy { get; set; }
    
    // Ranks
    public int? ChampionRank { get; set; }
    public int? OracleRank { get; set; }
    
    // Par jeu
    public List<GameSpecificStatsDto> StatsByGame { get; set; } = [];
}

public record GameSpecificStatsDto
{
    public BoardGameSummaryResponse Game { get; set; } = null!;
    public int GamesPlayed { get; set; }
    public int GamesWon { get; set; }
    public double WinRate { get; set; }
    public int BetsPlaced { get; set; }
    public int BetsCorrect { get; set; }
    public double PredictionAccuracy { get; set; }
}
```

---

## Frontend : Dart Models

Miroir des DTOs C# avec `json_serializable` pour la (dé)sérialisation.

```dart
// lib/data/models/player.dart
import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable()
class Player {
  final String id;
  final String name;
  final String? photoUrl;
  final PlayerProfile profile;
  final DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.profile,
    required this.createdAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}

@JsonSerializable()
class PlayerProfile {
  @JsonKey(name: 'agressivity')
  final int agressivity;
  @JsonKey(name: 'patience')
  final int patience;
  @JsonKey(name: 'analysis')
  final int analysis;
  @JsonKey(name: 'bluff')
  final int bluff;

  PlayerProfile({
    this.agressivity = 3,
    this.patience = 3,
    this.analysis = 3,
    this.bluff = 3,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => 
      _$PlayerProfileFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerProfileToJson(this);
}

// lib/data/models/board_game.dart

@JsonSerializable()
class BoardGame {
  final String id;
  final String name;
  final String? photoUrl;
  final GameProfile profile;
  final int minPlayers;
  final int maxPlayers;
  final int? estimatedDuration;

  BoardGame({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.profile,
    this.minPlayers = 2,
    this.maxPlayers = 4,
    this.estimatedDuration,
  });

  factory BoardGame.fromJson(Map<String, dynamic> json) => 
      _$BoardGameFromJson(json);
  Map<String, dynamic> toJson() => _$BoardGameToJson(this);
}

@JsonSerializable()
class GameProfile {
  @JsonKey(name: 'agressivity')
  final int agressivity;
  @JsonKey(name: 'patience')
  final int patience;
  @JsonKey(name: 'analysis')
  final int analysis;
  @JsonKey(name: 'bluff')
  final int bluff;

  GameProfile({
    this.agressivity = 3,
    this.patience = 3,
    this.analysis = 3,
    this.bluff = 3,
  });

  factory GameProfile.fromJson(Map<String, dynamic> json) => 
      _$GameProfileFromJson(json);
  Map<String, dynamic> toJson() => _$GameProfileToJson(this);
}

// lib/data/models/game_session.dart

@JsonSerializable()
class GameSession {
  final String id;
  final DateTime date;
  final BoardGameSummary boardGame;
  final String status;  // "created", "betting", "playing", "completed"
  final PlayerSummary? winner;
  final List<PlayerSummary> participants;
  final List<Bet> bets;
  final DateTime createdAt;

  GameSession({
    required this.id,
    required this.date,
    required this.boardGame,
    required this.status,
    this.winner,
    this.participants = const [],
    this.bets = const [],
    required this.createdAt,
  });

  bool get canPlaceBets => status == 'betting';
  bool get isCompleted => status == 'completed';

  factory GameSession.fromJson(Map<String, dynamic> json) => 
      _$GameSessionFromJson(json);
  Map<String, dynamic> toJson() => _$GameSessionToJson(this);
}

@JsonSerializable()
class PlayerSummary {
  final String id;
  final String name;
  final String? photoUrl;

  PlayerSummary({
    required this.id,
    required this.name,
    this.photoUrl,
  });

  factory PlayerSummary.fromJson(Map<String, dynamic> json) => 
      _$PlayerSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerSummaryToJson(this);
}

@JsonSerializable()
class BoardGameSummary {
  final String id;
  final String name;

  BoardGameSummary({required this.id, required this.name});

  factory BoardGameSummary.fromJson(Map<String, dynamic> json) => 
      _$BoardGameSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$BoardGameSummaryToJson(this);
}

// lib/data/models/bet.dart

@JsonSerializable()
class Bet {
  final String id;
  final PlayerSummary bettor;
  final PlayerSummary predictedWinner;
  final DateTime placedAt;
  final bool? isCorrect;

  Bet({
    required this.id,
    required this.bettor,
    required this.predictedWinner,
    required this.placedAt,
    this.isCorrect,
  });

  factory Bet.fromJson(Map<String, dynamic> json) => _$BetFromJson(json);
  Map<String, dynamic> toJson() => _$BetToJson(this);
}

// lib/data/models/match_score.dart

@JsonSerializable()
class MatchScore {
  final BoardGame boardGame;
  final double score;
  final String quality;  // "avoid", "poor", "average", "good", "great", "perfect"
  final String recommendation;
  final Map<String, double> axisScores;
  final String? mainConcern;

  MatchScore({
    required this.boardGame,
    required this.score,
    required this.quality,
    required this.recommendation,
    required this.axisScores,
    this.mainConcern,
  });

  factory MatchScore.fromJson(Map<String, dynamic> json) => 
      _$MatchScoreFromJson(json);
  Map<String, dynamic> toJson() => _$MatchScoreToJson(this);
}

// lib/data/models/ranking.dart

@JsonSerializable()
class RankingEntry {
  final int rank;
  final PlayerSummary player;
  final double score;
  final int totalGames;

  RankingEntry({
    required this.rank,
    required this.player,
    required this.score,
    required this.totalGames,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) => 
      _$RankingEntryFromJson(json);
  Map<String, dynamic> toJson() => _$RankingEntryToJson(this);
}

@JsonSerializable()
class PlayerStats {
  final Player player;
  final int totalGamesPlayed;
  final int gamesWon;
  final double winRate;
  final int totalBetsPlaced;
  final int betsWon;
  final double predictionAccuracy;
  final int? championRank;
  final int? oracleRank;
  final List<GameSpecificStats> statsByGame;

  PlayerStats({
    required this.player,
    this.totalGamesPlayed = 0,
    this.gamesWon = 0,
    this.winRate = 0,
    this.totalBetsPlaced = 0,
    this.betsWon = 0,
    this.predictionAccuracy = 0,
    this.championRank,
    this.oracleRank,
    this.statsByGame = const [],
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) => 
      _$PlayerStatsFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerStatsToJson(this);
}

@JsonSerializable()
class GameSpecificStats {
  final BoardGameSummary game;
  final int gamesPlayed;
  final int gamesWon;
  final double winRate;
  final int betsPlaced;
  final int betsCorrect;
  final double predictionAccuracy;

  GameSpecificStats({
    required this.game,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.winRate = 0,
    this.betsPlaced = 0,
    this.betsCorrect = 0,
    this.predictionAccuracy = 0,
  });

  factory GameSpecificStats.fromJson(Map<String, dynamic> json) => 
      _$GameSpecificStatsFromJson(json);
  Map<String, dynamic> toJson() => _$GameSpecificStatsToJson(this);
}
```

---

## Mapping Backend (C#)

```csharp
// Application/Mappings/MappingProfile.cs (AutoMapper ou manuel)

public static class PlayerMapper
{
    public static PlayerResponse ToResponse(this Player player) => new()
    {
        Id = player.Id,
        Name = player.Name,
        PhotoUrl = player.PhotoPath != null ? $"/uploads/{player.PhotoPath}" : null,
        Profile = new PlayerProfileDto
        {
            Agressivity = player.Profile.Agressivity,
            Patience = player.Profile.Patience,
            Analysis = player.Profile.Analysis,
            Bluff = player.Profile.Bluff
        },
        CreatedAt = player.CreatedAt
    };
    
    public static Player ToEntity(this CreatePlayerRequest request) => new()
    {
        Name = request.Name,
        Profile = new PlayerProfile
        {
            Agressivity = request.Profile.Agressivity,
            Patience = request.Profile.Patience,
            Analysis = request.Profile.Analysis,
            Bluff = request.Profile.Bluff
        }
    };
}
```

---

## Génération Code

### Backend (C#) - Aucune dépendance requise
Les DTOs utilisent des `record` ou classes avec attributs `[JsonPropertyName]`.

### Frontend (Flutter)

```yaml
# pubspec.yaml
dependencies:
  json_annotation: ^4.8.1
  dio: ^5.4.0

dev_dependencies:
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
```

```bash
# Générer les .g.dart
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Validation

### Backend (FluentValidation)

```csharp
public class CreatePlayerRequestValidator : AbstractValidator<CreatePlayerRequest>
{
    public CreatePlayerRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Profile.Agressivity).InclusiveBetween(1, 5);
        RuleFor(x => x.Profile.Patience).InclusiveBetween(1, 5);
        RuleFor(x => x.Profile.Analysis).InclusiveBetween(1, 5);
        RuleFor(x => x.Profile.Bluff).InclusiveBetween(1, 5);
    }
}
```

### Frontend (Dart)

```dart
// Validation avant envoi API
class PlayerValidator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Nom requis';
    if (value.length > 100) return 'Nom trop long';
    return null;
  }
  
  static String? validateAxis(int value) {
    if (value < 1 || value > 5) return 'Note entre 1 et 5';
    return null;
  }
}
```
