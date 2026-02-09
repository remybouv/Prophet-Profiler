namespace ProphetProfiler.Api.Models;

public enum GameAxis
{
    Aggressivity = 1,
    Patience = 2,
    Analysis = 3,
    Bluff = 4
}

public enum SessionStatus
{
    Created,
    Betting,
    Playing,
    Completed,
    Cancelled
}

public enum MatchQuality
{
    Avoid,      // 0-24
    Poor,       // 25-39
    Average,    // 40-59
    Good,       // 60-74
    Great,      // 75-89
    Perfect     // 90-100
}

public enum BetType
{
    Winner = 1
}