using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using ProphetProfiler.Api.Controllers;
using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Models;
using ProphetProfiler.Api.Models.Dtos;
using Xunit;

namespace ProphetProfiler.Api.Tests.Controllers;

/// <summary>
/// Tests d'intégration simples pour HomepageController
/// </summary>
public class HomepageControllerIntegrationTests : IDisposable
{
    private readonly AppDbContext _context;
    private readonly HomepageController _controller;

    public HomepageControllerIntegrationTests()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new AppDbContext(options);
        var logger = LoggerFactory.Create(_ => { }).CreateLogger<HomepageController>();
        _controller = new HomepageController(_context, logger);

        SeedTestData();
    }

    private void SeedTestData()
    {
        // Games
        var game1 = new BoardGame { Id = Guid.NewGuid(), Name = "Game 1" };
        var game2 = new BoardGame { Id = Guid.NewGuid(), Name = "Game 2" };
        _context.BoardGames.AddRange(game1, game2);

        // Players
        var player1 = new Player { Id = Guid.NewGuid(), Name = "Player 1" };
        var player2 = new Player { Id = Guid.NewGuid(), Name = "Player 2" };
        var player3 = new Player { Id = Guid.NewGuid(), Name = "Player 3" };
        _context.Players.AddRange(player1, player2, player3);

        // Sessions
        var activeSession = new GameSession
        {
            Id = Guid.NewGuid(),
            BoardGameId = game1.Id,
            Status = SessionStatus.Betting,
            Date = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow
        };
        activeSession.Participants.Add(player1);
        activeSession.Participants.Add(player2);

        var completedSession = new GameSession
        {
            Id = Guid.NewGuid(),
            BoardGameId = game2.Id,
            Status = SessionStatus.Completed,
            Date = DateTime.UtcNow.AddDays(-1),
            WinnerId = player1.Id,
            CreatedAt = DateTime.UtcNow.AddDays(-1)
        };

        _context.GameSessions.AddRange(activeSession, completedSession);
        _context.SaveChanges();
    }

    [Fact]
    public async Task GetHomepageData_ReturnsCorrectData()
    {
        // Act
        var result = await _controller.GetHomepageData();

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var response = Assert.IsType<HomepageDataResponse>(okResult.Value);

        Assert.True(response.ActiveSession?.HasActiveSession);
        Assert.Equal(3, response.TotalPlayers);
        Assert.Equal(2, response.TotalGames);
        Assert.Equal(2, response.RecentSessions.Count);
    }

    [Fact]
    public async Task GetHomepageData_WithNoActiveSession_ReturnsNullSession()
    {
        // Arrange - Remove active session
        var activeSession = _context.GameSessions.First(s => s.Status == SessionStatus.Betting);
        activeSession.Status = SessionStatus.Completed;
        await _context.SaveChangesAsync();

        // Act
        var result = await _controller.GetHomepageData();

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var response = Assert.IsType<HomepageDataResponse>(okResult.Value);

        Assert.Null(response.ActiveSession);
    }

    [Fact]
    public async Task HasActiveSession_WithActiveSession_ReturnsOk()
    {
        // Act
        var result = await _controller.HasActiveSession();

        // Assert
        Assert.IsType<OkObjectResult>(result.Result);
    }

    [Fact]
    public async Task GetQuickStats_ReturnsOk()
    {
        // Act
        var result = await _controller.GetQuickStats();

        // Assert
        Assert.IsType<OkObjectResult>(result.Result);
    }

    public void Dispose()
    {
        _context.Dispose();
    }
}
