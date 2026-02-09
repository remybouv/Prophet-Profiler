using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace ProphetProfiler.Api.Tests.Helpers;

/// <summary>
/// Factory pour créer des contextes de base de données en mémoire pour les tests
/// </summary>
public static class TestDbContextFactory
{
    public static AppDbContext Create()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        var context = new AppDbContext(options);
        context.Database.EnsureCreated();
        return context;
    }

    public static async Task<AppDbContext> CreateWithDataAsync()
    {
        var context = Create();
        
        // Ajouter des données de test
        await SeedTestDataAsync(context);
        
        return context;
    }

    private static async Task SeedTestDataAsync(AppDbContext context)
    {
        // Joueurs de test
        var alice = PlayerBuilder.AggressivePlayer().WithName("Alice").Build();
        var bob = PlayerBuilder.PatientPlayer().WithName("Bob").Build();
        var charlie = PlayerBuilder.BalancedPlayer().WithName("Charlie").Build();

        context.Players.AddRange(alice, bob, charlie);

        // Jeux de test
        var risk = BoardGameBuilder.Risk().Build();
        var chess = BoardGameBuilder.Chess().Build();
        var poker = BoardGameBuilder.Poker().Build();

        context.BoardGames.AddRange(risk, chess, poker);

        await context.SaveChangesAsync();
    }
}
