# SERVICES.md - Prophet & Profiler

## Vue d'ensemble

Les services sont répartis entre **Backend (.NET API)** et **Frontend (Flutter)** :

| Couche | Responsabilité | Tech |
|--------|----------------|------|
| **Backend Services** | Logique métier, calculs, persistence | C# / .NET |
| **Backend Controllers** | Exposition REST, validation, mapping | ASP.NET Core |
| **Frontend Services** | Appels API, cache local, mapping | Dart / Dio |
| **Frontend BLOCs** | State management UI | Dart / flutter_bloc |

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              BACKEND (.NET)                                  │
│                                                                              │
│  Controllers          Services              Repositories         EF Core    │
│  ┌─────────┐         ┌─────────────┐       ┌─────────────┐     ┌─────────┐  │
│  │ Players │◄───────►│             │◄─────►│             │◄────┤         │  │
│  │   API   │  DTOs   │  IPlayer    │       │ IPlayerRepo │     │ SQLite  │  │
│  └─────────┘         │  Service    │       │             │     │         │  │
│                      │             │       └─────────────┘     └─────────┘  │
│  ┌─────────┐         └─────────────┘                                        │
│  │  Match  │◄───────►┌─────────────┐                                         │
│  │   API   │  DTOs   │ IMatchScore │                                         │
│  └─────────┘         │ Calculator  │                                         │
│                      └─────────────┘                                         │
│  ┌─────────┐         ┌─────────────┐                                         │
│  │ Sessions│◄───────►│  IBetManager│                                         │
│  │   API   │         │             │                                         │
│  └─────────┘         └─────────────┘                                         │
└─────────────────────────────────────────────────────────────────────────────┘
                                       ▲
                                       │ HTTP/REST
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                             FRONTEND (FLUTTER)                               │
│                                                                              │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────────┐               │
│  │   UI    │◄──►│  BLOC   │◄──►│  Repo   │◄──►│ ApiService  │               │
│  │ Widgets │    │ (State) │    │  (Data) │    │  (Dio)      │               │
│  └─────────┘    └─────────┘    └─────────┘    └─────────────┘               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Backend : Interfaces de Services

### 1. IMatchScoreCalculator

```csharp
// Domain/Interfaces/Services/IMatchScoreCalculator.cs
namespace ProphetProfiler.Domain.Interfaces.Services;

public interface IMatchScoreCalculator
{
    /// <summary>
    /// Calcule le score de compatibilité entre joueurs et un jeu
    /// </summary>
    MatchScore CalculateScore(IReadOnlyList<Player> players, BoardGame boardGame);
    
    /// <summary>
    /// Trouve le meilleur jeu pour le groupe
    /// </summary>
    Task<MatchScore?> FindBestMatchAsync(
        IReadOnlyList<Guid> playerIds, 
        CancellationToken ct = default);
    
    /// <summary>
    /// Classe tous les jeux par compatibilité
    /// </summary>
    Task<IReadOnlyList<MatchScore>> RankAllGamesAsync(
        IReadOnlyList<Guid> playerIds,
        CancellationToken ct = default);
}

/// <summary>
/// Résultat d'un calcul de matching
/// </summary>
public class MatchScore
{
    public required BoardGame BoardGame { get; init; }
    public required double Score { get; init; }  // 0-100
    public required Dictionary<GameAxis, double> AxisScores { get; init; }
    public string? MainConcern { get; init; }
    
    public MatchQuality Quality => Score switch
    {
        >= 90 => MatchQuality.Perfect,
        >= 75 => MatchQuality.Great,
        >= 60 => MatchQuality.Good,
        >= 40 => MatchQuality.Average,
        >= 25 => MatchQuality.Poor,
        _ => MatchQuality.Avoid
    };
    
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

public enum MatchQuality { Avoid, Poor, Average, Good, Great, Perfect }
```

### 2. IBetManager

```csharp
// Domain/Interfaces/Services/IBetManager.cs
namespace ProphetProfiler.Domain.Interfaces.Services;

public interface IBetManager
{
    /// <summary>
    /// Place un pari après validation
    /// </summary>
    Task<Bet> PlaceBetAsync(
        Guid sessionId, 
        Guid bettorId, 
        Guid predictedWinnerId,
        CancellationToken ct = default);
    
    /// <summary>
    /// Valide si un pari est possible (sans le placer)
    /// </summary>
    Task<BetValidationResult> ValidateBetAsync(
        Guid sessionId,
        Guid bettorId,
        Guid predictedWinnerId,
        CancellationToken ct = default);
    
    /// <summary>
    /// Résout tous les paris d'une session à la fin
    /// </summary>
    Task<IReadOnlyList<BetResult>> ResolveBetsAsync(
        Guid sessionId,
        Guid actualWinnerId,
        CancellationToken ct = default);
    
    /// <summary>
    /// Liste des joueurs qui n'ont pas encore parié
    /// </summary>
    Task<IReadOnlyList<Player>> GetPendingBettorsAsync(
        Guid sessionId,
        CancellationToken ct = default);
    
    /// <summary>
    /// Tous les participants ont-ils parié?
    /// </summary>
    Task<bool> AllPlayersHaveBetAsync(Guid sessionId, CancellationToken ct = default);
}

public record BetValidationResult
{
    public bool IsValid { get; init; }
    public string ErrorCode { get; init; } = "OK";
    public string? ErrorMessage { get; init; }
    
    public static BetValidationResult Success() => new() { IsValid = true, ErrorCode = "OK" };
    public static BetValidationResult Fail(string code, string message) => 
        new() { IsValid = false, ErrorCode = code, ErrorMessage = message };
}

public record BetResult
{
    public Guid BetId { get; init; }
    public string BettorName { get; init; } = string.Empty;
    public string PredictedWinnerName { get; init; } = string.Empty;
    public bool IsCorrect { get; init; }
}

public static class BetErrorCodes
{
    public const string SessionNotFound = "SESSION_NOT_FOUND";
    public const string SessionNotInBettingPhase = "SESSION_NOT_BETTING";
    public const string BettorNotParticipant = "BETTOR_NOT_PARTICIPANT";
    public const string PredictedNotParticipant = "PREDICTED_NOT_PARTICIPANT";
    public const string AlreadyBet = "ALREADY_BET";
    public const string SelfBetNotAllowed = "SELF_BET_NOT_ALLOWED";
}
```

### 3. IRankingService

```csharp
// Domain/Interfaces/Services/IRankingService.cs
namespace ProphetProfiler.Domain.Interfaces.Services;

public interface IRankingService
{
    // Champions (victoires)
    Task<IReadOnlyList<RankingEntry>> GetChampionsGlobalAsync(int top = 10, CancellationToken ct = default);
    Task<IReadOnlyList<RankingEntry>> GetChampionsByGameAsync(Guid boardGameId, int top = 10, CancellationToken ct = default);
    Task<int> GetPlayerChampionRankAsync(Guid playerId, CancellationToken ct = default);
    
    // Oracles (prédictions)
    Task<IReadOnlyList<RankingEntry>> GetOraclesGlobalAsync(int top = 10, CancellationToken ct = default);
    Task<IReadOnlyList<RankingEntry>> GetOraclesByGameAsync(Guid boardGameId, int top = 10, CancellationToken ct = default);
    Task<int> GetPlayerOracleRankAsync(Guid playerId, CancellationToken ct = default);
    
    // Stats détaillées
    Task<PlayerStatsSummary> GetPlayerStatsAsync(Guid playerId, CancellationToken ct = default);
    Task UpdateStatsAfterSessionAsync(Guid sessionId, CancellationToken ct = default);
}

public class RankingEntry
{
    public int Rank { get; set; }
    public Player Player { get; set; } = null!;
    public double Score { get; set; }  // WinRate ou PredictionAccuracy
    public int TotalGames { get; set; }
}

public class PlayerStatsSummary
{
    public Player Player { get; set; } = null!;
    public int TotalGamesPlayed { get; set; }
    public int GamesWon { get; set; }
    public double WinRate { get; set; }
    public int TotalBetsPlaced { get; set; }
    public int BetsWon { get; set; }
    public double PredictionAccuracy { get; set; }
    public int? ChampionRank { get; set; }
    public int? OracleRank { get; set; }
    public List<GameSpecificStats> StatsByGame { get; set; } = [];
}

public class GameSpecificStats
{
    public BoardGame Game { get; set; } = null!;
    public int GamesPlayed { get; set; }
    public int GamesWon { get; set; }
    public double WinRate { get; set; }
    public int BetsPlaced { get; set; }
    public int BetsCorrect { get; set; }
    public double PredictionAccuracy { get; set; }
}
```

---

## Backend : Implémentations

### MatchScoreCalculator

```csharp
// Application/Services/MatchScoreCalculator.cs
namespace ProphetProfiler.Application.Services;

public class MatchScoreCalculator : IMatchScoreCalculator
{
    private readonly AppDbContext _context;
    
    public MatchScoreCalculator(AppDbContext context)
    {
        _context = context;
    }
    
    public MatchScore CalculateScore(IReadOnlyList<Player> players, BoardGame game)
    {
        if (players.Count == 0)
            throw new ArgumentException("Au moins un joueur requis", nameof(players));
        
        // Score nombre de joueurs
        var playerCountOk = players.Count >= game.MinPlayers && players.Count <= game.MaxPlayers;
        var playerCountScore = playerCountOk ? 1.0 : 0.0;
        
        // Profil moyen du groupe
        var avgProfile = new PlayerProfile
        {
            Agressivity = (int)Math.Round(players.Average(p => p.Profile.Agressivity)),
            Patience = (int)Math.Round(players.Average(p => p.Profile.Patience)),
            Analysis = (int)Math.Round(players.Average(p => p.Profile.Analysis)),
            Bluff = (int)Math.Round(players.Average(p => p.Profile.Bluff))
        };
        
        // Distance euclidienne
        var distance = Math.Sqrt(
            Math.Pow(avgProfile.Agressivity - game.Profile.Agressivity, 2) +
            Math.Pow(avgProfile.Patience - game.Profile.Patience, 2) +
            Math.Pow(avgProfile.Analysis - game.Profile.Analysis, 2) +
            Math.Pow(avgProfile.Bluff - game.Profile.Bluff, 2));
        
        var maxDistance = Math.Sqrt(4 * 16); // 4 axes × (5-1)²
        var profileScore = 1.0 - (distance / maxDistance);
        
        // Détails par axe
        var axisScores = new Dictionary<GameAxis, double>
        {
            [GameAxis.Agressivity] = CalculateAxisScore(players, p => p.Profile.Agressivity, game.Profile.Agressivity),
            [GameAxis.Patience] = CalculateAxisScore(players, p => p.Profile.Patience, game.Profile.Patience),
            [GameAxis.Analysis] = CalculateAxisScore(players, p => p.Profile.Analysis, game.Profile.Analysis),
            [GameAxis.Bluff] = CalculateAxisScore(players, p => p.Profile.Bluff, game.Profile.Bluff)
        };
        
        // Score final
        var finalScore = (profileScore * 0.7 + playerCountScore * 0.3) * 100;
        var weakestAxis = axisScores.OrderBy(a => a.Value).First();
        
        return new MatchScore
        {
            BoardGame = game,
            Score = Math.Round(finalScore, 1),
            AxisScores = axisScores,
            MainConcern = weakestAxis.Value < 0.5 ? $"{weakestAxis.Key} peu adapté" : null
        };
    }
    
    private double CalculateAxisScore(IReadOnlyList<Player> players, Func<Player, int> selector, int gameValue)
    {
        var avg = players.Average(selector);
        var distance = Math.Abs(avg - gameValue);
        return Math.Max(0, 1.0 - (distance / 4.0));
    }
    
    public async Task<MatchScore?> FindBestMatchAsync(IReadOnlyList<Guid> playerIds, CancellationToken ct = default)
    {
        var players = await _context.Players
            .Where(p => playerIds.Contains(p.Id))
            .ToListAsync(ct);
            
        var games = await _context.BoardGames.ToListAsync(ct);
        
        return games
            .Select(g => CalculateScore(players, g))
            .OrderByDescending(m => m.Score)
            .FirstOrDefault();
    }
    
    public async Task<IReadOnlyList<MatchScore>> RankAllGamesAsync(
        IReadOnlyList<Guid> playerIds, 
        CancellationToken ct = default)
    {
        var players = await _context.Players
            .Where(p => playerIds.Contains(p.Id))
            .ToListAsync(ct);
            
        var games = await _context.BoardGames.ToListAsync(ct);
        
        return games
            .Select(g => CalculateScore(players, g))
            .OrderByDescending(m => m.Score)
            .ToList();
    }
}
```

### BetManager

```csharp
// Application/Services/BetManager.cs
public class BetManager : IBetManager
{
    private readonly AppDbContext _context;
    
    public BetManager(AppDbContext context) => _context = context;
    
    public async Task<BetValidationResult> ValidateBetAsync(
        Guid sessionId, Guid bettorId, Guid predictedWinnerId, CancellationToken ct = default)
    {
        var session = await _context.GameSessions
            .Include(s => s.Participants)
            .Include(s => s.Bets)
            .FirstOrDefaultAsync(s => s.Id == sessionId, ct);
            
        if (session == null)
            return BetValidationResult.Fail(BetErrorCodes.SessionNotFound, "Session introuvable");
        
        if (session.Status != SessionStatus.Betting)
            return BetValidationResult.Fail(BetErrorCodes.SessionNotInBettingPhase, "Paris fermés");
        
        if (!session.Participants.Any(p => p.Id == bettorId))
            return BetValidationResult.Fail(BetErrorCodes.BettorNotParticipant, "Non participant");
        
        if (!session.Participants.Any(p => p.Id == predictedWinnerId))
            return BetValidationResult.Fail(BetErrorCodes.PredictedNotParticipant, "Joueur non dans la session");
        
        if (session.Bets.Any(b => b.BettorId == bettorId))
            return BetValidationResult.Fail(BetErrorCodes.AlreadyBet, "Déjà parié");
        
        if (bettorId == predictedWinnerId)
            return BetValidationResult.Fail(BetErrorCodes.SelfBetNotAllowed, "Interdiction parier sur soi");
        
        return BetValidationResult.Success();
    }
    
    public async Task<Bet> PlaceBetAsync(Guid sessionId, Guid bettorId, Guid predictedWinnerId, CancellationToken ct = default)
    {
        var validation = await ValidateBetAsync(sessionId, bettorId, predictedWinnerId, ct);
        if (!validation.IsValid)
            throw new InvalidOperationException(validation.ErrorMessage);
        
        var bet = new Bet
        {
            GameSessionId = sessionId,
            BettorId = bettorId,
            PredictedWinnerId = predictedWinnerId,
            PlacedAt = DateTime.UtcNow
        };
        
        _context.Bets.Add(bet);
        await _context.SaveChangesAsync(ct);
        
        return bet;
    }
    
    public async Task<IReadOnlyList<BetResult>> ResolveBetsAsync(
        Guid sessionId, Guid actualWinnerId, CancellationToken ct = default)
    {
        var bets = await _context.Bets
            .Include(b => b.Bettor)
            .Include(b => b.PredictedWinner)
            .Where(b => b.GameSessionId == sessionId)
            .ToListAsync(ct);
            
        var results = new List<BetResult>();
        
        foreach (var bet in bets)
        {
            bet.IsCorrect = bet.PredictedWinnerId == actualWinnerId;
            results.Add(new BetResult
            {
                BetId = bet.Id,
                BettorName = bet.Bettor.Name,
                PredictedWinnerName = bet.PredictedWinner.Name,
                IsCorrect = bet.IsCorrect.Value
            });
        }
        
        await _context.SaveChangesAsync(ct);
        return results;
    }
    
    public async Task<IReadOnlyList<Player>> GetPendingBettorsAsync(Guid sessionId, CancellationToken ct = default)
    {
        var session = await _context.GameSessions
            .Include(s => s.Participants)
            .Include(s => s.Bets)
            .FirstOrDefaultAsync(s => s.Id == sessionId, ct);
            
        if (session == null) return [];
        
        var bettorIds = session.Bets.Select(b => b.BettorId).ToHashSet();
        return session.Participants.Where(p => !bettorIds.Contains(p.Id)).ToList();
    }
    
    public async Task<bool> AllPlayersHaveBetAsync(Guid sessionId, CancellationToken ct = default)
    {
        var pending = await GetPendingBettorsAsync(sessionId, ct);
        return pending.Count == 0;
    }
}
```

---

## Backend : API Controllers

### MatchController

```csharp
// Controllers/MatchController.cs
using Microsoft.AspNetCore.Mvc;
using ProphetProfiler.Application.DTOs;
using ProphetProfiler.Domain.Interfaces.Services;

namespace ProphetProfiler.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MatchController : ControllerBase
{
    private readonly IMatchScoreCalculator _matchCalculator;
    private readonly IPlayerRepository _playerRepo;
    
    public MatchController(IMatchScoreCalculator matchCalculator, IPlayerRepository playerRepo)
    {
        _matchCalculator = matchCalculator;
        _playerRepo = playerRepo;
    }
    
    [HttpPost("best")]
    public async Task<ActionResult<MatchScoreResponse>> FindBestMatch(MatchRequest request)
    {
        var score = await _matchCalculator.FindBestMatchAsync(request.PlayerIds);
        if (score == null) return NotFound();
        
        return Ok(MapToResponse(score));
    }
    
    [HttpPost("rank")]
    public async Task<ActionResult<List<MatchScoreResponse>>> RankGames(MatchRequest request)
    {
        var scores = await _matchCalculator.RankAllGamesAsync(request.PlayerIds);
        return Ok(scores.Select(MapToResponse));
    }
    
    private MatchScoreResponse MapToResponse(MatchScore score) => new()
    {
        BoardGame = new BoardGameResponse
        {
            Id = score.BoardGame.Id,
            Name = score.BoardGame.Name,
            Profile = new GameProfileDto
            {
                Agressivity = score.BoardGame.Profile.Agressivity,
                Patience = score.BoardGame.Profile.Patience,
                Analysis = score.BoardGame.Profile.Analysis,
                Bluff = score.BoardGame.Profile.Bluff
            }
        },
        Score = score.Score,
        Quality = score.Quality.ToString().ToLower(),
        Recommendation = score.Recommendation,
        AxisScores = score.AxisScores.ToDictionary(
            kvp => kvp.Key.ToString().ToLower(), 
            kvp => kvp.Value),
        MainConcern = score.MainConcern
    };
}
```

### SessionsController (extraits)

```csharp
[HttpPost("{id}/bets")]
public async Task<ActionResult<BetResponse>> PlaceBet(
    Guid id, 
    PlaceBetRequest request,
    [FromHeader(Name = "X-Player-Id")] Guid bettorId)
{
    try
    {
        var bet = await _betManager.PlaceBetAsync(id, bettorId, request.PredictedWinnerId);
        return Ok(MapToResponse(bet));
    }
    catch (InvalidOperationException ex)
    {
        return BadRequest(new { error = ex.Message });
    }
}

[HttpPost("{id}/complete")]
public async Task<ActionResult> CompleteSession(Guid id, CompleteSessionRequest request)
{
    var session = await _context.GameSessions.FindAsync(id);
    if (session == null) return NotFound();
    
    session.Status = SessionStatus.Completed;
    session.WinnerId = request.WinnerId;
    session.CompletedAt = DateTime.UtcNow;
    
    // Résoudre les paris
    var betResults = await _betManager.ResolveBetsAsync(id, request.WinnerId);
    
    // Mettre à jour les stats
    await _rankingService.UpdateStatsAfterSessionAsync(id);
    
    await _context.SaveChangesAsync();
    
    return Ok(new { betResults });
}
```

---

## Frontend : Services Dart

### ApiService (Dio)

```dart
// lib/data/services/api_service.dart
import 'package:dio/dio.dart';

class ApiService {
  late final Dio _dio;
  
  ApiService({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'http://10.0.2.2:5000/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {'Content-Type': 'application/json'},
    ));
    
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
  
  Future<T> get<T>(String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic) parser,
  }) async {
    final response = await _dio.get(path, queryParameters: query);
    return parser(response.data);
  }
  
  Future<T> post<T>(String path, {
    dynamic data,
    required T Function(dynamic) parser,
  }) async {
    final response = await _dio.post(path, data: data);
    return parser(response.data);
  }
}
```

### SessionRepository (Flutter)

```dart
// lib/data/repositories/session_repository.dart
import '../models/game_session.dart';
import '../services/api_service.dart';

class SessionRepository {
  final ApiService _api;
  
  SessionRepository(this._api);
  
  Future<List<GameSession>> getSessions() async {
    return _api.get(
      '/sessions',
      parser: (data) => (data as List)
          .map((json) => GameSession.fromJson(json))
          .toList(),
    );
  }
  
  Future<GameSession> createSession({
    required List<String> playerIds,
    required String boardGameId,
  }) async {
    return _api.post(
      '/sessions',
      data: {
        'playerIds': playerIds,
        'boardGameId': boardGameId,
      },
      parser: (data) => GameSession.fromJson(data),
    );
  }
  
  Future<GameSession> placeBet({
    required String sessionId,
    required String bettorId,
    required String predictedWinnerId,
  }) async {
    return _api.post(
      '/sessions/$sessionId/bets',
      data: {'predictedWinnerId': predictedWinnerId},
      parser: (data) => GameSession.fromJson(data),
    );
  }
  
  Future<GameSession> completeSession({
    required String sessionId,
    required String winnerId,
  }) async {
    return _api.post(
      '/sessions/$sessionId/complete',
      data: {'winnerId': winnerId},
      parser: (data) => GameSession.fromJson(data),
    );
  }
}
```

### MatchRepository (Flutter)

```dart
// lib/data/repositories/match_repository.dart
import '../models/match_score.dart';
import '../services/api_service.dart';

class MatchRepository {
  final ApiService _api;
  
  MatchRepository(this._api);
  
  Future<MatchScore> findBestMatch(List<String> playerIds) async {
    return _api.post(
      '/match/best',
      data: {'playerIds': playerIds},
      parser: (data) => MatchScore.fromJson(data),
    );
  }
  
  Future<List<MatchScore>> rankGames(List<String> playerIds) async {
    return _api.post(
      '/match/rank',
      data: {'playerIds': playerIds},
      parser: (data) => (data as List)
          .map((json) => MatchScore.fromJson(json))
          .toList(),
    );
  }
}
```

---

## Frontend : BLOC Pattern

### SessionBloc

```dart
// lib/presentation/blocs/session_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class SessionEvent {}

class LoadSessions extends SessionEvent {}

class CreateSession extends SessionEvent {
  final List<String> playerIds;
  final String boardGameId;
  CreateSession(this.playerIds, this.boardGameId);
}

class PlaceBet extends SessionEvent {
  final String sessionId;
  final String predictedWinnerId;
  PlaceBet(this.sessionId, this.predictedWinnerId);
}

// States
abstract class SessionState {}

class SessionInitial extends SessionState {}
class SessionLoading extends SessionState {}
class SessionsLoaded extends SessionState {
  final List<GameSession> sessions;
  SessionsLoaded(this.sessions);
}
class SessionError extends SessionState {
  final String message;
  SessionError(this.message);
}

// BLOC
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final SessionRepository _repository;
  
  SessionBloc(this._repository) : super(SessionInitial()) {
    on<LoadSessions>(_onLoadSessions);
    on<CreateSession>(_onCreateSession);
    on<PlaceBet>(_onPlaceBet);
  }
  
  Future<void> _onLoadSessions(LoadSessions event, Emitter<SessionState> emit) async {
    emit(SessionLoading());
    try {
      final sessions = await _repository.getSessions();
      emit(SessionsLoaded(sessions));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }
  
  Future<void> _onCreateSession(CreateSession event, Emitter<SessionState> emit) async {
    emit(SessionLoading());
    try {
      await _repository.createSession(
        playerIds: event.playerIds,
        boardGameId: event.boardGameId,
      );
      add(LoadSessions());
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }
  
  Future<void> _onPlaceBet(PlaceBet event, Emitter<SessionState> emit) async {
    try {
      await _repository.placeBet(
        sessionId: event.sessionId,
        // bettorId récupéré du auth context
        predictedWinnerId: event.predictedWinnerId,
      );
      add(LoadSessions());
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }
}
```

---

## Injection de Dépendances

### Backend (Program.cs)

```csharp
// Services métier
builder.Services.AddScoped<IMatchScoreCalculator, MatchScoreCalculator>();
builder.Services.AddScoped<IBetManager, BetManager>();
builder.Services.AddScoped<IRankingService, RankingService>();

// Repositories
builder.Services.AddScoped<IPlayerRepository, PlayerRepository>();
builder.Services.AddScoped<IBoardGameRepository, BoardGameRepository>();
builder.Services.AddScoped<IGameSessionRepository, GameSessionRepository>();
```

### Frontend (get_it)

```dart
// lib/core/injection.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupInjection() {
  // Services
  getIt.registerLazySingleton(() => ApiService());
  
  // Repositories
  getIt.registerLazySingleton(() => SessionRepository(getIt()));
  getIt.registerLazySingleton(() => PlayerRepository(getIt()));
  getIt.registerLazySingleton(() => MatchRepository(getIt()));
  
  // BLOCs
  getIt.registerFactory(() => SessionBloc(getIt()));
  getIt.registerFactory(() => PlayerBloc(getIt()));
  getIt.registerFactory(() => MatchBloc(getIt()));
}
```

---

## Résumé des Responsabilités

| Composant | Backend (.NET) | Frontend (Flutter) |
|-----------|---------------|-------------------|
| **Validation métier** | ✅ Services C# | ❌ (seulement UI) |
| **Calculs** | ✅ Calculators | ❌ |
| **Persistence** | ✅ EF Core/SQLite | ❌ |
| **API** | ✅ Controllers | ❌ (client) |
| **State UI** | ❌ | ✅ BLOC |
| **Navigation** | ❌ | ✅ Navigator |
| **Affichage** | ❌ | ✅ Widgets |
| **Cache local** | ❌ | ✅ Optionnel V2 |
