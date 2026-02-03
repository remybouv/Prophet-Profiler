# Prophet & Profiler - Flutter + .NET API

## 🏗️ Architecture

```
ProphetProfiler/
├── backend/                 # .NET 9 Web API
│   ├── Controllers/         # API Endpoints
│   ├── Data/               # DbContext, Migrations
│   ├── Services/           # Business logic
│   └── Models/             # Entity models
│
├── frontend/flutter_app/   # Flutter Application
│   ├── lib/
│   │   ├── src/
│   │   │   ├── data/       # Models, Repositories, API
│   │   │   ├── domain/     # Entities, UseCases
│   │   │   ├── presentation/ # UI: Blocs, Pages, Widgets
│   │   │   └── services/   # API Service
│   │   └── main.dart
│   └── pubspec.yaml
│
└── docs/                   # Documentation
```

## 🚀 Démarrage

### Backend (.NET)
```bash
cd backend
dotnet restore
dotnet ef database update
dotnet run
# API disponible sur https://localhost:5001
```

### Frontend (Flutter)
```bash
cd frontend/flutter_app
flutter pub get
flutter run
```

## 📱 Fonctionnalités MVP

- [x] Structure projet Flutter + API
- [ ] CRUD Joueurs
- [ ] CRUD Jeux
- [ ] Match Score
- [ ] Sessions de jeu
- [ ] Système de paris
- [ ] Classements

## 🎨 Design System

Voir `docs/DESIGN_SYSTEM.md` pour la palette de couleurs (Royal Indigo #1A1B3A, Gold #D4A574)
