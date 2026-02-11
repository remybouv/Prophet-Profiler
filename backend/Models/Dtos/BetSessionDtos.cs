using ProphetProfiler.Api.Models;

namespace ProphetProfiler.Api.Models.Dtos;

/// <summary>
/// DTOs pour la création de session de paris (Page Création Paris)
/// </summary>

public record CreateBetSessionRequest(
    Guid BoardGameId,
    List<Guid> PlayerIds,
    DateTime? Date = null,
    string? Location = null,
    string? Notes = null
);

public record AvailablePlayersResponse
{
    public List<PlayerSummaryDto> Players { get; init; } = new();
    public int TotalCount { get; init; }
}

public record PlayerSummaryDto
{
    public Guid Id { get; init; }
    public string Name { get; init; } = string.Empty;
    public string? PhotoUrl { get; init; }
    public int TotalSessions { get; init; }
    public int TotalWins { get; init; }
}

/// <summary>
/// DTOs pour la page Session Active
/// </summary>

public record SessionActiveDetails
{
    public Guid SessionId { get; init; }
    public string BoardGameName { get; init; } = string.Empty;
    public string? BoardGameImageUrl { get; init; }
    public SessionStatus Status { get; init; }
    public DateTime Date { get; init; }
    public string? Location { get; init; }
    public List<ParticipantBetInfo> Participants { get; init; } = new();
    public List<BetDetailDto> Bets { get; init; } = new();
    public Guid? CurrentWinnerId { get; init; }
    public string? CurrentWinnerName { get; init; }
    public int TotalPointsInPlay { get; init; }
    public bool AllPlayersHaveBet { get; init; }
    public bool CanStartPlaying { get; init; }
}

public record ParticipantBetInfo
{
    public Guid PlayerId { get; init; }
    public string Name { get; init; } = string.Empty;
    public string? PhotoUrl { get; init; }
    public bool HasPlacedBet { get; init; }
    public Guid? BetOnPlayerId { get; init; }
    public string? BetOnPlayerName { get; init; }
    public DateTime? BetPlacedAt { get; init; }
}

public record BetDetailDto
{
    public Guid BetId { get; init; }
    public Guid BettorId { get; init; }
    public string BettorName { get; init; } = string.Empty;
    public string? BettorPhotoUrl { get; init; }
    public Guid PredictedWinnerId { get; init; }
    public string PredictedWinnerName { get; init; } = string.Empty;
    public DateTime PlacedAt { get; init; }
    public bool? IsCorrect { get; init; }
    public int PointsEarned { get; init; }
}

/// <summary>
/// DTOs pour la sélection du gagnant et résolution des paris
/// </summary>

public record SetWinnerRequest(Guid WinnerId);

public record SetWinnerResponse
{
    public Guid SessionId { get; init; }
    public Guid WinnerId { get; init; }
    public string WinnerName { get; init; } = string.Empty;
    public SessionStatus NewStatus { get; init; }
    public List<BetResolutionDto> BetResolutions { get; init; } = new();
    public int TotalPointsAwarded { get; init; }
    public int TotalPointsDeducted { get; init; }
}

public record BetResolutionDto
{
    public Guid BettorId { get; init; }
    public string BettorName { get; init; } = string.Empty;
    public string? BettorPhotoUrl { get; init; }
    public Guid PredictedWinnerId { get; init; }
    public bool IsCorrect { get; init; }
    public int PointsEarned { get; init; }
    public string ResultEmoji { get; init; } = string.Empty;
}

/// <summary>
/// DTOs pour la homepage
/// </summary>

public record ActiveSessionInfo
{
    public Guid SessionId { get; init; }
    public string BoardGameName { get; init; } = string.Empty;
    public SessionStatus Status { get; init; }
    public DateTime Date { get; init; }
    public int ParticipantCount { get; init; }
    public int BetsPlacedCount { get; init; }
    public bool HasActiveSession { get; init; }
}

public record HomepageDataResponse
{
    public ActiveSessionInfo? ActiveSession { get; init; }
    public int TotalPlayers { get; init; }
    public int TotalGames { get; init; }
    public List<RecentSessionDto> RecentSessions { get; init; } = new();
}

public record RecentSessionDto
{
    public Guid SessionId { get; init; }
    public string BoardGameName { get; init; } = string.Empty;
    public DateTime Date { get; init; }
    public SessionStatus Status { get; init; }
    public string? WinnerName { get; init; }
}
