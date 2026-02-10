using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using ProphetProfiler.Api.Controllers;
using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Models;
using ProphetProfiler.Api.Models.Dtos;
using ProphetProfiler.Api.Services;
using Xunit;

namespace ProphetProfiler.Api.Tests.Controllers;

/// <summary>
/// Tests d'intégration simples pour BetCreationController
/// Sans dépendance à Moq - utilise EF Core InMemory
/// </summary>
public class BetCreationControllerIntegrationTests : IDisposable
{
    private readonly AppDbContext _context;
    private readonly BetCreationController _controller;

    public BetCreationControllerIntegrationTests()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new AppDbContext(options);
        
        // Utiliser les vraies implémentations des services
        var betManager = new BetManager(_context);
        var logger = LoggerFactory.Create(_ => { }).CreateLogger<BetCreationController>();
        
        _controller = new BetCreationController(_context, betManager, logger);

        SeedTestData();
    }

    private void SeedTestData()
    {
        var game = new BoardGame { Id = Guid.NewGuid(), Name = "Test Game" };
        var player1 = new Player { Id = Guid.NewGuid(), Name = "Player 1" };
        var player2 = new Player { Id = Guid.NewGuid(), Name = "Player 2" };

        _context.BoardGames.Add(game);
        _context.Players.AddRange(player1, player2);
        _context.SaveChanges();
    }

    [Fact]
    public async Task GetAvailablePlayers_ReturnsAllPlayers()
    {
        // Act
        var result = await _controller.GetAvailablePlayers();

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var response = Assert.IsType<AvailablePlayersResponse>(okResult.Value);
        Assert.Equal(2, response.TotalCount);
    }

    [Fact]
    public async Task CreateBetSession_WithValidData_ReturnsCreatedSession()
    {
        // Arrange
        var game = _context.BoardGames.First();
        var players = _context.Players.ToList();

        var request = new CreateBetSessionRequest(
            game.Id,
            players.Select(p => p.Id).ToList(),
            DateTime.Now,
            "Test Location"
        );

        // Act
        var result = await _controller.CreateBetSession(request);

        // Assert
        var createdResult = Assert.IsType<CreatedAtActionResult>(result.Result);
        var session = Assert.IsType<GameSession>(createdResult.Value);
        Assert.Equal(SessionStatus.Betting, session.Status);
        Assert.Equal(2, session.Participants.Count);
    }

    [Fact]
    public async Task CreateBetSession_WithLessThan2Players_ReturnsBadRequest()
    {
        // Arrange
        var game = _context.BoardGames.First();
        var request = new CreateBetSessionRequest(
            game.Id,
            new List<Guid> { Guid.NewGuid() },
            DateTime.Now,
            null
        );

        // Act
        var result = await _controller.CreateBetSession(request);

        // Assert
        Assert.IsType<BadRequestObjectResult>(result.Result);
    }

    [Fact]
    public async Task CreateBetSession_WithInvalidGame_ReturnsNotFound()
    {
        // Arrange
        var request = new CreateBetSessionRequest(
            Guid.NewGuid(),
            _context.Players.Select(p => p.Id).ToList(),
            DateTime.Now,
            null
        );

        // Act
        var result = await _controller.CreateBetSession(request);

        // Assert
        Assert.IsType<NotFoundObjectResult>(result.Result);
    }

    [Fact]
    public async Task GetSessionDetails_ReturnsCorrectDetails()
    {
        // Arrange - Create a session first
        var session = await CreateTestSession();

        // Act
        var result = await _controller.GetSessionDetails(session.Id);

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var details = Assert.IsType<SessionActiveDetails>(okResult.Value);
        Assert.Equal(session.Id, details.SessionId);
        Assert.Equal(2, details.Participants.Count);
    }

    private async Task<GameSession> CreateTestSession()
    {
        var game = _context.BoardGames.First();
        var players = _context.Players.ToList();

        var session = new GameSession
        {
            BoardGameId = game.Id,
            Status = SessionStatus.Betting,
            Date = DateTime.UtcNow
        };

        foreach (var player in players)
        {
            session.Participants.Add(player);
        }

        _context.GameSessions.Add(session);
        await _context.SaveChangesAsync();

        return session;
    }

    public void Dispose()
    {
        _context.Dispose();
    }
}
