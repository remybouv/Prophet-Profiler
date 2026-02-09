using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Models;
using ProphetProfiler.Api.Services;
using ProphetProfiler.Api.Tests.Helpers;
using Microsoft.EntityFrameworkCore;

namespace ProphetProfiler.Api.Tests.Services;

public class BetManagerTests
{
    #region ValidateBetAsync - Tests nominaux

    [Fact]
    public async Task ValidateBetAsync_WithValidBet_ShouldReturnTrue()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().WithName("Alice").Build();
        var bob = PlayerBuilder.PatientPlayer().WithName("Bob").Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob }
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act
        var result = await betManager.ValidateBetAsync(session.Id, alice.Id, bob.Id);

        // Assert
        Assert.True(result);
    }

    [Fact]
    public async Task ValidateBetAsync_WithSelfBet_ShouldReturnFalse()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().WithName("Alice").Build();
        var bob = PlayerBuilder.PatientPlayer().WithName("Bob").Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob }
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act - Alice parie sur elle-même (auto-pari interdit selon specs MVP)
        var result = await betManager.ValidateBetAsync(session.Id, alice.Id, alice.Id);

        // Assert
        Assert.False(result);
    }

    #endregion

    #region ValidateBetAsync - Tests d'erreur

    [Fact]
    public async Task ValidateBetAsync_WithNonExistentSession_ShouldReturnFalse()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().Build();
        var bob = PlayerBuilder.PatientPlayer().Build();
        context.Players.AddRange(alice, bob);
        await context.SaveChangesAsync();

        // Act
        var result = await betManager.ValidateBetAsync(Guid.NewGuid(), alice.Id, bob.Id);

        // Assert
        Assert.False(result);
    }

    [Fact]
    public async Task ValidateBetAsync_WithWrongStatus_ShouldReturnFalse()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().Build();
        var bob = PlayerBuilder.PatientPlayer().Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Playing, // Mauvais statut
            Participants = new List<Player> { alice, bob }
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act
        var result = await betManager.ValidateBetAsync(session.Id, alice.Id, bob.Id);

        // Assert
        Assert.False(result);
    }

    [Fact]
    public async Task ValidateBetAsync_WithNonParticipantBettor_ShouldReturnFalse()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().Build();
        var bob = PlayerBuilder.PatientPlayer().Build();
        var charlie = PlayerBuilder.BalancedPlayer().Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob, charlie);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob } // Charlie n'est pas participant
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act - Charlie (non participant) essaie de parier
        var result = await betManager.ValidateBetAsync(session.Id, charlie.Id, alice.Id);

        // Assert
        Assert.False(result);
    }

    [Fact]
    public async Task ValidateBetAsync_WithNonParticipantWinner_ShouldReturnFalse()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().Build();
        var bob = PlayerBuilder.PatientPlayer().Build();
        var charlie = PlayerBuilder.BalancedPlayer().Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob, charlie);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob } // Charlie n'est pas participant
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act - Alice parie sur Charlie (non participant)
        var result = await betManager.ValidateBetAsync(session.Id, alice.Id, charlie.Id);

        // Assert
        Assert.False(result);
    }

    [Fact]
    public async Task ValidateBetAsync_WhenAlreadyBet_ShouldReturnFalse()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().Build();
        var bob = PlayerBuilder.PatientPlayer().Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob },
            Bets = new List<Bet>
            {
                new Bet { BettorId = alice.Id, PredictedWinnerId = bob.Id, PlacedAt = DateTime.UtcNow }
            }
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act - Alice essaie de parier une deuxième fois
        var result = await betManager.ValidateBetAsync(session.Id, alice.Id, bob.Id);

        // Assert
        Assert.False(result);
    }

    #endregion

    #region PlaceBetAsync - Tests

    [Fact]
    public async Task PlaceBetAsync_WithValidBet_ShouldCreateBet()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().WithName("Alice").Build();
        var bob = PlayerBuilder.PatientPlayer().WithName("Bob").Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob }
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act
        var bet = await betManager.PlaceBetAsync(session.Id, alice.Id, bob.Id);

        // Assert
        Assert.NotNull(bet);
        Assert.Equal(session.Id, bet.GameSessionId);
        Assert.Equal(alice.Id, bet.BettorId);
        Assert.Equal(bob.Id, bet.PredictedWinnerId);
        Assert.Null(bet.IsCorrect);
        Assert.Equal(0, bet.PointsEarned);
    }

    [Fact]
    public async Task PlaceBetAsync_WithInvalidBet_ShouldThrowException()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);

        // Act & Assert
        await Assert.ThrowsAsync<InvalidOperationException>(() => 
            betManager.PlaceBetAsync(Guid.NewGuid(), Guid.NewGuid(), Guid.NewGuid()));
    }

    #endregion

    #region ResolveBetsAsync - Tests

    [Fact]
    public async Task ResolveBetsAsync_CorrectBet_ShouldAward10Points()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().WithName("Alice").Build();
        var bob = PlayerBuilder.PatientPlayer().WithName("Bob").Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob },
            WinnerId = alice.Id
        };
        context.GameSessions.Add(session);
        
        var bet = new Bet
        {
            GameSessionId = session.Id,
            BettorId = bob.Id,
            PredictedWinnerId = alice.Id, // Bob prédit correctement qu'Alice gagne
            PlacedAt = DateTime.UtcNow
        };
        context.Bets.Add(bet);
        await context.SaveChangesAsync();

        // Act
        var resolvedBets = await betManager.ResolveBetsAsync(session.Id, alice.Id);

        // Assert
        var resolvedBet = resolvedBets.First();
        Assert.True(resolvedBet.IsCorrect);
        Assert.Equal(10, resolvedBet.PointsEarned);
    }

    [Fact]
    public async Task ResolveBetsAsync_WithMinimumTwoPlayers_AllowsBetting()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().WithName("Alice").Build();
        var bob = PlayerBuilder.PatientPlayer().WithName("Bob").Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob },
            WinnerId = alice.Id
        };
        context.GameSessions.Add(session);
        
        // Alice parie sur Bob (pas d'auto-pari)
        var bet = new Bet
        {
            GameSessionId = session.Id,
            BettorId = alice.Id,
            PredictedWinnerId = bob.Id,
            Type = BetType.Winner,
            PlacedAt = DateTime.UtcNow
        };
        context.Bets.Add(bet);
        await context.SaveChangesAsync();

        // Act
        var resolvedBets = await betManager.ResolveBetsAsync(session.Id, alice.Id);

        // Assert - Mauvaise prédiction = -2 points
        var resolvedBet = resolvedBets.First();
        Assert.False(resolvedBet.IsCorrect);
        Assert.Equal(-2, resolvedBet.PointsEarned);
    }

    [Fact]
    public async Task ResolveBetsAsync_IncorrectBetOthers_ShouldPenalize2Points()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().Build();
        var bob = PlayerBuilder.PatientPlayer().Build();
        var charlie = PlayerBuilder.BalancedPlayer().Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob, charlie);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob, charlie },
            WinnerId = alice.Id
        };
        context.GameSessions.Add(session);
        
        var bet = new Bet
        {
            GameSessionId = session.Id,
            BettorId = bob.Id,
            PredictedWinnerId = charlie.Id, // Mauvaise prédiction
            Type = BetType.Winner,
            PlacedAt = DateTime.UtcNow
        };
        context.Bets.Add(bet);
        await context.SaveChangesAsync();

        // Act
        var resolvedBets = await betManager.ResolveBetsAsync(session.Id, alice.Id);

        // Assert - Selon specs MVP: -2 points pour prédiction incorrecte
        var resolvedBet = resolvedBets.First();
        Assert.False(resolvedBet.IsCorrect);
        Assert.Equal(-2, resolvedBet.PointsEarned);
    }

    [Fact]
    public async Task ResolveBetsAsync_WithNonExistentSession_ShouldThrowException()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);

        // Act & Assert
        await Assert.ThrowsAsync<InvalidOperationException>(() => 
            betManager.ResolveBetsAsync(Guid.NewGuid(), Guid.NewGuid()));
    }

    #endregion

    #region GetPendingBettorsAsync - Tests

    [Fact]
    public async Task GetPendingBettorsAsync_WithPendingBettors_ShouldReturnThem()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().WithName("Alice").Build();
        var bob = PlayerBuilder.PatientPlayer().WithName("Bob").Build();
        var charlie = PlayerBuilder.BalancedPlayer().WithName("Charlie").Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob, charlie);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob, charlie },
            Bets = new List<Bet>
            {
                new Bet { BettorId = alice.Id, PredictedWinnerId = bob.Id, PlacedAt = DateTime.UtcNow },
                new Bet { BettorId = bob.Id, PredictedWinnerId = charlie.Id, PlacedAt = DateTime.UtcNow }
            }
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act
        var pending = await betManager.GetPendingBettorsAsync(session.Id);

        // Assert
        Assert.Single(pending);
        Assert.Equal(charlie.Id, pending[0].Id);
        Assert.Equal("Charlie", pending[0].Name);
    }

    [Fact]
    public async Task GetPendingBettorsAsync_WhenAllHaveBet_ShouldReturnEmptyList()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().Build();
        var bob = PlayerBuilder.PatientPlayer().Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob },
            Bets = new List<Bet>
            {
                new Bet { BettorId = alice.Id, PredictedWinnerId = bob.Id, PlacedAt = DateTime.UtcNow },
                new Bet { BettorId = bob.Id, PredictedWinnerId = alice.Id, PlacedAt = DateTime.UtcNow }
            }
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act
        var pending = await betManager.GetPendingBettorsAsync(session.Id);

        // Assert
        Assert.Empty(pending);
    }

    [Fact]
    public async Task GetPendingBettorsAsync_WithNoBets_ShouldReturnAllParticipants()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().Build();
        var bob = PlayerBuilder.PatientPlayer().Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob }
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act
        var pending = await betManager.GetPendingBettorsAsync(session.Id);

        // Assert
        Assert.Equal(2, pending.Count);
    }

    [Fact]
    public async Task GetPendingBettorsAsync_WithNonExistentSession_ShouldReturnEmptyList()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);

        // Act
        var pending = await betManager.GetPendingBettorsAsync(Guid.NewGuid());

        // Assert
        Assert.Empty(pending);
    }

    #endregion

    #region AllPlayersHaveBetAsync - Tests

    [Fact]
    public async Task AllPlayersHaveBetAsync_WhenAllHaveBet_ShouldReturnTrue()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().Build();
        var bob = PlayerBuilder.PatientPlayer().Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob },
            Bets = new List<Bet>
            {
                new Bet { BettorId = alice.Id, PredictedWinnerId = bob.Id, PlacedAt = DateTime.UtcNow },
                new Bet { BettorId = bob.Id, PredictedWinnerId = alice.Id, PlacedAt = DateTime.UtcNow }
            }
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act
        var result = await betManager.AllPlayersHaveBetAsync(session.Id);

        // Assert
        Assert.True(result);
    }

    [Fact]
    public async Task AllPlayersHaveBetAsync_WhenSomePending_ShouldReturnFalse()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().Build();
        var bob = PlayerBuilder.PatientPlayer().Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob },
            Bets = new List<Bet>
            {
                new Bet { BettorId = alice.Id, PredictedWinnerId = bob.Id, PlacedAt = DateTime.UtcNow }
                // Bob n'a pas parié
            }
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act
        var result = await betManager.AllPlayersHaveBetAsync(session.Id);

        // Assert
        Assert.False(result);
    }

    #endregion

    #region GetBetsSummaryAsync - Tests

    [Fact]
    public async Task GetBetsSummaryAsync_WithValidSession_ShouldReturnSummary()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().WithName("Alice").Build();
        var bob = PlayerBuilder.PatientPlayer().WithName("Bob").Build();
        var charlie = PlayerBuilder.BalancedPlayer().WithName("Charlie").Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob, charlie);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice, bob, charlie },
            Bets = new List<Bet>
            {
                new Bet { 
                    BettorId = alice.Id, 
                    PredictedWinnerId = bob.Id, 
                    Type = BetType.Winner,
                    PlacedAt = DateTime.UtcNow 
                }
            }
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act
        var summary = await betManager.GetBetsSummaryAsync(session.Id);

        // Assert
        Assert.Equal(session.Id, summary.SessionId);
        Assert.Equal(SessionStatus.Betting, summary.SessionStatus);
        Assert.Equal(3, summary.TotalParticipants);
        Assert.Equal(1, summary.TotalBetsPlaced);
        Assert.Single(summary.Bets);
        Assert.Equal(2, summary.PendingBettors.Count);
        Assert.Contains(summary.PendingBettors, p => p.Name == "Bob");
        Assert.Contains(summary.PendingBettors, p => p.Name == "Charlie");
    }

    [Fact]
    public async Task GetBetsSummaryAsync_WithResolvedBets_ShouldIncludeResults()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().WithName("Alice").Build();
        var bob = PlayerBuilder.PatientPlayer().WithName("Bob").Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Completed,
            Participants = new List<Player> { alice, bob },
            WinnerId = bob.Id
        };
        context.GameSessions.Add(session);
        
        var bet = new Bet
        {
            GameSessionId = session.Id,
            BettorId = alice.Id,
            PredictedWinnerId = bob.Id,
            Type = BetType.Winner,
            IsCorrect = true,
            PointsEarned = 10,
            PlacedAt = DateTime.UtcNow
        };
        context.Bets.Add(bet);
        await context.SaveChangesAsync();

        // Act
        var summary = await betManager.GetBetsSummaryAsync(session.Id);

        // Assert
        Assert.Single(summary.Bets);
        Assert.Equal("Alice", summary.Bets[0].BettorName);
        Assert.Equal("Bob", summary.Bets[0].PredictedWinnerName);
        Assert.True(summary.Bets[0].IsCorrect);
        Assert.Equal(10, summary.Bets[0].PointsEarned);
    }

    [Fact]
    public async Task GetBetsSummaryAsync_WithNonExistentSession_ShouldThrowException()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);

        // Act & Assert
        await Assert.ThrowsAsync<InvalidOperationException>(() => 
            betManager.GetBetsSummaryAsync(Guid.NewGuid()));
    }

    #endregion
}
