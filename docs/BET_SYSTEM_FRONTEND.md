# Documentation Système de Paris - Frontend

## Vue d'ensemble

Cette implémentation ajoute le système de paris "Qui sera le champion de ce soir ?" à l'application Flutter Prophet & Profiler.

## Architecture

### Modèles de données (`lib/src/data/models/bet_model.dart`)

```dart
enum SessionStatus { planning, betting, inProgress, completed }

class Bet                  // Un pari individuel
class BetsSummary          // Résumé des paris d'une session
class BetHistory           // Historique complet d'un joueur
class BetHistoryItem       // Élément d'historique individuel
class PlaceBetRequest      // Requête pour placer un pari
```

### Widgets UI (`lib/src/presentation/widgets/custom/`)

| Widget | Description |
|--------|-------------|
| `bet_button.dart` | Bouton "Qui sera le champion ?" avec badge X/Y |
| `bet_selection_dialog.dart` | Écran de sélection du joueur à parier |
| `bet_results_dialog.dart` | Affichage des résultats post-session |
| `bet_history_list.dart` | Historique des paris dans le profil |

### Pages (`lib/src/presentation/pages/`)

| Page | Description |
|------|-------------|
| `session_page.dart` | Page de session avec intégration des paris |

### Services (`lib/src/services/api_service.dart`)

```dart
Future<BetsSummary> getBetsSummary(String sessionId)
Future<Bet> placeBet(String sessionId, String bettorId, String predictedWinnerId)
Future<BetHistory> getPlayerBetHistory(String playerId)
```

### BLoC (`lib/src/presentation/blocs/bets_bloc.dart`)

Gestion d'état pour les paris avec ChangeNotifier.

## Fonctionnalités

### 1. Bouton de pari

- Badge affichant "X/Y paris"
- Visible uniquement en statut "Betting"
- Devient "Voir les paris" après avoir parié
- Désactivé si moins de 2 joueurs

### 2. Sélection du pari

- Liste des participants avec photos/noms
- Auto-pari interdit (grisé/désactivé)
- Slider de sélection
- Confirmation avant placement

### 3. Confirmation

- Récapitulatif du pari
- Message "Vous ne pourrez plus modifier ce pari"
- Boutons Confirmer/Annuler

### 4. Résultats

- Gagnant affiché en grand
- Liste visible : qui a parié sur qui
- Points gagnés (+10) / perdus (-5)
- Stats globales

### 5. Historique

- Liste des paris passés
- Résultats gagné/perdu/pending
- Stats : total, taux de réussite

## Design System

Le système utilise le thème existant :

- **Royal Indigo** `#1A1B3A` - Fonds
- **Gold** `#D4A574` - Accents, boutons
- **Teal** `#2D6B6B` - Succès, points gagnés
- **Rust** `#B85450` - Erreurs, points perdus

## Intégration API

### Endpoints utilisés

```
GET  /api/sessions/{id}/bets/summary
POST /api/sessions/{id}/bets
GET  /api/players/{id}/bets/history
```

## Utilisation

### Afficher le bouton de pari

```dart
BetButton(
  betsCount: 2,
  totalParticipants: 4,
  hasUserBet: false,
  isEnabled: true,
  onPressed: _showBetSelection,
)
```

### Ouvrir la sélection

```dart
BetSelectionDialog.show(
  context: context,
  participants: players,
  currentPlayer: currentPlayer,
  onPlayerSelected: (player) => _placeBet(player),
);
```

### Voir les résultats

```dart
BetResultsDialog.show(
  context: context,
  betsSummary: summary,
  currentPlayerId: currentPlayer.id,
);
```

### Afficher l'historique

```dart
BetHistorySection(betHistory: history)
```

## Navigation

La HomePage a été mise à jour avec :
- Nouveau design du header
- Bouton "Session active" vers SessionPage
- Thème Royal Indigo + Gold

## Fichiers créés/modifiés

### Nouveaux fichiers (8)
- `bet_model.dart` + `bet_model.g.dart`
- `bets_bloc.dart`
- `session_page.dart`
- `bet_button.dart`
- `bet_selection_dialog.dart`
- `bet_results_dialog.dart`
- `bet_history_list.dart`

### Fichiers modifiés (4)
- `api_service.dart` - Ajout méthodes paris
- `home_page.dart` - Nouveau design + navigation
- `pages.dart` - Export SessionPage
- `widgets.dart` - Export widgets paris
