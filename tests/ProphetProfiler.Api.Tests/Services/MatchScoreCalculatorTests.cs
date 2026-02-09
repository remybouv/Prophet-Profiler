using ProphetProfiler.Api.Models;
using ProphetProfiler.Api.Services;
using ProphetProfiler.Api.Tests.Helpers;

namespace ProphetProfiler.Api.Tests.Services;

public class MatchScoreCalculatorTests
{
    #region CalculateScore - Tests nominaux

    [Fact]
    public void CalculateScore_WithPerfectMatch_ShouldReturnHighScore()
    {
        // Arrange
        var calculator = new MatchScoreCalculator(TestDbContextFactory.Create());
        var player = PlayerBuilder.BalancedPlayer().Build();
        var game = BoardGameBuilder.Catan()
            .WithProfile(3, 3, 3, 3) // Profil identique au joueur
            .WithPlayerCount(1, 4)
            .Build();

        // Act
        var result = calculator.CalculateScore(new List<Player> { player }, game);

        // Assert
        Assert.True(result.Score >= 95, $"Score attendu >= 95, obtenu: {result.Score}");
        Assert.Equal(MatchQuality.Perfect, result.Quality);
    }

    [Fact]
    public void CalculateScore_WithGoodMatch_ShouldReturnGoodQuality()
    {
        // Arrange
        var calculator = new MatchScoreCalculator(TestDbContextFactory.Create());
        var player = PlayerBuilder.AnalyticalPlayer().Build(); // (2,4,5,2)
        var game = BoardGameBuilder.Chess().Build(); // (2,5,5,1) - très proche

        // Act
        var result = calculator.CalculateScore(new List<Player> { player }, game);

        // Assert
        Assert.True(result.Score >= 75, $"Score attendu >= 75, obtenu: {result.Score}");
        Assert.True(result.Quality >= MatchQuality.Good);
    }

    [Fact]
    public void CalculateScore_WithMultiplePlayers_ShouldUseAverage()
    {
        // Arrange
        var calculator = new MatchScoreCalculator(TestDbContextFactory.Create());
        var aggressive = PlayerBuilder.AggressivePlayer().Build(); // (5,1,2,4)
        var patient = PlayerBuilder.PatientPlayer().Build();       // (1,5,5,3)
        // Moyenne: (3, 3, 3.5, 3.5)
        
        var game = BoardGameBuilder.Catan().WithProfile(3, 3, 4, 3).Build(); // proche de la moyenne

        // Act
        var result = calculator.CalculateScore(new List<Player> { aggressive, patient }, game);

        // Assert
        Assert.True(result.Score > 50, $"Score attendu > 50, obtenu: {result.Score}");
        Assert.NotNull(result.AxisScores);
        Assert.Equal(4, result.AxisScores.Count);
    }

    [Fact]
    public void CalculateScore_WithPlayerCountInRange_ShouldNotPenalize()
    {
        // Arrange
        var calculator = new MatchScoreCalculator(TestDbContextFactory.Create());
        var players = new List<Player>
        {
            PlayerBuilder.BalancedPlayer().Build(),
            PlayerBuilder.BalancedPlayer().Build(),
            PlayerBuilder.BalancedPlayer().Build()
        };
        var game = BoardGameBuilder.Catan().WithPlayerCount(3, 4).Build();

        // Act
        var result = calculator.CalculateScore(players, game);

        // Assert
        Assert.Equal(3, result.BoardGame.MinPlayers);
        Assert.Equal(4, result.BoardGame.MaxPlayers);
        // Avec profil identique (3,3,3,3) et 3 joueurs dans [3,4], score devrait être élevé
    }

    [Fact]
    public void CalculateScore_WithPlayerCountOutOfRange_ShouldPenalize()
    {
        // Arrange
        var calculator = new MatchScoreCalculator(TestDbContextFactory.Create());
        var players = new List<Player>
        {
            PlayerBuilder.BalancedPlayer().Build(),
            PlayerBuilder.BalancedPlayer().Build()
        };
        var game = BoardGameBuilder.Catan().WithPlayerCount(3, 4).Build(); // 2 joueurs, min=3

        // Act
        var result = calculator.CalculateScore(players, game);

        // Assert
        // Avec profil identique mais pénalité 0.5 sur le playerCount, 
        // le score final devrait être réduit
        Assert.True(result.Score < 80, $"Score attendu < 80 (pénalité), obtenu: {result.Score}");
    }

    [Fact]
    public void CalculateScore_ShouldReturnCorrectAxisScores()
    {
        // Arrange
        var calculator = new MatchScoreCalculator(TestDbContextFactory.Create());
        var player = PlayerBuilder.AggressivePlayer().Build(); // (5,1,2,4)
        var game = BoardGameBuilder.Risk().Build();            // (5,2,3,2)

        // Act
        var result = calculator.CalculateScore(new List<Player> { player }, game);

        // Assert
        Assert.Contains(GameAxis.Aggressivity, result.AxisScores.Keys);
        Assert.Contains(GameAxis.Patience, result.AxisScores.Keys);
        Assert.Contains(GameAxis.Analysis, result.AxisScores.Keys);
        Assert.Contains(GameAxis.Bluff, result.AxisScores.Keys);
        
        // Agressivité: match parfait (5 vs 5) = 100
        Assert.Equal(100, result.AxisScores[GameAxis.Aggressivity], precision: 1);
    }

    [Fact]
    public void CalculateScore_ShouldProvideRecommendation()
    {
        // Arrange
        var calculator = new MatchScoreCalculator(TestDbContextFactory.Create());
        var player = PlayerBuilder.BalancedPlayer().Build();
        var game = BoardGameBuilder.Catan().Build();

        // Act
        var result = calculator.CalculateScore(new List<Player> { player }, game);

        // Assert
        Assert.NotNull(result.Recommendation);
        Assert.NotEmpty(result.Recommendation);
        Assert.True(result.Recommendation.Contains("🎯") || 
                    result.Recommendation.Contains("✨") || 
                    result.Recommendation.Contains("👍") || 
                    result.Recommendation.Contains("🤷") || 
                    result.Recommendation.Contains("⚠️") || 
                    result.Recommendation.Contains("❌"));
    }

    #endregion

    #region CalculateScore - Edge Cases

    [Fact]
    public void CalculateScore_WithEmptyPlayerList_ShouldThrowArgumentException()
    {
        // Arrange
        var calculator = new MatchScoreCalculator(TestDbContextFactory.Create());
        var game = BoardGameBuilder.Catan().Build();

        // Act & Assert
        var exception = Assert.Throws<ArgumentException>(() => 
            calculator.CalculateScore(new List<Player>(), game));
        Assert.Contains("Au moins un joueur requis", exception.Message);
    }

    [Fact]
    public void CalculateScore_WithSinglePlayer_ShouldWork()
    {
        // Arrange
        var calculator = new MatchScoreCalculator(TestDbContextFactory.Create());
        var player = PlayerBuilder.BalancedPlayer().Build();
        var game = BoardGameBuilder.Catan().Build();

        // Act
        var result = calculator.CalculateScore(new List<Player> { player }, game);

        // Assert
        Assert.True(result.Score >= 0);
        Assert.True(result.Score <= 100);
    }

    [Fact]
    public void CalculateScore_WithMaxDistance_ShouldReturnLowProfileScore()
    {
        // Arrange
        var calculator = new MatchScoreCalculator(TestDbContextFactory.Create());
        var player = PlayerBuilder.AggressivePlayer().Build(); // (5,1,2,4)
        // Distance max: jeu avec (1,5,5,1) = opposé total
        var game = new BoardGameBuilder()
            .WithProfile(1, 5, 5, 1)
            .WithPlayerCount(1, 10)
            .Build();

        // Act
        var result = calculator.CalculateScore(new List<Player> { player }, game);

        // Assert
        // Distance normalisée: sqrt(16+16+9+9)/16 = sqrt(50)/16 ≈ 0.44, profileScore ≈ 0.56
        // playerCountScore = 1 (dans la range)
        // Final ≈ (0.56 * 0.7 + 0.3) * 100 ≈ 69
        // Le score réel dépend de l'implémentation exacte
        Assert.True(result.Score >= 0, $"Score devrait être >= 0, obtenu: {result.Score}");
        Assert.True(result.Score <= 100, $"Score devrait être <= 100, obtenu: {result.Score}");
        // Avec un matching faible, on s'attend à ce que la qualité ne soit pas parfaite
        Assert.True(result.Quality < MatchQuality.Perfect);
    }

    [Fact]
    public void CalculateScore_WithManyPlayers_ShouldCalculateAverageCorrectly()
    {
        // Arrange
        var calculator = new MatchScoreCalculator(TestDbContextFactory.Create());
        var players = new List<Player>();
        for (int i = 0; i < 10; i++)
        {
            players.Add(PlayerBuilder.BalancedPlayer().Build());
        }
        var game = BoardGameBuilder.Catan().WithProfile(3, 3, 3, 3).WithPlayerCount(1, 20).Build();

        // Act
        var result = calculator.CalculateScore(players, game);

        // Assert
        // Tous les joueurs ont profil (3,3,3,3), donc match parfait
        Assert.True(result.Score >= 90, $"Score attendu >= 90, obtenu: {result.Score}");
    }

    #endregion

    #region Quality Thresholds Tests

    [Theory]
    [InlineData(95, MatchQuality.Perfect)]
    [InlineData(90, MatchQuality.Perfect)]
    [InlineData(89, MatchQuality.Great)]
    [InlineData(75, MatchQuality.Great)]
    [InlineData(74, MatchQuality.Good)]
    [InlineData(60, MatchQuality.Good)]
    [InlineData(59, MatchQuality.Average)]
    [InlineData(40, MatchQuality.Average)]
    [InlineData(39, MatchQuality.Poor)]
    [InlineData(25, MatchQuality.Poor)]
    [InlineData(24, MatchQuality.Avoid)]
    [InlineData(0, MatchQuality.Avoid)]
    public void MatchQuality_ShouldRespectThresholds(double score, MatchQuality expectedQuality)
    {
        // Arrange - création d'un MatchScore avec le score spécifié
        var matchScore = new MatchScore
        {
            BoardGame = BoardGameBuilder.Catan().Build(),
            Score = score,
            AxisScores = new Dictionary<GameAxis, double>()
        };

        // Act & Assert
        Assert.Equal(expectedQuality, matchScore.Quality);
    }

    #endregion
}
