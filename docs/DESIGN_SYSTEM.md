# DESIGN_SYSTEM.md - Prophet & Profiler

## Direction Artistique

**Éthique** : Ludique mais premium. Inspiration jeux de société modernes (Wingspan, Azul, Dune Imperium) — sophistication, matériaux nobles, pas de plastique cheap.

**Mood** : Soirée entre amis dans un salon chaleureux. Éclairage tamisé, bois, feutre.

---

## 🎨 Palette de Couleurs

### Couleurs Primaires
| Nom | Hex | Usage |
|-----|-----|-------|
| **Royal Indigo** | `#1A1B3A` | Fonds principaux, header |
| **Gold Accent** | `#D4A574` | CTAs, accents premium, icônes clés |
| **Cream** | `#F5F1E8` | Fonds de cartes, textes sur fond sombre |

### Couleurs Secondaires
| Nom | Hex | Usage |
|-----|-----|-------|
| **Teal** | `#2D6B6B` | Validation, succès, stats positives |
| **Rust** | `#B85450` | Agressivité, alertes, accents chauds |
| **Slate** | `#4A5568` | Textes secondaires, bordures |
| **Charcoal** | `#2D3748` | Cartes sombres, overlays |

### Couleurs des Axes de Profil
| Axe | Couleur | Hex |
|-----|---------|-----|
| Agressivité | **Rouge brique** | `#C44536` |
| Patience | **Bleu acier** | `#4A6FA5` |
| Analyse | **Vert sauge** | `#5E8B7E` |
| Bluff | **Orchidée** | `#9B72AA` |

### Échelle de Gris
| Nom | Hex |
|-----|-----|
| Pure White | `#FFFFFF` |
| Whisper | `#F7F5F0` |
| Mist | `#E8E4DC` |
| Stone | `#9CA3AF` |
| Shadow | `#6B7280` |

---

## 🔤 Typographie

### Police Principale : **Outfit** (Google Fonts)
- **Light** (300) : Labels, légendes
- **Regular** (400) : Corps de texte
- **Medium** (500) : Sous-titres
- **SemiBold** (600) : Titres de section
- **Bold** (700) : Titres principaux

### Police Secondaire : **Space Grotesk** (Google Fonts)
- **Medium** (500) : Chiffres, stats, scores
- **Bold** (700) : Titres accentués, badges

### Échelle Typographique (Mobile)
| Élément | Taille | Poids | Line-height |
|---------|--------|-------|-------------|
| H1 | 32px | 700 | 1.2 |
| H2 | 24px | 600 | 1.3 |
| H3 | 20px | 600 | 1.4 |
| H4 | 16px | 500 | 1.4 |
| Body | 16px | 400 | 1.5 |
| Body Small | 14px | 400 | 1.5 |
| Caption | 12px | 300 | 1.4 |
| Stat Number | 28px | 500 | 1 |
| Score Big | 48px | 700 | 1 |

---

## 📐 Espacements & Grille

### Base Unit : **8px**

### Tokens d'Espacement
| Token | Valeur | Usage |
|-------|--------|-------|
| `xs` | 4px | Inline gaps, icon padding |
| `sm` | 8px | Tight gaps |
| `md` | 16px | Standard padding |
| `lg` | 24px | Section padding |
| `xl` | 32px | Large sections |
| `2xl` | 48px | Page breaks |

### Grille Mobile
- **Container** : 100% - 32px (padding latéral)
- **Gutters** : 16px
- **Cards** : Full width avec 16px internal padding

### Rayons de Bordure
| Token | Valeur | Usage |
|-------|--------|-------|
| `none` | 0px | Inputs (rare) |
| `sm` | 8px | Petits éléments, tags |
| `md` | 12px | Boutons, cartes |
| `lg` | 16px | Cards principales |
| `full` | 9999px | Avatars, badges ronds |

### Ombres
| Token | Valeur | Usage |
|-------|--------|-------|
| `sm` | `0 1px 2px rgba(26,27,58,0.05)` | Tags, badges |
| `md` | `0 4px 6px rgba(26,27,58,0.07)` | Cartes |
| `lg` | `0 10px 15px rgba(26,27,58,0.1)` | Modals, dropdowns |
| `glow` | `0 0 20px rgba(212,165,116,0.3)` | Accent elements |

---

## 🧩 Composants de Base

### Material Design 3 + Flutter

Cette app utilise **Material Design 3** avec un thème custom dark. Références widgets Flutter ci-dessous.

### Thème Flutter (ThemeData)

```dart
ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Color(0xFFD4A574),        // Gold
    onPrimary: Color(0xFF1A1B3A),      // Royal Indigo
    secondary: Color(0xFF2D6B6B),      // Teal
    surface: Color(0xFF2D3748),        // Charcoal
    surfaceContainerHighest: Color(0xFF4A5568), // Slate
    background: Color(0xFF1A1B3A),     // Royal Indigo
    onBackground: Color(0xFFF5F1E8),   // Cream
  ),
  scaffoldBackgroundColor: Color(0xFF1A1B3A),
  cardTheme: CardTheme(
    color: Color(0xFF2D3748),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
)
```

### Boutons

#### Primary Button
```
Design:
Background: #D4A574 (Gold)
Text: #1A1B3A (Royal Indigo)
Padding: 16px 24px
Border-radius: 12px
Font: Outfit 600, 16px

Flutter:
- Widget: FilledButton (Material 3)
- Style: FilledButton.styleFrom(
    backgroundColor: Color(0xFFD4A574),
    foregroundColor: Color(0xFF1A1B3A),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  )
```

#### Secondary Button
```
Design:
Background: transparent
Border: 1px solid #D4A574
Text: #D4A574
Padding: 16px 24px
Border-radius: 12px

Flutter:
- Widget: OutlinedButton (Material 3)
- Style: OutlinedButton.styleFrom(
    side: BorderSide(color: Color(0xFFD4A574)),
    foregroundColor: Color(0xFFD4A574),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  )
```

#### Ghost Button
```
Design:
Background: transparent
Text: #F5F1E8 (sur fond sombre)
Padding: 12px 16px
Border-radius: 8px

Flutter:
- Widget: TextButton (Material 3)
- Style: TextButton.styleFrom(
    foregroundColor: Color(0xFFF5F1E8),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  )
```

#### Icon Button
```
Design:
Size: 48px x 48px
Background: #2D3748
Border-radius: 12px
Icon: 24px, #F5F1E8

Flutter:
- Widget: IconButton.filled (Material 3)
- Style: IconButton.styleFrom(
    backgroundColor: Color(0xFF2D3748),
    foregroundColor: Color(0xFFF5F1E8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    minimumSize: Size(48, 48),
  )
```

### Cartes

#### Card Base
```
Design:
Background: #2D3748 (Charcoal)
Border-radius: 16px
Padding: 16px
Shadow: md

Flutter:
- Widget: Card (Material 3)
- Style: Card(
    color: Color(0xFF2D3748),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(padding: EdgeInsets.all(16), child: ...),
  )
```

#### Card Elevated
```
Design:
Background: #4A5568 (Slate)
Border: 1px solid #D4A574 (Gold accent)
Border-radius: 16px
Padding: 20px
Shadow: glow

Flutter:
- Widget: Card.elevated avec custom
- Style: Card(
    color: Color(0xFF4A5568),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Color(0xFFD4A574)),
    ),
    elevation: 8,
    child: Padding(padding: EdgeInsets.all(20), child: ...),
  )
```

#### Card Player
```
Design:
Background: gradient de #2D3748 à #1A1B3A
Border-radius: 16px
Padding: 16px
Avatar: 56px, border 2px Gold

Flutter:
- Widget: Card + Container avec gradient
- Style: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: [Color(0xFF2D3748), Color(0xFF1A1B3A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Padding(padding: EdgeInsets.all(16), child: ...),
  )
```

### Inputs

#### Text Input
```
Design:
Background: #2D3748
Border: 1px solid #4A5568
Border-radius: 12px
Padding: 16px
Text: #F5F1E8
Placeholder: #9CA3AF
Focus: border #D4A574

Flutter:
- Widget: TextField ou TextFormField
- Style: TextField(
    decoration: InputDecoration(
      filled: true,
      fillColor: Color(0xFF2D3748),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF4A5568)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFD4A574)),
      ),
    ),
    style: TextStyle(color: Color(0xFFF5F1E8)),
  )
```

#### Star Rating (4 axes)
```
Design:
Star empty: #4A5568
Star filled: #D4A574
Star size: 24px
Gap: 4px

Flutter:
- Widget: Custom Row avec IconButton ou package flutter_rating_bar
- Style: Row avec Icon(Icons.star, color: filled ? Color(0xFFD4A574) : Color(0xFF4A5568))
```

### Badges & Tags

#### Badge Champion
```
Design:
Background: #D4A574
Text: #1A1B3A
Border-radius: full
Padding: 4px 12px
Font: Space Grotesk 700, 12px
Icon: Crown (left)

Flutter:
- Widget: Chip (Material 3) ou custom Container
- Style: Chip(
    avatar: Icon(Icons.emoji_events, color: Color(0xFF1A1B3A)),
    label: Text('Champion'),
    backgroundColor: Color(0xFFD4A574),
    labelStyle: TextStyle(color: Color(0xFF1A1B3A), fontWeight: FontWeight.bold),
  )
```

#### Badge Oracle
```
Design:
Background: #2D6B6B
Text: #F5F1E8
Border-radius: full
Padding: 4px 12px
Font: Space Grotesk 700, 12px
Icon: Eye (left)

Flutter:
- Widget: Chip (Material 3)
- Style: Chip(
    avatar: Icon(Icons.visibility, color: Color(0xFFF5F1E8)),
    label: Text('Oracle'),
    backgroundColor: Color(0xFF2D6B6B),
    labelStyle: TextStyle(color: Color(0xFFF5F1E8), fontWeight: FontWeight.bold),
  )
```

#### Tag Jeu
```
Design:
Background: rgba(212,165,116,0.15)
Border: 1px solid rgba(212,165,116,0.3)
Text: #D4A574
Border-radius: 8px
Padding: 6px 12px
Font: Outfit 500, 12px

Flutter:
- Widget: Chip.outlined (Material 3)
- Style: Chip(
    label: Text('Azul'),
    side: BorderSide(color: Color(0xFFD4A574).withOpacity(0.3)),
    backgroundColor: Color(0xFFD4A574).withOpacity(0.15),
    labelStyle: TextStyle(color: Color(0xFFD4A574)),
  )
```

---

## 📊 Éléments de Data Viz

### Barres de Score (4 axes)
```
Design:
Height: 8px
Border-radius: 4px
Background track: #4A5568
Fill: Couleur de l'axe
Animation: width 0.3s ease-out

Flutter:
- Widget: LinearProgressIndicator ou custom Container
- Style: Container(
    height: 8,
    decoration: BoxDecoration(
      color: Color(0xFF4A5568),
      borderRadius: BorderRadius.circular(4),
    ),
    child: FractionallySizedBox(
      widthFactor: 0.75, // 75%
      child: Container(
        decoration: BoxDecoration(
          color: axeColor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
  )
```

### Jauges de Match
```
Design:
Type: Demi-cercle ou barre horizontale
Colors: Rouge (<40%) → Orange (40-70%) → Vert (>70%)
Label: "Parfait pour ce groupe" / "À éviter"

Flutter:
- Widget: CustomPaint pour demi-cercle ou LinearProgressIndicator
- Package: syncfusion_flutter_gauges ou custom implementation
```

### Indicateurs de Paris
```
Design:
Pion Joueur: 32px circle, photo + bord couleur
Jeton Mise: 24px, icône pièce + montant
Animation: slide-in lors du reveal

Flutter:
- Widget: CircleAvatar avec Container parent pour bordure
- Style: Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Color(0xFFD4A574), width: 2),
    ),
    child: CircleAvatar(
      radius: 16,
      backgroundImage: NetworkImage(playerPhoto),
    ),
  )
```

---

## 🖼️ Images & Assets

### Avatars Joueurs
- **Size**: 56px (list), 80px (profile), 120px (detail)
- **Border**: 2px solid Gold (pour soi) / transparent (autres)
- **Fallback**: Initiales sur fond gradient selon hash du nom

### Photos de Jeux
- **Ratio**: 4:3 ou 1:1 (boîte carrée)
- **Border-radius**: 12px
- **Shadow**: md
- **Overlay**: Gradient sombre en bas pour le texte

### Icônes
- **Library**: Material Icons (default Flutter) ou Material Symbols
- **Alternative**: Phosphor Flutter (package phosphor_flutter)
- **Size**: 24px standard, 20px small, 32px large
- **Color**: hérite du contexte (Cream ou Gold)

### Navigation Flutter
```dart
// BottomNavigationBar Material 3
NavigationBar(
  backgroundColor: Color(0xFF1A1B3A),
  indicatorColor: Color(0xFFD4A574).withOpacity(0.2),
  selectedIndex: _selectedIndex,
  onDestinationSelected: (index) { ... },
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

---

## 🔄 États & Interactions

### Touch Targets
- Minimum: 48px x 48px
- Espacement entre: 8px minimum

### Animations
| Élément | Animation | Durée |
|---------|-----------|-------|
| Page transition | Slide horizontal | 300ms ease-in-out |
| Card appear | Fade + slide up | 200ms ease-out |
| Button press | Scale 0.97 | 100ms |
| Score update | Count up | 500ms |
| Bet placement | Bounce | 400ms elastic |

### États de Feedback
| État | Design | Flutter |
|------|--------|---------|
| **Loading** | Spinner Gold sur fond Indigo | `CircularProgressIndicator(color: Color(0xFFD4A574))` |
| **Success** | Check Teal + haptic light | `Icons.check_circle` + `HapticFeedback.lightImpact()` |
| **Error** | X Rust + shake animation | `Icons.error` + `AnimatedBuilder` avec shake |
| **Empty** | Illustration + texte encouragement | `Center` avec `Column` contenant `Icon` + `Text` |

### Snackbar/Toast Flutter
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Paris enregistré !'),
    backgroundColor: Color(0xFF2D6B6B),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
```

---

## 📱 Breakpoints

| Breakpoint | Width | Adaptations |
|------------|-------|-------------|
| Mobile (default) | < 480px | Base design |
| Mobile L | 480-768px | Grille 2 colonnes pour jeux |
| Tablet | 768px+ | Grille 2-3 colonnes, sidebar |
