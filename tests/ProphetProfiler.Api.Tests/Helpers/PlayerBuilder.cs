using ProphetProfiler.Api.Models;

namespace ProphetProfiler.Api.Tests.Helpers;

/// <summary>
/// Builder pour créer des joueurs avec profil pour les tests
/// </summary>
public class PlayerBuilder
{
    private Guid _id = Guid.NewGuid();
    private string _name = "TestPlayer";
    private string? _photoUrl;
    private int _aggressivity = 3;
    private int _patience = 3;
    private int _analysis = 3;
    private int _bluff = 3;

    public PlayerBuilder WithId(Guid id)
    {
        _id = id;
        return this;
    }

    public PlayerBuilder WithName(string name)
    {
        _name = name;
        return this;
    }

    public PlayerBuilder WithPhotoUrl(string? photoUrl)
    {
        _photoUrl = photoUrl;
        return this;
    }

    public PlayerBuilder WithAggressivity(int value)
    {
        _aggressivity = value;
        return this;
    }

    public PlayerBuilder WithPatience(int value)
    {
        _patience = value;
        return this;
    }

    public PlayerBuilder WithAnalysis(int value)
    {
        _analysis = value;
        return this;
    }

    public PlayerBuilder WithBluff(int value)
    {
        _bluff = value;
        return this;
    }

    public PlayerBuilder WithProfile(int aggressivity, int patience, int analysis, int bluff)
    {
        _aggressivity = aggressivity;
        _patience = patience;
        _analysis = analysis;
        _bluff = bluff;
        return this;
    }

    public Player Build()
    {
        return new Player
        {
            Id = _id,
            Name = _name,
            PhotoUrl = _photoUrl,
            Profile = new PlayerProfile
            {
                PlayerId = _id,
                Aggressivity = _aggressivity,
                Patience = _patience,
                Analysis = _analysis,
                Bluff = _bluff
            }
        };
    }

    // Joueurs prédéfinis pour les tests
    public static PlayerBuilder AggressivePlayer() => new PlayerBuilder()
        .WithName("Rambo")
        .WithProfile(5, 1, 2, 4);

    public static PlayerBuilder PatientPlayer() => new PlayerBuilder()
        .WithName("Yoda")
        .WithProfile(1, 5, 5, 3);

    public static PlayerBuilder BalancedPlayer() => new PlayerBuilder()
        .WithName("Average")
        .WithProfile(3, 3, 3, 3);

    public static PlayerBuilder AnalyticalPlayer() => new PlayerBuilder()
        .WithName("Spock")
        .WithProfile(2, 4, 5, 2);

    public static PlayerBuilder BlufferPlayer() => new PlayerBuilder()
        .WithName("PokerFace")
        .WithProfile(3, 3, 3, 5);
}
