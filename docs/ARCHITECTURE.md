# ARCHITECTURE.md - Prophet & Profiler

## Nouvelle Stack

| Couche | Technologie | Rôle |
|--------|-------------|------|
| **Backend** | .NET 8 Web API | Logique métier, données, API REST |
| **Base de données** | SQLite + EF Core | Stockage local (fichier) |
| **Frontend** | Flutter (Dart) | UI mobile cross-platform |
| **Communication** | HTTP/REST + JSON | Échange de données |

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              FRONTEND (FLUTTER)                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │    UI       │  │   BLOC      │  │  Repository │  │   Services API      │ │
│  │   (Widget)  │◄─┤  (State)    │◄─┤   (Data)    │◄─┤  (HTTP Client)      │ │
│  └─────────────┘  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘ │
│                          │                │                    │            │
│                          └────────────────┴────────────────────┘            │
│                                               │                             │
└───────────────────────────────────────────────┼─────────────────────────────┘
                                                │ HTTP/REST
                                                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              BACKEND (.NET API)                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                         CONTROLLERS (API)                                ││
│  │  PlayersController │ GamesController │ SessionsController │ Stats       ││
│  └───────────────────────────────┬─────────────────────────────────────────┘│
│                                  │                                          │
│                                  ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                      APPLICATION LAYER                                   ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────────┐ ││
│  │  │   DTOs      │  │   Services  │  │  Interfaces │  │  Validators    │ ││
│  │  │  (Contracts)│  │   (Métier)  │  │             │  │   (Fluent)     │ ││
│  │  └─────────────┘  └──────┬──────┘  └─────────────┘  └────────────────┘ ││
│  └──────────────────────────┼──────────────────────────────────────────────┘│
│                             │                                               │
│                             ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                        DATA LAYER                                        ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────────┐ ││
│  │  │   Domain    │  │   EF Core   │  │ Repositories│  │   Migrations   │ ││
│  │  │   Models    │  │   DbContext │  │             │  │                │ ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └────────────────┘ ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                   │                                         │
│                                   ▼                                         │
│                         ┌─────────────────┐                                 │
│                         │     SQLite      │                                 │
│                         │   prophet.db    │                                 │
│                         └─────────────────┘                                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Structure des Projets

### Backend (.NET Web API)

```
ProphetProfiler.Api/
├── Program.cs                      # Bootstrap, DI, middleware
├── appsettings.json
├── Controllers/                    # API Endpoints
│   ├── PlayersController.cs        # GET/POST/PUT/DELETE /api/players
│   ├── BoardGamesController.cs     # /api/games
│   ├── SessionsController.cs       # /api/sessions
│   └── StatsController.cs          # /api/stats (rankings)
│
├── Application/                    # Couche application
│   ├── DTOs/                       # Contrats API
│   │   ├── PlayerDtos.cs
│   │   ├── BoardGameDtos.cs
│   │   ├── SessionDtos.cs
│   │   └── RankingDtos.cs
│   ├── Services/                   # Implémentations
│   │   ├── MatchScoreCalculator.cs
│   │   ├── BetManager.cs
│   │   └── RankingService.cs
│   └── Validators/                 # Validation Fluent
│       └── PlayerValidator.cs
│
├── Domain/                         # Core (peut être nuget partagé)
│   ├── Models/                     # Entités pures
│   │   ├── Player.cs
│   │   ├── BoardGame.cs
│   │   ├── GameSession.cs
│   │   ├── Bet.cs
│   │   └── PlayerStats.cs
│   └── Interfaces/
│       ├── IMatchScoreCalculator.cs
│       ├── IBetManager.cs
│       └── IRankingService.cs
│
└── Infrastructure/                 # Accès données
    ├── Data/
    │   ├── AppDbContext.cs
    │   └── Migrations/
    └── Repositories/
        └── (optionnel - peut utiliser DbContext direct)
```

### Frontend (Flutter)

```
prophet_profiler/
├── lib/
│   ├── main.dart
│   ├── app.dart                    # MaterialApp, routing
│   │
│   ├── data/                       # Couche données
│   │   ├── models/                 # Models Dart (miroir DTOs API)
│   │   │   ├── player.dart
│   │   │   ├── board_game.dart
│   │   │   ├── game_session.dart
│   │   │   └── bet.dart
│   │   ├── repositories/           # Abstraction accès données
│   │   │   ├── player_repository.dart
│   │   │   └── session_repository.dart
│   │   └── services/               # HTTP Client
│   │       ├── api_client.dart
│   │       └── api_endpoints.dart
│   │
│   ├── domain/                     # Logique métier (light)
│   │   └── usecases/               # Cas d'usage si complexe
│   │
│   ├── presentation/               # UI + State Management
│   │   ├── blocs/                  # BLOC pattern
│   │   │   ├── players_bloc.dart
│   │   │   ├── sessions_bloc.dart
│   │   │   └── match_bloc.dart
│   │   ├── pages/                  # Écrans
│   │   │   ├── players_list_page.dart
│   │   │   ├── session_create_page.dart
│   │   │   ├── betting_page.dart
│   │   │   └── rankings_page.dart
│   │   └── widgets/                # Composants réutilisables
│   │       ├── player_card.dart
│   │       ├── game_selector.dart
│   │       └── axis_rating.dart
│   │
│   └── core/                       # Utilitaires
│       ├── constants.dart
│       ├── theme.dart
│       └── extensions.dart
│
├── pubspec.yaml
└── android/ios/web/                # Platforms
```

---

## API REST Design

### Endpoints

```yaml
# Players
GET    /api/players                 # Liste tous les joueurs
GET    /api/players/{id}            # Détail joueur
POST   /api/players                 # Créer joueur
PUT    /api/players/{id}            # Modifier joueur
DELETE /api/players/{id}            # Supprimer joueur
GET    /api/players/{id}/stats      # Stats joueur

# Board Games
GET    /api/games                   # Liste jeux
GET    /api/games/{id}
POST   /api/games
PUT    /api/games/{id}
DELETE /api/games/{id}

# Sessions (core feature)
GET    /api/sessions                # Liste sessions
GET    /api/sessions/{id}           # Détail avec participants, paris
POST   /api/sessions                # Créer session
POST   /api/sessions/{id}/start     # Débuter phase paris
POST   /api/sessions/{id}/bets      # Placer un pari (body: predictedWinnerId)
POST   /api/sessions/{id}/complete  # Terminer session (body: winnerId)
DELETE /api/sessions/{id}

# Match Score
POST   /api/match/best              # Trouver meilleur jeu pour groupe
       Body: { "playerIds": [guid, guid] }
       
POST   /api/match/rank              # Classer tous les jeux
       Body: { "playerIds": [guid, guid] }

# Rankings
GET    /api/rankings/champions      # Classement victoires
GET    /api/rankings/champions?gameId={id}  # Par jeu
GET    /api/rankings/oracles        # Classement prédictions
```

### Exemples de Requêtes/Réponses

```http
# Créer un joueur
POST /api/players
Content-Type: application/json

{
  "name": "Alice",
  "profile": {
    "agressivity": 4,
    "patience": 2,
    "analysis": 5,
    "bluff": 3
  }
}

# Réponse 201
{
  "id": "a1b2c3d4...",
  "name": "Alice",
  "profile": { ... },
  "createdAt": "2024-02-03T10:00:00Z"
}
```

```http
# Matching
POST /api/match/best
Content-Type: application/json

{
  "playerIds": ["guid1", "guid2", "guid3"]
}

# Réponse 200
{
  "boardGame": {
    "id": "game1",
    "name": "Wingspan",
    "profile": { ... }
  },
  "score": 87.5,
  "quality": "great",
  "recommendation": "✨ Excellent choix",
  "axisScores": {
    "agressivity": 0.9,
    "patience": 0.85,
    "analysis": 0.95,
    "bluff": 0.8
  },
  "mainConcern": null
}
```

---

## Flux de Données Flutter

### Architecture BLOC

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│    Event     │───►│     BLOC     │───►│    State     │───►│     UI       │
│ (User action)│    │  (Business)  │    │   (Data)     │    │  (Builder)   │
└──────────────┘    └──────┬───────┘    └──────────────┘    └──────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  Repository  │
                    │              │
                    │ • Call API   │
                    │ • Cache data │
                    │ • Handle err │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   API Client │
                    │   (Dio)      │
                    └──────────────┘
```

### Exemple : Création Session

```dart
// Event
class CreateSession extends SessionEvent {
  final List<String> playerIds;
  final String boardGameId;
  CreateSession(this.playerIds, this.boardGameId);
}

// BLOC
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final SessionRepository _repo;
  
  SessionBloc(this._repo) : super(SessionInitial()) {
    on<CreateSession>((event, emit) async {
      emit(SessionLoading());
      try {
        final session = await _repo.createSession(
          playerIds: event.playerIds,
          boardGameId: event.boardGameId,
        );
        emit(SessionCreated(session));
      } catch (e) {
        emit(SessionError(e.toString()));
      }
    });
  }
}

// UI
BlocBuilder<SessionBloc, SessionState>(
  builder: (context, state) {
    if (state is SessionLoading) return CircularProgressIndicator();
    if (state is SessionCreated) return SessionDetailView(state.session);
    return CreateSessionForm();
  },
)
```

---

## Communication Backend ↔ Frontend

### Dio (Flutter HTTP Client)

```dart
// lib/data/services/api_client.dart
class ApiClient {
  final Dio _dio;
  
  ApiClient({String baseUrl = 'http://localhost:5000/api'}) 
    : _dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 3),
        headers: {'Content-Type': 'application/json'},
      )) {
    _dio.interceptors.add(LogInterceptor());
  }
  
  Future<T> get<T>(String path, {Map<String, dynamic>? query}) async {
    final response = await _dio.get(path, queryParameters: query);
    return response.data as T;
  }
  
  Future<T> post<T>(String path, {dynamic data}) async {
    final response = await _dio.post(path, data: data);
    return response.data as T;
  }
}
```

### Gestion Offline (Future V2)

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   Flutter    │◄───────►│  Local DB    │         │  Backend API │
│    App       │  Sync   │   (SQLite)   │◄───────►│   REST       │
└──────────────┘         └──────────────┘         └──────────────┘

V1: Direct API calls (online only)
V2: Drift/Floor local DB + sync
```

---

## Sécurité & Configuration

### Backend

```csharp
// CORS pour Flutter web/mobile
builder.Services.AddCors(options =>
{
    options.AddPolicy("Flutter", policy =>
    {
        policy.WithOrigins(
                "http://localhost:8080",    // Flutter web dev
                "http://10.0.2.2:5000")     // Android emulator
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// Compression réponse
builder.Services.AddResponseCompression();

// Global exception handler
app.UseExceptionHandler(errorApp => { /* ... */ });
```

### Flutter

```dart
// Environnements
class ApiConfig {
  static String get baseUrl {
    if (kDebugMode) {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
      if (Platform.isIOS) return 'http://localhost:5000/api';
      return 'http://localhost:5000/api';
    }
    return 'https://api.profiler.app/api';
  }
}
```

---

## Déploiement Dev

```bash
# Backend
> cd ProphetProfiler.Api
> dotnet run
# API disponible sur http://localhost:5000

# Frontend (autre terminal)
> cd prophet_profiler
> flutter run
# Connecté automatiquement à l'API
```

---

## Évolutivité

| Feature | Changement |
|---------|-----------|
| Multi-device sync | Ajout SignalR (WebSocket) pour temps réel |
| Auth utilisateurs | JWT + Identity |
| Cloud | Remplacer SQLite par PostgreSQL sur serveur |
| Desktop | Flutter Desktop Windows/Mac/Linux |
