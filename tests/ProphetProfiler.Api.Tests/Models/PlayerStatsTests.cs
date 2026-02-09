using ProphetProfiler.Api.Models;
using ProphetProfiler.Api.Tests.Helpers;

namespace ProphetProfiler.Api.Tests.Models;

public class PlayerStatsTests
{
    #region WinRate - Tests

    [Fact]
    public void WinRate_WithGamesPlayed_ShouldCalculateCorrectly()
    {
        // Arrange
        var stats = new PlayerStats
        {
            TotalGamesPlayed = 10,
            GamesWon = 4
        };

        // Act & Assert
        Assert.Equal(40.0, stats.WinRate);
    }

    [Fact]
    public void WinRate_WithAllWins_ShouldBe100()
    {
        // Arrange
        var stats = new PlayerStats
        {
            TotalGamesPlayed = 5,
            GamesWon = 5
        };

        // Act & Assert
        Assert.Equal(100.0, stats.WinRate);
    }

    [Fact]
    public void WinRate_WithNoWins_ShouldBe0()
    {
        // Arrange
        var stats = new PlayerStats
        {
            TotalGamesPlayed = 5,
            GamesWon = 0
        };

        // Act & Assert
        Assert.Equal(0.0, stats.WinRate);
    }

    [Fact]
    public void WinRate_WithNoGamesPlayed_ShouldBe0()
    {
        // Arrange
        var stats = new PlayerStats
        {
            TotalGamesPlayed = 0,
            GamesWon = 0
        };

        // Act & Assert
        Assert.Equal(0.0, stats.WinRate); // Pas de division par zéro
    }

    [Fact]
    public void WinRate_DefaultValues_ShouldBe0()
    {
        // Arrange
        var stats = new PlayerStats();

        // Act & Assert
        Assert.Equal(0.0, stats.WinRate);
    }

    #endregion

    #region PredictionAccuracy - Tests

    [Fact]
    public void PredictionAccuracy_WithBetsPlaced_ShouldCalculateCorrectly()
    {
        // Arrange
        var stats = new PlayerStats
        {
            TotalBetsPlaced = 10,
            BetsCorrect = 7
        };

        // Act & Assert
        Assert.Equal(70.0, stats.PredictionAccuracy);
    }

    [Fact]
    public void PredictionAccuracy_WithAllCorrect_ShouldBe100()
    {
        // Arrange
        var stats = new PlayerStats
        {
            TotalBetsPlaced = 5,
            BetsCorrect = 5
        };

        // Act & Assert
        Assert.Equal(100.0, stats.PredictionAccuracy);
    }

    [Fact]
    public void PredictionAccuracy_WithNoCorrect_ShouldBe0()
    {
        // Arrange
        var stats = new PlayerStats
        {
            TotalBetsPlaced = 5,
            BetsCorrect = 0
        };

        // Act & Assert
        Assert.Equal(0.0, stats.PredictionAccuracy);
    }

    [Fact]
    public void PredictionAccuracy_WithNoBetsPlaced_ShouldBe0()
    {
        // Arrange
        var stats = new PlayerStats
        {
            TotalBetsPlaced = 0,
            BetsCorrect = 0
        };

        // Act & Assert
        Assert.Equal(0.0, stats.PredictionAccuracy); // Pas de division par zéro
    }

    [Fact]
    public void PredictionAccuracy_DefaultValues_ShouldBe0()
    {
        // Arrange
        var stats = new PlayerStats();

        // Act & Assert
        Assert.Equal(0.0, stats.PredictionAccuracy);
    }

    #endregion

    #region RecordGamePlayed - Tests

    [Fact]
    public void RecordGamePlayed_WithWin_ShouldIncrementBothCounters()
    {
        // Arrange
        var stats = new PlayerStats();
        var beforeDate = stats.LastUpdated;

        // Act
        stats.RecordGamePlayed(won: true);

        // Assert
        Assert.Equal(1, stats.TotalGamesPlayed);
        Assert.Equal(1, stats.GamesWon);
        Assert.True(stats.LastUpdated >= beforeDate);
    }

    [Fact]
    public void RecordGamePlayed_WithLoss_ShouldIncrementOnlyTotal()
    {
        // Arrange
        var stats = new PlayerStats();

        // Act
        stats.RecordGamePlayed(won: false);

        // Assert
        Assert.Equal(1, stats.TotalGamesPlayed);
        Assert.Equal(0, stats.GamesWon);
    }

    [Fact]
    public void RecordGamePlayed_MultipleTimes_ShouldAccumulate()
    {
        // Arrange
        var stats = new PlayerStats();

        // Act
        stats.RecordGamePlayed(won: true);   // 1/1
        stats.RecordGamePlayed(won: false);  // 1/2
        stats.RecordGamePlayed(won: true);   // 2/3
        stats.RecordGamePlayed(won: true);   // 3/4

        // Assert
        Assert.Equal(4, stats.TotalGamesPlayed);
        Assert.Equal(3, stats.GamesWon);
        Assert.Equal(75.0, stats.WinRate);
    }

    [Fact]
    public void RecordGamePlayed_ShouldUpdateLastUpdated()
    {
        // Arrange
        var stats = new PlayerStats();
        var initialDate = DateTime.UtcNow.AddMinutes(-1);
        stats.LastUpdated = initialDate;

        // Act
        stats.RecordGamePlayed(won: true);

        // Assert
        Assert.True(stats.LastUpdated > initialDate);
    }

    #endregion

    #region RecordBet - Tests

    [Fact]
    public void RecordBet_WithCorrect_ShouldIncrementBothCounters()
    {
        // Arrange
        var stats = new PlayerStats();

        // Act
        stats.RecordBet(correct: true);
        stats.OraclePoints += 10;

        // Assert
        Assert.Equal(1, stats.TotalBetsPlaced);
        Assert.Equal(1, stats.BetsCorrect);
        Assert.Equal(10, stats.OraclePoints);
    }

    [Fact]
    public void RecordBet_WithIncorrect_ShouldIncrementOnlyTotal()
    {
        // Arrange
        var stats = new PlayerStats();

        // Act
        stats.RecordBet(correct: false);
        stats.OraclePoints -= 2;

        // Assert
        Assert.Equal(1, stats.TotalBetsPlaced);
        Assert.Equal(0, stats.BetsCorrect);
        Assert.Equal(-2, stats.OraclePoints);
    }

    [Fact]
    public void RecordBet_MultipleTimes_ShouldAccumulate()
    {
        // Arrange
        var stats = new PlayerStats();

        // Act
        stats.RecordBet(correct: true); stats.OraclePoints += 10;   // 1/1
        stats.RecordBet(correct: true); stats.OraclePoints += 10;   // 2/2
        stats.RecordBet(correct: false); stats.OraclePoints -= 2;   // 2/3
        stats.RecordBet(correct: true); stats.OraclePoints += 10;   // 3/4
        stats.RecordBet(correct: false); stats.OraclePoints -= 2;   // 3/5

        // Assert
        Assert.Equal(5, stats.TotalBetsPlaced);
        Assert.Equal(3, stats.BetsCorrect);
        Assert.Equal(60.0, stats.PredictionAccuracy);
        Assert.Equal(26, stats.OraclePoints); // 10+10-2+10-2 = 26
    }

    [Fact]
    public void RecordBet_ShouldUpdateLastUpdated()
    {
        // Arrange
        var stats = new PlayerStats();
        var initialDate = DateTime.UtcNow.AddMinutes(-1);
        stats.LastUpdated = initialDate;

        // Act
        stats.RecordBet(correct: true);

        // Assert
        Assert.True(stats.LastUpdated > initialDate);
    }

    [Fact]
    public void RecordBet_WithOraclePoints_ShouldAccumulatePoints()
    {
        // Arrange
        var stats = new PlayerStats();

        // Act - Les points sont gérés séparément via OraclePoints
        stats.RecordBet(correct: true);
        stats.OraclePoints += 10;

        // Assert
        Assert.Equal(1, stats.TotalBetsPlaced);
        Assert.Equal(1, stats.BetsCorrect);
        Assert.Equal(10, stats.OraclePoints);
        // Note: PlayerStats stocke maintenant les points Oracle séparément
    }

    #endregion

    #region Combined Stats - Tests

    [Fact]
    public void CombinedStats_PlayerWithGamesAndBets_ShouldCalculateBothRates()
    {
        // Arrange
        var stats = new PlayerStats();

        // 10 parties, 4 victoires = 40% WinRate
        for (int i = 0; i < 6; i++) stats.RecordGamePlayed(won: false);
        for (int i = 0; i < 4; i++) stats.RecordGamePlayed(won: true);

        // 10 paris, 8 corrects = 80% Accuracy
        for (int i = 0; i < 2; i++) { stats.RecordBet(correct: false); stats.OraclePoints -= 2; }
        for (int i = 0; i < 8; i++) { stats.RecordBet(correct: true); stats.OraclePoints += 10; }

        // Act & Assert
        Assert.Equal(10, stats.TotalGamesPlayed);
        Assert.Equal(4, stats.GamesWon);
        Assert.Equal(40.0, stats.WinRate);

        Assert.Equal(10, stats.TotalBetsPlaced);
        Assert.Equal(8, stats.BetsCorrect);
        Assert.Equal(80.0, stats.PredictionAccuracy);
    }

    [Fact]
    public void CombinedStats_NewPlayer_ShouldHaveZeroRates()
    {
        // Arrange
        var player = PlayerBuilder.BalancedPlayer().Build();
        var stats = new PlayerStats { PlayerId = player.Id };

        // Act & Assert
        Assert.Equal(0, stats.TotalGamesPlayed);
        Assert.Equal(0, stats.GamesWon);
        Assert.Equal(0.0, stats.WinRate);
        Assert.Equal(0, stats.TotalBetsPlaced);
        Assert.Equal(0, stats.BetsCorrect);
        Assert.Equal(0.0, stats.PredictionAccuracy);
    }

    #endregion
}
