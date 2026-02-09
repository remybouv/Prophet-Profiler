using Microsoft.AspNetCore.Mvc;
using ProphetProfiler.Api.Controllers;
using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Models;
using ProphetProfiler.Api.Tests.Helpers;

namespace ProphetProfiler.Api.Tests.Controllers;

public class PlayersControllerTests
{
    #region GetBetHistory - Tests

    [Fact]
    public async Task GetBetHistory_WithExistingPlayer_ShouldReturnHistory()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var controller = new PlayersController(context);
        
        var alice = PlayerBuilder.AggressivePlayer().WithName("Alice").Build();
        var bob = PlayerBuilder.PatientPlayer().WithName("Bob").Build();
        var charlie = PlayerBuilder.BalancedPlayer().WithName("Charlie").Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob, charlie);
        context.BoardGames.Add(game);
        
        var session1 = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Completed,
            Participants = new List<Player> { alice, bob, charlie },
            WinnerId = bob.Id
        };
        var session2 = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Completed,
            Participants = new List<Player> { alice, bob },
            WinnerId = alice.Id
        };
        context.GameSessions.AddRange(session1, session2);
        
        // Alice a parié sur Bob (correct dans session1, incorrect dans session2 si alice gagne)
        context.Bets.AddRange(
            new Bet 
            { 
                GameSessionId = session1.Id,
                BettorId = alice.Id, 
                PredictedWinnerId = bob.Id,
                Type = BetType.Winner,
                IsCorrect = true,
                PointsEarned = 10,
                PlacedAt = DateTime.UtcNow.AddDays(-2)
            },
            new Bet 
            { 
                GameSessionId = session2.Id,
                BettorId = alice.Id, 
                PredictedWinnerId = bob.Id,
                Type = BetType.Winner,
                IsCorrect = false,
                PointsEarned = -2,
                PlacedAt = DateTime.UtcNow.AddDays(-1)
            }
        );
        await context.SaveChangesAsync();

        // Act
        var result = await controller.GetBetHistory(alice.Id);

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var history = Assert.IsType<BetHistoryResponse>(okResult.Value);
        Assert.Equal(2, history.TotalCount);
        Assert.Equal(2, history.Bets.Count);
        Assert.Equal(1, history.Page);
        Assert.Equal(1, history.TotalPages);
        
        // Vérifier l'ordre décroissant
        Assert.True(history.Bets[0].PlacedAt > history.Bets[1].PlacedAt);
        
        // Vérifier les points
        Assert.Equal(-2, history.Bets[0].PointsEarned); // Plus récent
        Assert.Equal(10, history.Bets[1].PointsEarned); // Plus ancien
    }

    [Fact]
    public async Task GetBetHistory_WithPagination_ShouldReturnCorrectPage()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var controller = new PlayersController(context);
        
        var alice = PlayerBuilder.AggressivePlayer().Build();
        var bob = PlayerBuilder.PatientPlayer().Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        // Créer 5 sessions avec des paris
        for (int i = 0; i < 5; i++)
        {
            var session = new GameSession
            {
                BoardGameId = game.Id,
                Status = SessionStatus.Completed,
                Participants = new List<Player> { alice, bob },
                WinnerId = bob.Id
            };
            context.GameSessions.Add(session);
            context.Bets.Add(new Bet
            {
                GameSessionId = session.Id,
                BettorId = alice.Id,
                PredictedWinnerId = bob.Id,
                Type = BetType.Winner,
                PlacedAt = DateTime.UtcNow.AddDays(-i)
            });
        }
        await context.SaveChangesAsync();

        // Act - Page 1 avec 2 éléments par page
        var result = await controller.GetBetHistory(alice.Id, page: 1, pageSize: 2);

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var history = Assert.IsType<BetHistoryResponse>(okResult.Value);
        Assert.Equal(5, history.TotalCount);
        Assert.Equal(2, history.Bets.Count);
        Assert.Equal(1, history.Page);
        Assert.Equal(3, history.TotalPages);
    }

    [Fact]
    public async Task GetBetHistory_WithNonExistentPlayer_ShouldReturnNotFound()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var controller = new PlayersController(context);

        // Act
        var result = await controller.GetBetHistory(Guid.NewGuid());

        // Assert
        var notFoundResult = Assert.IsType<NotFoundObjectResult>(result.Result);
        Assert.Equal("Joueur non trouvé", notFoundResult.Value);
    }

    [Fact]
    public async Task GetBetHistory_WithNoBets_ShouldReturnEmptyList()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var controller = new PlayersController(context);
        
        var alice = PlayerBuilder.AggressivePlayer().Build();
        context.Players.Add(alice);
        await context.SaveChangesAsync();

        // Act
        var result = await controller.GetBetHistory(alice.Id);

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var history = Assert.IsType<BetHistoryResponse>(okResult.Value);
        Assert.Equal(0, history.TotalCount);
        Assert.Empty(history.Bets);
        Assert.Equal(0, history.TotalPages);
    }

    [Fact]
    public async Task GetBetHistory_WithInvalidPage_ShouldUseDefaultValues()
    {
        // Arrange
        await using var context = TestDbContextFactory.Create();
        var controller = new PlayersController(context);
        
        var alice = PlayerBuilder.AggressivePlayer().Build();
        var bob = PlayerBuilder.PatientPlayer().Build();
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
        context.Bets.Add(new Bet
        {
            GameSessionId = session.Id,
            BettorId = alice.Id,
            PredictedWinnerId = bob.Id,
            Type = BetType.Winner,
            PlacedAt = DateTime.UtcNow
        });
        await context.SaveChangesAsync();

        // Act - Page négative devient 1, pageSize > 100 devient 10
        var result = await controller.GetBetHistory(alice.Id, page: -1, pageSize: 200);

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var history = Assert.IsType<BetHistoryResponse>(okResult.Value);
        Assert.Single(history.Bets);
    }

    #endregion
}