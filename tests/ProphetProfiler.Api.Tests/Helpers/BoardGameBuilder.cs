using ProphetProfiler.Api.Models;

namespace ProphetProfiler.Api.Tests.Helpers;

/// <summary>
/// Builder pour créer des jeux de société avec profil pour les tests
/// </summary>
public class BoardGameBuilder
{
    private Guid _id = Guid.NewGuid();
    private string _name = "TestGame";
    private string? _description;
    private string? _photoUrl;
    private int _minPlayers = 2;
    private int _maxPlayers = 4;
    private int? _averageDuration = 60;
    private int _aggressivity = 3;
    private int _patience = 3;
    private int _analysis = 3;
    private int _bluff = 3;

    public BoardGameBuilder WithId(Guid id)
    {
        _id = id;
        return this;
    }

    public BoardGameBuilder WithName(string name)
    {
        _name = name;
        return this;
    }

    public BoardGameBuilder WithPlayerCount(int min, int max)
    {
        _minPlayers = min;
        _maxPlayers = max;
        return this;
    }

    public BoardGameBuilder WithDuration(int? duration)
    {
        _averageDuration = duration;
        return this;
    }

    public BoardGameBuilder WithProfile(int aggressivity, int patience, int analysis, int bluff)
    {
        _aggressivity = aggressivity;
        _patience = patience;
        _analysis = analysis;
        _bluff = bluff;
        return this;
    }

    public BoardGame Build()
    {
        return new BoardGame
        {
            Id = _id,
            Name = _name,
            Description = _description,
            PhotoUrl = _photoUrl,
            MinPlayers = _minPlayers,
            MaxPlayers = _maxPlayers,
            AverageDuration = _averageDuration,
            Profile = new GameProfile
            {
                BoardGameId = _id,
                Aggressivity = _aggressivity,
                Patience = _patience,
                Analysis = _analysis,
                Bluff = _bluff
            }
        };
    }

    // Jeux prédéfinis pour les tests
    public static BoardGameBuilder Risk() => new BoardGameBuilder()
        .WithName("Risk")
        .WithPlayerCount(2, 6)
        .WithProfile(5, 2, 3, 2);

    public static BoardGameBuilder Chess() => new BoardGameBuilder()
        .WithName("Chess")
        .WithPlayerCount(2, 2)
        .WithProfile(2, 5, 5, 1);

    public static BoardGameBuilder Poker() => new BoardGameBuilder()
        .WithName("Poker")
        .WithPlayerCount(2, 10)
        .WithProfile(4, 4, 4, 5);

    public static BoardGameBuilder Catan() => new BoardGameBuilder()
        .WithName("Catan")
        .WithPlayerCount(3, 4)
        .WithProfile(2, 4, 4, 2);

    public static BoardGameBuilder Diplomacy() => new BoardGameBuilder()
        .WithName("Diplomacy")
        .WithPlayerCount(2, 7)
        .WithProfile(4, 5, 5, 5);
}
