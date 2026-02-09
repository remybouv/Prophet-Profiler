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
    public async Task ValidateBetAsync_WithSelfBet_ShouldReturnTrue()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var betManager = new BetManager(context);
        
        var alice = PlayerBuilder.AggressivePlayer().WithName("Alice").Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.Add(alice);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Participants = new List<Player> { alice }
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act - Alice parie sur elle-même (auto-pari)
        var result = await betManager.ValidateBetAsync(session.Id, alice.Id, alice.Id);

        // Assert
        Assert.True(result);
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
    public async Task ResolveBetsAsync_CorrectSelfBet_ShouldAward15Points()
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
            BettorId = alice.Id,
            PredictedWinnerId = alice.Id, // Auto-pari gagnant
            PlacedAt = DateTime.UtcNow
        };
        context.Bets.Add(bet);
        await context.SaveChangesAsync();

        // Act
        var resolvedBets = await betManager.ResolveBetsAsync(session.Id, alice.Id);

        // Assert
        var resolvedBet = resolvedBets.First();
        Assert.True(resolvedBet.IsCorrect);
        Assert.Equal(15, resolvedBet.PointsEarned); // 10 base + 5 bonus
    }

    [Fact]
    public async Task ResolveBetsAsync_IncorrectSelfBet_ShouldPenalize2Points()
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
            WinnerId = bob.Id // Bob gagne, pas Alice
        };
        context.GameSessions.Add(session);
        
        var bet = new Bet
        {
            GameSessionId = session.Id,
            BettorId = alice.Id,
            PredictedWinnerId = alice.Id, // Auto-pari perdant
            PlacedAt = DateTime.UtcNow
        };
        context.Bets.Add(bet);
        await context.SaveChangesAsync();

        // Act
        var resolvedBets = await betManager.ResolveBetsAsync(session.Id, bob.Id);

        // Assert
        var resolvedBet = resolvedBets.First();
        Assert.False(resolvedBet.IsCorrect);
        Assert.Equal(-2, resolvedBet.PointsEarned); // Pénalité auto-pari perdant
    }

    [Fact]
    public async Task ResolveBetsAsync_IncorrectBetOthers_ShouldAward0Points()
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
            PredictedWinnerId = charlie.Id, // Mauvaise prédiction (pas auto-pari)
            PlacedAt = DateTime.UtcNow
        };
        context.Bets.Add(bet);
        await context.SaveChangesAsync();

        // Act
        var resolvedBets = await betManager.ResolveBetsAsync(session.Id, alice.Id);

        // Assert
        var resolvedBet = resolvedBets.First();
        Assert.False(resolvedBet.IsCorrect);
        Assert.Equal(0, resolvedBet.PointsEarned); // Pas de pénalité si ce n'est pas auto-pari
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
}
