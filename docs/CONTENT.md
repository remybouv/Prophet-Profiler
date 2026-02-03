# CONTENT.md - Micro-copy pour Prophet & Profiler

> **Ton** : Ludique mais premium. Chaleureux, sophistiqué, jamais culpabilisant. Émojis pertinents.

---

## 🎯 Boutons (Actions claires, verbes d'action)

### Actions principales
| Contexte | Label | Emoji |
|----------|-------|-------|
| Création | Créer | ➕ |
| Enregistrement | Enregistrer | 💾 |
| Confirmation | Confirmer | ✓ |
| Validation finale | Valider | ✓ |
| Lancement | Commencer | ▶️ |
| Démarrage session | Lancer la partie | 🎲 |
| Saisie résultat | Terminer la session | 🏁 |

### Navigation
| Contexte | Label | Emoji |
|----------|-------|-------|
| Retour | Retour | ← |
| Annulation | Annuler | ✕ |
| Fermeture | Fermer | ✕ |
| Édition | Modifier | ✏️ |
| Suppression | Supprimer | 🗑️ |
| Continuer | Continuer | → |
| Passer | Passer cette étape | ⏭️ |

### Actions spécifiques
| Contexte | Label | Emoji |
|----------|-------|-------|
| Ajouter joueur | Nouveau joueur | 👤➕ |
| Ajouter jeu | Nouveau jeu | 🎲➕ |
| Prendre photo | Prendre une photo | 📷 |
| Choisir galerie | Choisir dans la galerie | 🖼️ |
| Sélectionner | Sélectionner | ◯→◉ |
| Placer pari | Miser sur ce joueur | 🎯 |
| Révéler paris | Découvrir les mises | 👁️ |
| Calculer match | Analyser la compatibilité | ⚡ |
| Rafraîchir | Actualiser | 🔄 |
| Partager | Partager | 📤 |

---

## 📝 Labels de formulaires

### Joueurs
```
Nom du joueur
Photo (optionnel)
Profil comportemental
```

### Jeux
```
Nom du jeu
Photo de la boîte (optionnel)
Caractéristiques requises
Nombre de joueurs minimum
Nombre de joueurs maximum
```

### Sessions
```
Date de la partie
Heure
Jeu sélectionné
Participants
```

### 4 Axes de notation
```
Agressivité — De la discussion cordiale au chaos assuré
Patience — De l'éclair rapide au marathon stratégique
Analyse — De l'instinct pur au calcul millimétré
Bluff — De la franchise légendaire au poker face absolu
```

---

## ⚠️ Messages d'erreur (Encourager, jamais culpabiliser)

### Validation formulaires
```
❌ "Veuillez entrer un nom (2 caractères minimum)"
❌ "Ce nom est déjà utilisé — chaque joueur est unique ✨"
❌ "Sélectionnez au moins 2 joueurs pour une partie"
❌ "Sélectionnez un jeu pour continuer"
```

### Actions impossibles
```
❌ "Ce jeu a déjà servi dans des sessions passées — il a marqué l'histoire 📚"
→ Bouton : "Voir les sessions" | "OK, je garde ce jeu"

❌ "Ce joueur a participé à des parties — supprimer anonymisera son historique"
→ Bouton : "Anonymiser et supprimer" | "Garder le profil"
```

### Contraintes système
```
❌ "Une connexion est nécessaire pour cette action"
❌ "Oups, quelque chose s'est mal passé. On réessaie ? 🔄"
❌ "La photo est trop lourde — 5 Mo maximum"
```

---

## ✅ Messages de succès/feedback

### Création
```
✅ "Nouveau joueur prêt à entrer dans l'arène ! 🎭"
✅ "Jeu ajouté à votre collection — encore un pour la liste 🎲"
✅ "Session créée — que les paris commencent ! 🎯"
```

### Modifications
```
✅ "Profil mis à jour avec succès ✨"
✅ "Modifications enregistrées"
✅ "Note ajustée — le portrait est plus précis 🎨"
```

### Sessions & Paris
```
✅ "Paris verrouillés — suspense garanti 🤐"
✅ "Résultats enregistrés ! Les points sont distribués 🏆"
✅ "Session terminée — belle partie ! 👏"
```

### Match Score
```
✅ "Analyse complète — votre groupe est prêt ⚡"
✅ "Match calculé pour [X] jeux"
```

---

## 💭 Placeholders

### Champs texte
```
Nom du joueur → "ex: Marie, Le Barbu, La Machine..."
Nom du jeu → "ex: Azul, Dune Imperium, 7 Wonders..."
Recherche joueur → "Rechercher un joueur..."
Recherche jeu → "Rechercher un jeu..."
```

### États par défaut
```
Photo joueur → Initiales sur gradient (généré auto)
Photo jeu → Icône 🎲 sur fond Charcoal
Date session → Aujourd'hui, Heure actuelle
```

---

## 💡 Tooltips & Explications

### Les 4 Axes (Cartes explicatives)

#### 🟥 Agressivité — "Le feu sacré"
```
1★ — Discussions cordiales, négociations pacifiques
3★ — Conflits occasionnels, zones de contrôle disputées
5★ — Chaos total, trahisons fréquentes, guerre totale

💡 "Ce joueur aime-t-il l'affrontement direct ? 
     Le jeu nécessite-t-il des attaques ou de la compétition ?"
```

#### 🟦 Patience — "La vertu des stratèges"
```
1★ — Réactif, instincts immédiats, tours rapides
3★ — Équilibre réflexion/action, timing important
5★ — Planification long terme, patience d'ange, marathon

💡 "Ce joueur préfère les coups tactiques rapides ou 
     les stratégies qui mûrissent sur plusieurs tours ?"
```

#### 🟩 Analyse — "L'œil du lynx"
```
1★ — Instinct, chance, feeling
3★ — Quelques calculs, optimisations opportunes
5★ — Maths poussées, optimisation complète, analyse profonde

💡 "Ce joueur calcule-t-il toutes les variables ? 
     Le jeu récompense-t-il la réflexion approfondie ?"
```

#### 🟪 Bluff — "L'art du masque"
```
1★ — Cartes sur table, honnêteté totale
3★ — Petites ruses, secrets partiels
5★ — Poker face absolu, mensonges glaçaux, manipulation

💡 "Ce joueur ment-il avec aisance ? 
     Le jeu pénalise-t-il la transparence ?"
```

### Match Score
```
Tooltip score : "Score de compatibilité entre le groupe et ce jeu"

Légende couleurs :
🟢 90-100% — Parfait pour ce groupe
🟢 75-89% — Très bon choix  
🟠 60-74% — Ça peut le faire
🟠 40-59% — Moyen
🔴 0-39% — À éviter
```

### Système de paris
```
Tooltip pari : "Misez sur qui vous pensez être le vainqueur"

Explication points :
"+10 points si votre prédiction est correcte
 +5 points bonus si vous misez sur vous-même ET gagnez
 -2 points si vous misez sur vous-même ET perdez"

Tooltip auto-pari : "Oser parier sur soi révèle confiance... ou narcissisme 🎭"
```

### Classements
```
Tooltip Champion : "Classement par taux de victoire — minimum 3 parties"
Tooltip Oracle : "Classement par précision des pronostics — minimum 5 paris"

Explication win rate : "Victoires / Parties jouées × 100"
Explication précision : "Paris corrects / Total des paris × 100"
```

---

## 🎨 Textes d'interface divers

### Header/Navigation
```
Tab Joueurs → "Joueurs" | "Vos profilés"
Tab Jeux → "Jeux" | "Votre collection"
Tab Match → "Match" | "Compatibilité"
Tab Sessions → "Sessions" | "Historique"
Tab Classements → "Classements" | "Hall of Fame"
```

### Statistiques
```
"Parties jouées"
"Victoires"
"Win rate"
"Paris effectués"
"Paris corrects"
"Précision"
"Score Oracle"
"Jeu favori"
"Meilleur jeu"
```

### Étapes de session
```
1. "Configuration" — Date, jeu, participants
2. "Phase de paris" — Chacun mise en secret
3. "Révélation" — Découverte des mises
4. "Résultat" — Le gagnant est couronné
```

---

## 🔢 Formatages numériques

```
Score Match : "87%" (jamais de décimale)
Win rate : "67%" (arrondi, pas de décimale)
Précision : "73%" (arrondi)
Score Oracle : "142 pts" (entiers)
Nombre parties : "12 parties" (pluriel intelligent)
```

---

*Document créé par Paracelsus — Content Writer*
*Dernière mise à jour : 2026-02-03*
