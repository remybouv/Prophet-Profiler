# RÉPONSE RÉUNION - Dismas (Developer)

## ✅ Confirmé : Architecture .NET MAUI

Je maintiens mes 4 livrables (ARCHITECTURE.md, MODELS.md, DATABASE.md, SERVICES.md) en **.NET MAUI**.

---

## Réponses aux Questions Critiques

### 1. ⚠️ Architecture MAUI vs Flutter/API
**DÉCISION** : On reste sur **.NET MAUI** (mon livrable initial).

Ma structure en 3 projets reste valide :
- `ProphetProfiler.Core` (Models + Interfaces)
- `ProphetProfiler.Infrastructure` (EF Core + Services)
- `ProphetProfiler.UI` (MAUI + MVVM)

---

### 2. 🔢 Algorithme Match Score - ALIGNEMENT REYNAULD

Reynauld demande : axes extrêmes (1 ou 5) ont **plus de poids**.

**Implémentation MAUI** (à intégrer dans `MatchScoreCalculator.cs`) :

```csharp
public MatchScore CalculateScore(IReadOnlyList<Player> players, BoardGame game)
{
    var avgProfile = new PlayerProfile
    {
        Agressivity = (int)Math.Round(players.Average(p => p.Profile.Agressivity)),
        Patience = (int)Math.Round(players.Average(p => p.Profile.Patience)),
        Analysis = (int)Math.Round(players.Average(p => p.Profile.Analysis)),
        Bluff = (int)Math.Round(players.Average(p => p.Profile.Bluff))
    };
    
    // Pondération Reynauld : axes extrêmes comptent plus
    double CalculateWeightedDistance(int playerVal, int gameVal)
    {
        var distance = Math.Abs(playerVal - gameVal);
        
        // Poids selon valeur : 1 ou 5 = extrême = 1.5x | 2,3,4 = neutre = 1.0x
        var playerWeight = (playerVal == 1 || playerVal == 5) ? 1.5 : 1.0;
        var gameWeight = (gameVal == 1 || gameVal == 5) ? 1.5 : 1.0;
        
        return distance * Math.Max(playerWeight, gameWeight);
    }
    
    var axisScores = new Dictionary<GameAxis, double>
    {
        [GameAxis.Agressivity] = CalculateWeightedDistance(avgProfile.Agressivity, game.Profile.Agressivity),
        [GameAxis.Patience] = CalculateWeightedDistance(avgProfile.Patience, game.Profile.Patience),
        [GameAxis.Analysis] = CalculateWeightedDistance(avgProfile.Analysis, game.Profile.Analysis),
        [GameAxis.Bluff] = CalculateWeightedDistance(avgProfile.Bluff, game.Profile.Bluff)
    };
    
    // Score final 0-100
    var weightedAvg = axisScores.Average(a => 1.0 - (a.Value / 6.0)); // Normalisé
    var score = weightedAvg * 100;
    
    return new MatchScore
    {
        BoardGame = game,
        Score = Math.Round(score, 1),
        Quality = score switch
        {
            >= 90 => MatchQuality.Perfect,
            >= 75 => MatchQuality.Great,
            >= 60 => MatchQuality.Good,
            >= 40 => MatchQuality.Average,
            >= 25 => MatchQuality.Poor,
            _ => MatchQuality.Avoid
        },
        AxisScores = axisScores.ToDictionary(kvp => kvp.Key, kvp => 1.0 - (kvp.Value / 6.0)),
        MainConcern = axisScores.OrderByDescending(a => a.Value).First().Key.ToString()
    };
}
```

**Validé avec Reynauld** : ✓ Pondération extrêmes intégrée

---

### 3. 📦 Modèles EF Core - Validation

Les modèles sont **adaptés MAUI** (pas besoin de DTOs API complexes) :

```csharp
// Domain Models - Utilisés directement en MAUI
public class Player  // Entité EF Core + Binding MVVM
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public PlayerProfile Profile { get; set; }  // Owned Entity
    // ...
}

// Synchronisation MAUI : PropertyChanged automatique via MVVM
```

**Avantages MAUI** :
- Pas de sérialisation JSON réseau (accès direct SQLite)
- `INotifyPropertyChanged` natif pour binding XAML
- Navigation directe via `Shell` (pas de HTTP)

---

### 4. 🎨 Couverture Wireframes BALDWIN

| Wireframe Baldwin | Flux MAUI Prévu | Status |
|-------------------|-----------------|--------|
| Home/Dashboard | `MainPage.xaml` + `MainViewModel.cs` | ✅ OK |
| Liste Joueurs | `PlayersListPage.xaml` | ✅ OK |
| Profil Joueur (4 axes) | `PlayerDetailPage.xaml` + StarRating custom | ✅ OK |
| Création Session | `SessionCreatePage.xaml` avec Match Score | ✅ OK |
| Classements | `ChampionsPage.xaml` + `OraclesPage.xaml` | ✅ OK |

**🚨 Écrans à AJOUTER chez Baldwin** (manquants dans wireframes) :

1. **Catalogue Jeux** (`GamesListPage.xaml`)
   - Grid des jeux avec photos boîtes
   - FAB "Ajouter un jeu"

2. **Phase de Paris** (`BettingPage.xaml`)
   - Liste participants avec RadioButton pour prédiction
   - Compteur "X/Y ont parié"
   - **Nouveau** : Affichage points (+10, +5 bonus, -2 pénalité)

3. **Résultats Session** (`ResultsPage.xaml`)
   - Podium vainqueur
   - Liste des paris avec résultat (✓/✗) et points gagnés
   - Gestion égalités (division points)

4. **Match Preview** (`MatchPreviewPage.xaml`)
   - Comparaison visuelle radar (joueurs vs jeu)
   - Recommandation "Parfait/Bon/À éviter"

---

## 🔧 Adaptations Points Paris (Reynauld)

Système de points à intégrer dans `BetManager.cs` :

```csharp
public class BetScoringService
{
    public int CalculatePoints(Bet bet, Guid actualWinnerId)
    {
        var isCorrect = bet.PredictedWinnerId == actualWinnerId;
        var points = 0;
        
        if (isCorrect)
        {
            points += 10;  // Base
            
            // Bonus auto-gagnant (a parié sur soi et gagné)
            if (bet.BettorId == bet.PredictedWinnerId)
                points += 5;
        }
        else
        {
            // Pénalité auto-perdant (a parié sur soi et perdu)
            if (bet.BettorId == bet.PredictedWinnerId)
                points -= 2;
        }
        
        return points;
    }
    
    public Dictionary<Guid, int> ResolveSessionPoints(GameSession session)
    {
        // Gestion égalités : points divisés par nombre d'ex-aequo
        var betsByPoints = session.Bets
            .Select(b => new { Bet = b, Points = CalculatePoints(b, session.WinnerId.Value) })
            .GroupBy(x => x.Points)
            .ToList();
        
        var results = new Dictionary<Guid, int>();
        foreach (var group in betsByPoints)
        {
            var dividedPoints = group.Key / group.Count(); // Égalité = division
            foreach (var item in group)
            {
                results[item.Bet.BettorId] = dividedPoints;
            }
        }
        
        return results;
    }
}
```

---

## 🎨 Intégration Design System Baldwin

```xml
<!-- Styles MAUI à ajouter dans Colors.xaml -->
<Color x:Key="Primary">#3F51B5</Color>        <!-- Royal Indigo -->
<Color x:Key="Secondary">#FFD700</Color>      <!-- Gold -->
<Color x:Key="BackgroundDark">#121212</Color> <!-- Dark mode -->
<Color x:Key="Surface">#1E1E1E</Color>

<!-- StarRating custom (4 axes) -->
<controls:StarRating 
    Value="{Binding Profile.Agressivity}"
    Maximum="5"
    StarColor="{StaticResource Secondary}" />
```

---

## ✅ TODO Final

| Tâche | Assigné | Priorité |
|-------|---------|----------|
| Implémenter algo pondération extrêmes | Dismas | 🔴 Haute |
| Service BetScoring avec points/égalités | Dismas | 🔴 Haute |
| StarRating custom control (4 axes) | Dismas + Baldwin | 🟡 Moyenne |
| Écrans manquants wireframes | Baldwin | 🟡 Moyenne |
| Dark mode theme MAUI | Dismas | 🟢 Basse |

**Je suis prêt pour le développement.** Mon architecture MAUI couvre tous les flux. 🚀

---
*Dismas, Developer*  
*09:42 UTC*
