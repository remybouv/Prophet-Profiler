# 🔍 Rapport d'Investigation - Bug Stats toujours à 3

## Problème signalé
Sur l'écran liste des joueurs, les stats (Aggressivity, Bluff, etc.) restent à 3 (valeur défaut) même après modification.

---

## 🔎 Investigation

### 1. Requête EF Core - ✅ OK

**Fichier:** `backend/Controllers/PlayersController.cs`

```csharp
[HttpGet]
public async Task<ActionResult<List<Player>>> GetAll()
{
    var players = await _context.Players
        .Include(p => p.Profile)  // ✅ Profile bien inclus
        .ToListAsync();
    return Ok(players);
}
```

**Résultat:** La requête inclut bien `.Include(p => p.Profile)`. Les données sont correctement chargées.

---

### 2. Sauvegarde BDD - ✅ OK

**Fichier:** `backend/Controllers/PlayersController.cs`

```csharp
[HttpPut("{id}")]
public async Task<ActionResult> Update(Guid id, [FromBody] UpdatePlayerRequest request)
{
    var player = await _context.Players
        .Include(p => p.Profile)  // ✅ Profile bien chargé
        .FirstOrDefaultAsync(p => p.Id == id);
    
    if (player == null) return NotFound();
    
    // ✅ Mise à jour conditionnelle correcte
    if (request.Aggressivity.HasValue) player.Profile.Aggressivity = request.Aggressivity.Value;
    if (request.Patience.HasValue) player.Profile.Patience = request.Patience.Value;
    if (request.Analysis.HasValue) player.Profile.Analysis = request.Analysis.Value;
    if (request.Buff.HasValue) player.Profile.Bluff = request.Bluff.Value;
    
    await _context.SaveChangesAsync();  // ✅ Sauvegarde OK
    return NoContent();
}
```

**Résultat:** Les valeurs sont correctement sauvegardées en BDD.

---

### 3. DTO de réponse - ❌ PROBLÈME TROUVÉ

**Backend (C#):** Le modèle retourne des propriétés en **PascalCase**:
```csharp
public class PlayerProfile
{
    public int Aggressivity { get; set; } = 3;  // PascalCase
    public int Patience { get; set; } = 3;
    public int Analysis { get; set; } = 3;
    public int Bluff { get; set; } = 3;
}
```

**Frontend (Flutter):** Le modèle attend du **camelCase**:
```dart
@JsonSerializable()
class PlayerProfile extends Equatable {
  @JsonKey(name: 'aggressivity')  // camelCase !
  final int aggressivity;
  @JsonKey(name: 'patience')
  final int patience;
  @JsonKey(name: 'analysis')
  final int analysis;
  @JsonKey(name: 'bluff')
  final int bluff;
```

**Code généré:** `player_model.g.dart`
```dart
PlayerProfile _$PlayerProfileFromJson(Map<String, dynamic> json) =>
    PlayerProfile(
      aggressivity: (json['aggressivity'] as num).toInt(),  // camelCase
      patience: (json['patience'] as num).toInt(),
      analysis: (json['analysis'] as num).toInt(),
      bluff: (json['bluff'] as num).toInt(),
    );
```

**Problème:** 
- L'API retourne: `{ "Aggressivity": 4, "Patience": 2, ... }` (PascalCase)
- Le frontend attend: `{ "aggressivity": 4, "patience": 2, ... }` (camelCase)
- Les champs ne sont pas mappés → valeurs Dart par défaut (null/0) → affichage des valeurs par défaut (3)

---

### 4. Cache Flutter

Le cache Flutter n'est pas en cause. Le problème est la désérialisation JSON qui échoue silencieusement.

---

## 🛠️ Fix proposé

### Solution recommandée : Configurer JSON camelCase dans le backend

**Fichier à modifier:** `backend/Program.cs`

```csharp
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    });
```

**Avantage:** 
- Respecte les conventions (camelCase pour JSON/JavaScript, PascalCase pour C#)
- Pas de changement nécessaire côté frontend
- Standard de l'industrie

---

### Alternative : Modifier le frontend pour accepter PascalCase

**Fichier:** `frontend/flutter_app/lib/src/data/models/player_model.dart`

```dart
@JsonSerializable()
class PlayerProfile extends Equatable {
  @JsonKey(name: 'Aggressivity')  // PascalCase
  final int aggressivity;
  @JsonKey(name: 'Patience')
  final int patience;
  @JsonKey(name: 'Analysis')
  final int analysis;
  @JsonKey(name: 'Bluff')
  final int bluff;
```

Puis régénérer avec `flutter pub run build_runner build`.

**Inconvénient:** Non-standard (JSON utilise généralement camelCase).

---

## ✅ Recommandation finale

**Appliquer la Solution 1** (camelCase dans le backend) car c'est la convention standard et cela évite de casser d'autres endpoints potentiels.

## Fichier de correction

Voir `BUGFIX_STATS_CASING.patch` pour le code exact à appliquer.
