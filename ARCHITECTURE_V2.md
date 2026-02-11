# Prophet-Profiler V2 - Architecture Technique

## Résumé de l'Analyse

### Architecture Existante

**Backend (.NET 9 Web API)**
- EF Core + SQLite
- Models: `Player`, `PlayerProfile`, `BoardGame`, `GameSession`, `Bet`, `PlayerStats`
- Services: `BetManager`, `RankingService`, `MatchScoreCalculator`
- Controllers: `Players`, `Sessions`, `Games`, `Rankings`

**Frontend (Flutter)**
- Architecture BLoC pattern
- Thème: Premium dark (Royal Indigo + Gold)
- Pages existantes: Home, Players, Games, Rankings, Session

### Flux de Données Actuel

```
1. Création Session → POST /api/sessions (avec BoardGameId + PlayerIds)
2. Démarrage Paris → POST /api/sessions/{id}/transition (Created→Betting)
3. Placement Pari → POST /api/sessions/{id}/bets (BettorId + PredictedWinnerId)
4. Clôture Session → POST /api/sessions/{id}/complete (WinnerId)
```

---

## Nouvelle Architecture V2

### 1. Nouveaux Endpoints API

#### Sessions Controller (Extensions)

```csharp
// GET /api/sessions/active
// Retourne la session en cours (Betting ou Playing) ou null

// GET /api/sessions/{id}/bets/detailed  
// Retourne détails complets des paris pour la page Session Active

// POST /api/sessions/{id}/winner
// Définit le gagnant sans clôturer (nouvelle étape intermédiaire)
```

#### Nouveau BetCreationController

```csharp
// POST /api/bet-sessions/create
// Crée une session avec participants en une seule étape

// GET /api/bet-sessions/available-players
// Liste des joueurs disponibles pour une nouvelle session
```

### 2. Nouveaux DTOs

```csharp
// Pour la page Création Paris
public record CreateBetSessionRequest(
    Guid BoardGameId,
    List<Guid> PlayerIds,
    DateTime? Date,
    string? Location
);

// Pour la page Session Active
public record SessionActiveDetails
{
    public Guid SessionId { get; init; }
    public string BoardGameName { get; init; } = string.Empty;
    public SessionStatus Status { get; init; }
    public List<ParticipantBetInfo> Participants { get; init; } = new();
    public List<BetDetail> Bets { get; init; } = new();
    public Guid? CurrentWinnerId { get; init; }
    public int TotalPointsInPlay { get; init; }
}

public record ParticipantBetInfo
{
    public Guid PlayerId { get; init; }
    public string Name { get; init; } = string.Empty;
    public string? PhotoUrl { get; init; }
    public bool HasPlacedBet { get; init; }
    public Guid? BetOnPlayerId { get; init; }
    public int CurrentScore { get; init; }
}

// Pour la sélection du gagnant
public record SetWinnerRequest(Guid WinnerId);
public record ResolveBetsResponse(
    Guid WinnerId,
    string WinnerName,
    List<BetResolution> Resolutions
);

public record BetResolution
{
    public Guid BettorId { get; init; }
    public string BettorName { get; init; } = string.Empty;
    public bool IsCorrect { get; init; }
    public int PointsEarned { get; init; }
}
```

### 3. Modifications Base de Données

**Aucune modification requise** - Le schéma existant supporte déjà:
- Les sessions avec statuts (Created, Betting, Playing, Completed, Cancelled)
- Les paris avec leurs relations (Bettor, PredictedWinner)
- Les points gagnés sur chaque pari

**Contraintes existantes déjà en place:**
- Auto-pari interdit (validation dans BetManager)
- Un seul pari par participant par session

### 4. Workflow Nouvelles Pages

#### Page Création Paris (BetCreationPage)

```
1. Chargement: GET /api/bet-sessions/available-players
                GET /api/games

2. Sélection:   □ Dropdown Jeu (BoardGame)
                □ Multi-sélection Joueurs (min 2)
                □ Date/Location (optionnel)

3. Validation:  → POST /api/bet-sessions/create
                → Navigation Session Active
```

#### Page Session Active (ActiveSessionPage)

```
1. Chargement: GET /api/sessions/{id}/bets/detailed

2. Affichage:  ─ Header (Jeu, Date, Statut)
               ─ Liste Participants avec statut pari
               ─ Section Paris placés (si Betting/Playing)

3. Actions par statut:
   - Betting:    □ Bouton "Placer mon pari" → Dialog dropdown
   - Playing:    □ Dropdown "Sélectionner gagnant" → POST winner
   - Completed:  □ Affichage résultats + points attribués
```

#### Homepage (Modifications)

```
┌─────────────────────────────────────────┐
│  Prophet & Profiler                     │
├─────────────────────────────────────────┤
│                                         │
│  [🎲 Session active]  ←── Enabled si    │
│                          session existe │
│                                         │
│  [➕ Nouvelle Session] ←── Toujours     │
│                          actif          │
│                                         │
│  [👥 Joueurs]                           │
│                                         │
└─────────────────────────────────────────┘
```

### 5. Flutter - Structure Widgets

```
lib/src/presentation/pages/
├── bet_creation_page.dart          # NOUVEAU
│   └── Sections:
│       ├── GameSelector (dropdown)
│       ├── PlayerMultiSelect (grid/liste)
│       └── CreateButton
│
├── active_session_page.dart        # NOUVEAU  
│   └── Sections:
│       ├── SessionHeader
│       ├── ParticipantsList
│       ├── BetsSummary
│       ├── WinnerSelector (dropdown conditionnel)
│       └── ResultsPanel
│
└── home_page.dart                  # MODIFIÉ
    └── Conditional buttons based on active session

lib/src/presentation/blocs/
├── bet_creation_bloc.dart          # NOUVEAU
└── active_session_bloc.dart        # NOUVEAU
```

### 6. Service API Extensions

```dart
class ApiService {
  // NOUVEAU: Sessions
  Future<Session?> getActiveSession();
  Future<SessionActiveDetails> getSessionActiveDetails(String sessionId);
  Future<Session> createBetSession(CreateBetSessionRequest request);
  
  // NOUVEAU: Winner selection
  Future<ResolveBetsResponse> setSessionWinner(String sessionId, String winnerId);
  
  // EXISTANT (déjà implémenté)
  Future<Bet> placeBet(String sessionId, String bettorId, String predictedWinnerId);
  Future<BetsSummary> getBetsSummary(String sessionId);
}
```

---

## Implémentation Phase 1: Backend

1. ✅ Créer `BetCreationController`
2. ✅ Étendre `SessionsController` avec endpoints manquants
3. ✅ Créer DTOs dans `Models/Dtos/`
4. ✅ Mettre à jour `IBetManager` et `BetManager` si nécessaire

## Implémentation Phase 2: Frontend

1. Créer modèles Dart pour nouveaux DTOs
2. Étendre `ApiService`
3. Créer BLoCs (BetCreationBloc, ActiveSessionBloc)
4. Créer pages UI
5. Modifier HomePage avec boutons conditionnels

## Notes

- **Attente Baldwin**: UI finale dépend des wireframes
- **Tests**: Tests unitaires backend + tests widget Flutter
- **Design**: Respecter palette Royal Indigo (#1a1a4e) + Gold (#d4af37)
