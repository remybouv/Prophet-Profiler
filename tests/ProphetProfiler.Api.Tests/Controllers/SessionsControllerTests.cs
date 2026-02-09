using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProphetProfiler.Api.Controllers;
using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Models;
using ProphetProfiler.Api.Services;
using ProphetProfiler.Api.Tests.Helpers;

namespace ProphetProfiler.Api.Tests.Controllers;

public class SessionsControllerTests
{
    private AppDbContext CreateContext()
    {
        return TestDbContextFactory.Create();
    }

    #region TransitionStatus - Tests

    [Fact]
    public async Task TransitionStatus_FromCreatedToBetting_With2Players_ShouldSucceed()
    {
        // Arrange
        await using var context = CreateContext();
        var betManager = new BetManager(context);
        var rankingService = new RankingService(context);
        var controller = new SessionsController(context, betManager, rankingService);
        
        var alice = PlayerBuilder.AggressivePlayer().WithName("Alice").Build();
        var bob = PlayerBuilder.PatientPlayer().WithName("Bob").Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Created,
            Participants = new List<Player> { alice, bob }
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act
        var result = await controller.TransitionStatus(session.Id, new TransitionRequest(SessionStatus.Betting));

        // Assert
        Assert.IsType<NoContentResult>(result);
        
        var updatedSession = await context.GameSessions.FindAsync(session.Id);
        Assert.Equal(SessionStatus.Betting, updatedSession!.Status);
    }

    [Fact]
    public async Task TransitionStatus_FromCreatedToBetting_WithOnly1Player_ShouldFail()
    {
        // Arrange
        await using var context = CreateContext();
        var betManager = new BetManager(context);
        var rankingService = new RankingService(context);
        var controller = new SessionsController(context, betManager, rankingService);
        
        var alice = PlayerBuilder.AggressivePlayer().WithName("Alice").Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.Add(alice);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Created,
            Participants = new List<Player> { alice } // Un seul joueur
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act
        var result = await controller.TransitionStatus(session.Id, new TransitionRequest(SessionStatus.Betting));

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Equal("Minimum 2 joueurs requis pour activer les paris", badRequestResult.Value);
    }

    [Fact]
    public async Task TransitionStatus_FromBettingToPlaying_ShouldSucceed()
    {
        // Arrange
        await using var context = CreateContext();
        var betManager = new BetManager(context);
        var rankingService = new RankingService(context);
        var controller = new SessionsController(context, betManager, rankingService);
        
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
        var result = await controller.TransitionStatus(session.Id, new TransitionRequest(SessionStatus.Playing));

        // Assert
        Assert.IsType<NoContentResult>(result);
        
        var updatedSession = await context.GameSessions.FindAsync(session.Id);
        Assert.Equal(SessionStatus.Playing, updatedSession!.Status);
    }

    [Fact]
    public async Task TransitionStatus_InvalidTransition_ShouldFail()
    {
        // Arrange
        await using var context = CreateContext();
        var betManager = new BetManager(context);
        var rankingService = new RankingService(context);
        var controller = new SessionsController(context, betManager, rankingService);
        
        var alice = PlayerBuilder.AggressivePlayer().Build();
        var bob = PlayerBuilder.PatientPlayer().Build();
        var game = BoardGameBuilder.Catan().Build();
        
        context.Players.AddRange(alice, bob);
        context.BoardGames.Add(game);
        
        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Created,
            Participants = new List<Player> { alice, bob }
        };
        context.GameSessions.Add(session);
        await context.SaveChangesAsync();

        // Act - Transition invalide: Created -> Completed
        var result = await controller.TransitionStatus(session.Id, new TransitionRequest(SessionStatus.Completed));

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("Transition invalide", badRequestResult.Value!.ToString());
    }

    [Fact]
    public async Task TransitionStatus_WithNonExistentSession_ShouldReturnNotFound()
    {
        // Arrange
        await using var context = CreateContext();
        var betManager = new BetManager(context);
        var rankingService = new RankingService(context);
        var controller = new SessionsController(context, betManager, rankingService);

        // Act
        var result = await controller.TransitionStatus(Guid.NewGuid(), new TransitionRequest(SessionStatus.Betting));

        // Assert
        var notFoundResult = Assert.IsType<NotFoundObjectResult>(result);
        Assert.Equal("Session non trouvée", notFoundResult.Value);
    }

    #endregion

    #region PlaceBet - Tests

    [Fact]
    public async Task PlaceBet_WithSelfBet_ShouldReturnBadRequest()
    {
        // Arrange
        await using var context = CreateContext();
        var betManager = new BetManager(context);
        var rankingService = new RankingService(context);
        var controller = new SessionsController(context, betManager, rankingService);
        
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

        // Act - Auto-pari interdit
        var result = await controller.PlaceBet(session.Id, new PlaceBetRequest(alice.Id, alice.Id));

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result.Result);
        Assert.Equal("Auto-pari interdit : vous ne pouvez pas parier sur vous-même", badRequestResult.Value);
    }

    #endregion

    #region GetBetsSummary - Tests

    [Fact]
    public async Task GetBetsSummary_WithValidSession_ShouldReturnSummary()
    {
        // Arrange
        await using var context = CreateContext();
        var betManager = new BetManager(context);
        var rankingService = new RankingService(context);
        var controller = new SessionsController(context, betManager, rankingService);
        
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
            Bets = new List<Bet>
            {
                new Bet 
                { 
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
        var result = await controller.GetBetsSummary(session.Id);

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var summary = Assert.IsType<BetsSummary>(okResult.Value);
        Assert.Equal(2, summary.TotalParticipants);
        Assert.Equal(1, summary.TotalBetsPlaced);
        Assert.Single(summary.PendingBettors);
        Assert.Equal("Bob", summary.PendingBettors[0].Name);
    }

    #endregion
}