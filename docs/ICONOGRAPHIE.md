# ICONOGRAPHIE.md - Prophet & Profiler

## Bibliothèque Flutter

### Option 1: Material Icons (intégré)
**Par défaut dans Flutter** - Aucun package nécessaire
```dart
import 'package:flutter/material.dart';

Icon(Icons.home)
Icon(Icons.people)
```

### Option 2: Material Symbols (recommandé)
Package: `material_symbols_icons`
```dart
import 'package:material_symbols_icons/material_symbols_icons.dart';

Icon(Symbols.home)
Icon(Symbols.group)
```

### Option 3: Phosphor Flutter
Package: `phosphor_flutter`
```dart
import 'package:phosphor_flutter/phosphor_flutter.dart';

Icon(PhosphorIcons.house())
Icon(PhosphorIcons.users())
```

**Taille standard**: 24px (`size: 24`)
**Variantes**: `outlined`, `rounded`, `sharp` (Material) ou `regular`, `bold`, `fill` (Phosphor)

---
## Correspondances Flutter (Material Icons)

| Usage | Material Icon | Code Flutter |
|-------|---------------|--------------|
| **Accueil** | `Icons.home` / `Icons.home_outlined` | `Icon(Icons.home)` |
| **Joueurs** | `Icons.people` / `Icons.people_outline` | `Icon(Icons.people)` |
| **Jeu** | `Icons.casino` / `Icons.sports_esports` | `Icon(Icons.casino)` |
| **Session** | `Icons.sports_esports` / `Icons.videogame_asset` | `Icon(Icons.sports_esports)` |
| **Classements** | `Icons.emoji_events` / `Icons.military_tech` | `Icon(Icons.emoji_events)` |
| **Ajouter** | `Icons.add` / `Icons.add_circle` | `Icon(Icons.add)` |
| **Fermer** | `Icons.close` / `Icons.clear` | `Icon(Icons.close)` |
| **Retour** | `Icons.arrow_back` | `Icon(Icons.arrow_back)` |
| **Suivant** | `Icons.arrow_forward` | `Icon(Icons.arrow_forward)` |
| **Valider** | `Icons.check` / `Icons.check_circle` | `Icon(Icons.check)` |
| **Éditer** | `Icons.edit` / `Icons.mode_edit` | `Icon(Icons.edit)` |
| **Supprimer** | `Icons.delete` / `Icons.delete_outline` | `Icon(Icons.delete)` |
| **Recherche** | `Icons.search` | `Icon(Icons.search)` |
| **Paramètres** | `Icons.settings` | `Icon(Icons.settings)` |
| **Plus d'options** | `Icons.more_vert` | `Icon(Icons.more_vert)` |
| **Caméra** | `Icons.camera_alt` / `Icons.photo_camera` | `Icon(Icons.camera_alt)` |
| **Image** | `Icons.image` / `Icons.photo` | `Icon(Icons.image)` |
| **Profil** | `Icons.person` / `Icons.account_circle` | `Icon(Icons.person)` |
| **Étoile vide** | `Icons.star_border` | `Icon(Icons.star_border)` |
| **Étoile pleine** | `Icons.star` / `Icons.star_rate` | `Icon(Icons.star)` |
| **Calendrier** | `Icons.calendar_today` | `Icon(Icons.calendar_today)` |
| **Lieu** | `Icons.location_on` / `Icons.place` | `Icon(Icons.location_on)` |
| **Portefeuille** | `Icons.account_balance_wallet` | `Icon(Icons.account_balance_wallet)` |
| **Cible** | `Icons.track_changes` / `Icons.adjust` | `Icon(Icons.track_changes)` |
| **Verrouiller** | `Icons.lock` / `Icons.lock_outline` | `Icon(Icons.lock)` |
| **Déverrouiller** | `Icons.lock_open` | `Icon(Icons.lock_open)` |
| **Chronomètre** | `Icons.timer` / `Icons.hourglass_empty` | `Icon(Icons.timer)` |
| **Drapeau** | `Icons.flag` / `Icons.outlined_flag` | `Icon(Icons.flag)` |
| **Trophée** | `Icons.emoji_events` | `Icon(Icons.emoji_events)` |
| **Médaille** | `Icons.workspace_premium` | `Icon(Icons.workspace_premium)` |
| **Couronne** | `Icons.stars` (fallback) | `Icon(Icons.stars)` |
| **Œil/Oracle** | `Icons.visibility` / `Icons.remove_red_eye` | `Icon(Icons.visibility)` |
| **Flamme** | `Icons.local_fire_department` | `Icon(Icons.local_fire_department)` |
| **Tendance haut** | `Icons.trending_up` | `Icon(Icons.trending_up)` |
| **Tendance bas** | `Icons.trending_down` | `Icon(Icons.trending_down)` |
| **Notification** | `Icons.notifications` | `Icon(Icons.notifications)` |
| **Aide** | `Icons.help` / `Icons.help_outline` | `Icon(Icons.help_outline)` |
| **Information** | `Icons.info` / `Icons.info_outline` | `Icon(Icons.info_outline)` |
| **Alerte** | `Icons.warning` / `Icons.error_outline` | `Icon(Icons.warning)` |
| **Rafraîchir** | `Icons.refresh` | `Icon(Icons.refresh)` |
| **Boîte** | `Icons.inventory_2` / `Icons.inventory` | `Icon(Icons.inventory_2)` |
| **Graphique** | `Icons.bar_chart` / `Icons.insert_chart` | `Icon(Icons.bar_chart)` |
| **Pouce haut** | `Icons.thumb_up` / `Icons.thumb_up_off_alt` | `Icon(Icons.thumb_up)` |
| **Pouce bas** | `Icons.thumb_down` / `Icons.thumb_down_off_alt` | `Icon(Icons.thumb_down)` |

---
## Axes du Profil (Material Icons)

| Axe | Icône Flutter | Couleur |
|-----|---------------|---------|
| **Agressivité** | `Icons.flash_on` / `Icons.bolt` | `#C44536` |
| **Patience** | `Icons.hourglass_full` / `Icons.timer` | `#4A6FA5` |
| **Analyse** | `Icons.lightbulb` / `Icons.psychology` | `#5E8B7E` |
| **Bluff** | `Icons.theater_comedy` / `Icons.masks` | `#9B72AA` |

### Alternatives Material Symbols (plus précis):
```dart
// Si utilisation de material_symbols_icons
Icon(Symbols.swords)        // Agressivité
Icon(Symbols.hourglass)     // Patience
Icon(Symbols.neurology)     // Analyse
Icon(Symbols.mask)          // Bluff
```

---

---

## Navigation (Bottom Bar)

| Icône | Nom | Usage |
|-------|-----|-------|
| 🏠 | `home` | Onglet Accueil (Dashboard) |
| 👥 | `users` | Onglet Joueurs |
| 🎲 | `dice-5` | Onglet Jeu (Match Score) |
| 🎯 | `target` | Onglet Session (Paris) |
| 🏆 | `trophy` | Onglet Classements |

---

## Actions Générales

| Icône | Nom | Usage |
|-------|-----|-------|
| ➕ | `plus` | Ajouter (joueur, jeu, session) |
| ✕ | `x` | Fermer, annuler |
| ← | `arrow-left` | Retour |
| → | `arrow-right` | Suivant, continuer |
| ✓ | `check` | Valider, confirmer |
| ✎ | `pencil` | Éditer, modifier |
| 🗑️ | `trash-2` | Supprimer |
| 🔍 | `search` | Recherche |
| ⚙️ | `settings` | Paramètres |
| ⋮ | `more-vertical` | Menu options |
| 📷 | `camera` | Ajouter photo |
| 🖼️ | `image` | Image placeholder |

---

## Navigation Joueurs

| Icône | Nom | Usage |
|-------|-----|-------|
| 👤 | `user` | Profil joueur (fallback avatar) |
| 👥 | `users` | Liste des joueurs |
| ➕👤 | `user-plus` | Ajouter un joueur |
| ✎👤 | `user-cog` | Modifier profil |
| 🌟 | `star` | Profil, notation |
| ⭐ | `star-fill` | Étoile pleine (rating) |
| ☆ | `star` | Étoile vide (rating) |

---

## Jeux et Match Score

| Icône | Nom | Usage |
|-------|-----|-------|
| 🎲 | `dice-5` | Jeux, hasard |
| 🎮 | `gamepad-2` | Jeux (variante) |
| 📦 | `package` | Boîte de jeu |
| 🎯 | `target` | Match, fit |
| ↔️ | `scale` | Comparaison, match |
| 📊 | `bar-chart-2` | Stats, analyse |
| 👍 | `thumbs-up` | Bon match |
| 👎 | `thumbs-down` | Mauvais match |
| ⚠️ | `alert-triangle` | Avertissement match |
| ⏱️ | `clock` | Durée de jeu |
| 👨‍👩‍👧‍👦 | `users` | Nombre de joueurs |
| 🎂 | `cake` | Âge minimum |

---

## Sessions et Paris

| Icône | Nom | Usage |
|-------|-----|-------|
| 📅 | `calendar` | Date de session |
| 📍 | `map-pin` | Lieu |
| 🎰 | `slot-machine` ou `dices` | Phase de paris |
| 🪙 | `coins` ou `circle-dollar-sign` | Points, mise |
| 💰 | `wallet` | Portefeuille de points |
| 🎯 | `crosshair` | Miser sur quelqu'un |
| ✋ | `hand` | Stop, fermer les paris |
| 🔒 | `lock` | Paris fermés |
| 🔓 | `unlock` | Paris ouverts |
| ⏳ | `hourglass` | Temps restant |
| 🏁 | `flag` | Partie terminée |
| ✓🏁 | `check-circle` | Résultat confirmé |

---

## Classements et Récompenses

| Icône | Nom | Usage |
|-------|-----|-------|
| 🏆 | `trophy` | Champion |
| 🥇 | `medal` | 1ère place |
| 🥈 | `award` | 2ème place |
| 🥉 | `badge` | 3ème place |
| 👑 | `crown` | Top champion |
| 🌟 | `sparkles` | Oracle, magie |
| 👁️ | `eye` | Prédiction, oracle |
| 🔮 | `glass-water` (fallback) | Boule de cristal |
| 📈 | `trending-up` | Progression |
| 📉 | `trending-down` | Régression |
| 🔥 | `flame` | Série en cours |
| 🎯 | `bullseye` | Précision |
| 🎖️ | `award` | Badges |

---

## Profils et Axes (4 axes)

| Axe | Icône | Nom | Couleur |
|-----|-------|-----|---------|
| **Agressivité** | ⚔️ | `swords` | `#C44536` (Rouge brique) |
| **Patience** | 🧘 | `hourglass` ou `pause-circle` | `#4A6FA5` (Bleu acier) |
| **Analyse** | 🧠 | `brain` ou `lightbulb` | `#5E8B7E` (Vert sauge) |
| **Bluff** | 🎭 | `mask` ou `ghost` | `#9B72AA` (Orchidée) |

### Variantes d'icônes pour les axes

**Si Lucide n'a pas l'icône exacte:**
- Agressivité: `zap` (éclair) ou `flame`
- Patience: `watch` ou `timer`
- Analyse: `search` + `bar-chart` ou `puzzle`
- Bluff: `smile` (variante malicieuse) ou `shuffle`

---

## États et Feedback

| Icône | Nom | Usage |
|-------|-----|-------|
| ✅ | `check-circle` | Succès |
| ❌ | `x-circle` | Erreur |
| ⚠️ | `alert-circle` | Attention |
| ℹ️ | `info` | Information |
| ❓ | `help-circle` | Aide |
| 🔔 | `bell` | Notifications |
| 🔕 | `bell-off` | Silencieux |
| 🔄 | `refresh-cw` | Actualiser |
| ⏳ | `loader` | Chargement (spinner) |
| 📭 | `inbox` | Vide, pas de données |

---

## Illustrations (Empty States)

| Usage | Description | Style |
|-------|-------------|-------|
| Pas de joueurs | Dés à jouer stylisés | Line art, Gold accent |
| Pas de jeux | Boîte de jeu ouverte vide | Line art |
| Pas de sessions | Calendrier avec feuilles qui s'envolent | Line art |
| Erreur | Dés cassés ou déséquilibrés | Line art, Rust accent |
| Succès | Confettis + trophée | Line art, Gold |

---

## Spécifications Techniques

### Tailles
| Contexte | Taille |
|----------|--------|
| Bottom nav | 24px |
| Boutons icon | 20px |
| List items | 20px |
| Empty states | 64px |
| Hero icons | 48px |
| Badges | 16px |

### Couleurs par Contexte
| Contexte | Couleur |
|----------|---------|
| Default | `#F5F1E8` (Cream) |
| Active/Selected | `#D4A574` (Gold) |
| Success | `#2D6B6B` (Teal) |
| Error | `#B85450` (Rust) |
| Warning | `#D4A574` (Gold) |
| Disabled | `#9CA3AF` (Stone) |

### Fichiers à Produire (si custom)

Si besoin d'icônes custom, créer en SVG:
1. `logo.svg` - Logo Prophet & Profiler
2. `dice-prophet.svg` - Dés stylisés pour la marque
3. `crown-oracle.svg` - Couronne + œil pour champion oracle
4. `axes-radar.svg` - Icône des 4 axes en radar

---

## Récapitulatif par Écran

### Dashboard
- home, trophy, users, dice-5, target, calendar, bar-chart-2

### Joueurs
- users, user, user-plus, star, star-fill, pencil, trash-2, search, camera

### Jeu (Match Score)
- dice-5, target, search, plus, check, arrow-left, arrow-right, scale, thumbs-up, thumbs-down

### Session
- target, calendar, map-pin, coins, crosshair, hand, lock, unlock, hourglass, flag, check-circle, trophy

### Classements
- trophy, medal, award, badge, crown, sparkles, eye, trending-up, trending-down, flame, bullseye

---

## Implémentation Flutter

### NavigationBar (Bottom Navigation)
```dart
NavigationBar(
  destinations: [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Accueil',
    ),
    NavigationDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: 'Joueurs',
    ),
    NavigationDestination(
      icon: Icon(Icons.casino_outlined),
      selectedIcon: Icon(Icons.casino),
      label: 'Jeu',
    ),
    NavigationDestination(
      icon: Icon(Icons.sports_esports_outlined),
      selectedIcon: Icon(Icons.sports_esports),
      label: 'Session',
    ),
    NavigationDestination(
      icon: Icon(Icons.emoji_events_outlined),
      selectedIcon: Icon(Icons.emoji_events),
      label: 'Classements',
    ),
  ],
)
```

### Toggle IconButton (Star Rating)
```dart
IconButton(
  icon: Icon(
    isFilled ? Icons.star : Icons.star_border,
    color: isFilled ? Color(0xFFD4A574) : Color(0xFF4A5568),
  ),
  onPressed: () { ... },
)
```

### Badge avec icône
```dart
Badge(
  label: Text('3'),
  child: Icon(Icons.notifications),
)
```

### Tailles (Flutter)
| Contexte | Taille | Code |
|----------|--------|------|
| Bottom nav | 24px | `size: 24` (défaut) |
| IconButton | 24px | `size: 24` (défaut) |
| ListTile leading | 24-32px | `size: 28` |
| Empty states | 64px | `size: 64` |
| Hero/Feature | 48px | `size: 48` |
| Chip/Badge | 16-18px | `size: 16` |

### Couleurs par Contexte (Flutter)
```dart
Icon(
  Icons.star,
  color: Color(0xFFF5F1E8),        // Default (Cream)
  // ou
  color: Color(0xFFD4A574),        // Active/Selected (Gold)
  // ou
  color: Color(0xFF2D6B6B),        // Success (Teal)
  // ou
  color: Color(0xFFB85450),        // Error (Rust)
  // ou
  color: Color(0xFF9CA3AF),        // Disabled (Stone)
)
```
