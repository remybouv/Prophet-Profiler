# TERMINOLOGY.md - Glossaire de l'application

> **Ton** : Clair, précis, avec une touche de chaleur. Les définitions doivent être immédiatement compréhensibles.

---

## 📱 Noms des Features

| Feature | Nom dans l'app | Description courte |
|---------|----------------|-------------------|
| Gestion des profils joueurs | **Joueurs** | Créer et gérer les profils de vos compagnons de jeu |
| Catalogue de jeux | **Jeux** | Votre collection personnelle avec caractéristiques |
| Algorithme de compatibilité | **Match Score** | Score de compatibilité entre un groupe et un jeu |
| Sessions de jeu | **Sessions** | Parties enregistrées avec paris et résultats |
| Système de pronostics | **Paris** | Miser secrètement sur le futur vainqueur |
| Tableau des victoires | **Classement Champions** | Win rate des meilleurs joueurs |
| Tableau des prédictions | **Classement Oracles** | Précision des meilleurs pronostiqueurs |
| Vue d'ensemble | **Accueil** | Dashboard avec actions rapides et stats |

---

## 🎯 Les 4 Axes de Profilage

### Définitions en 1 phrase

| Axe | Couleur | Définition |
|-----|---------|------------|
| **Agressivité** | 🟥 Rouge brique (#C44536) | Niveau d'affrontement direct et d'interaction conflictuelle qu'un joueur apprécie ou qu'un jeu requiert. |
| **Patience** | 🟦 Bleu acier (#4A6FA5) | Capacité à privilégier la planification long terme face aux récompenses immédiates. |
| **Analyse** | 🟩 Vert sauge (#5E8B7E) | Propension à calculer, optimiser et réfléchir stratégiquement plutôt qu'agir sur l'instinct. |
| **Bluff** | 🟪 Orchidée (#9B72AA) | Aptitude à dissimuler ses intentions et à tromper les adversaires. |

### Échelle commune
```
★☆☆☆☆ (1/5) — Très faible / Presque absent
★★☆☆☆ (2/5) — Faible / Occasionnel
★★★☆☆ (3/5) — Modéré / Équilibré
★★★★☆ (4/5) — Élevé / Fréquent
★★★★★ (5/5) — Très élevé / Constant
```

---

## 🎲 Vocabulaire du Jeu

### Termes généraux

| Terme | Définition | Contexte d'usage |
|-------|------------|------------------|
| **Session** | Une partie de jeu enregistrée avec date, participants, jeu utilisé, paris placés et résultat. | "Créer une nouvelle session" |
| **Match Score** | Score de compatibilité (0-100%) entre le profil moyen d'un groupe de joueurs et les caractéristiques requises par un jeu. | "Le Match Score de Wingspan pour ce groupe est de 87%" |
| **Profil** | Ensemble des 4 évaluations (Agressivité, Patience, Analyse, Bluff) attribuées à un joueur. | "Le profil de Thomas tend vers l'agressivité" |
| **Profil groupe** | Moyenne des profils des joueurs sélectionnés pour une analyse Match Score. | "Le profil groupe est très analytique" |
| **Caractéristiques** | Les 4 valeurs (1-5) définissant le profil requis ou présent. | "Les caractéristiques de ce jeu privilégient le bluff" |

### Système de paris

| Terme | Définition | Règles associées |
|-------|------------|------------------|
| **Pari** | Prédiction faite par un joueur sur qui va gagner la partie. | Un seul pari par joueur et par session |
| **Miser** | Action de placer un pari sur un participant. | Peut être sur soi ou sur un autre |
| **Auto-pari** | Pari placé sur soi-même. | +5 pts si gagnant, -2 pts si perdant |
| **Phase de paris** | Période où les joueurs placent secrètement leurs mises. | Les paris sont masqués jusqu'à révélation |
| **Révélation** | Moment où tous les paris sont dévoilés simultanément. | Avant le début de la partie |
| **Points Oracle** | Score cumulé basé sur la précision des prédictions. | +10 par bon pari, bonus/malus auto-pari |

### Résultats & Statistiques

| Terme | Définition | Formule / Détail |
|-------|------------|------------------|
| **Win Rate** | Pourcentage de parties gagnées sur parties jouées. | Victoires ÷ Parties jouées × 100 |
| **Précision** | Pourcentage de paris corrects sur total des paris. | Paris corrects ÷ Total paris × 100 |
| **Score Oracle** | Total cumulé des points gagnés via les paris. | Somme de tous les points (+10, +5, -2, 0) |
| **Jeu favori** | Le jeu le plus fréquemment joué par un joueur. | Mode du nombre de sessions par jeu |
| **Meilleur jeu** | Le jeu avec le meilleur win rate pour un joueur. | Max win rate parmi les jeux avec ≥3 parties |
| **Ex-aequo** | Égalité entre plusieurs gagnants. | Points de pari divisés par nombre de gagnants |

---

## 🏆 Classements

### Champion
```
Titre honorifique pour les joueurs avec le meilleur win rate.

Accès : Minimum 3 parties jouées
Tri : Win rate décroissant, puis nombre de parties
Badge : 👑 Crown sur fond Gold
```

### Oracle
```
Titre honorifique pour les joueurs avec la meilleure précision de prédiction.

Accès : Minimum 5 paris effectués
Tri : Score Oracle total décroissant
Badge : 👁️ Eye sur fond Teal
```

---

## 🔄 États des sessions

| État | Description | Icône |
|------|-------------|-------|
| **Configurée** | Session créée, joueurs et jeu sélectionnés. | ⚙️ |
| **Paris ouverts** | Les joueurs peuvent placer leurs mises. | 🎯 |
| **Paris fermés** | Tous les paris sont placés, en attente de révélation. | 🔒 |
| **Révélée** | Les mises sont visibles par tous. | 👁️ |
| **En cours** | La partie est en train de se jouer. | ▶️ |
| **Terminée** | Résultat saisi, points distribués. | ✓ |
| **Annulée** | Session abandonnée sans résultat. | ✕ |

---

## ⚡ Match Score — Niveaux

| Score | Label | Signification |
|-------|-------|---------------|
| 90-100% | **Parfait** | Le jeu correspond exactement au profil du groupe |
| 75-89% | **Très bon** | Excellente compatibilité, le groupe va apprécier |
| 60-74% | **Acceptable** | Ça peut fonctionner, avec quelques ajustements |
| 40-59% | **Moyen** | Certains joueurs risquent d'être mal à l'aise |
| 0-39% | **À éviter** | Incompatibilité majeure, choisir un autre jeu |

---

## 🎨 Termes d'interface

| Terme UI | Équivalent utilisateur | Usage |
|----------|------------------------|-------|
| **Fit** | Compatibilité | "Le fit entre ce groupe et Azul est excellent" |
| **Outlier** | Joueur atypique | "Thomas est un outlier sur l'agressivité" |
| **Radar chart** | Graphique en toile d'araignée | Visualisation des 4 axes |
| **Slider** | Curseur de notation | Interface pour attribuer 1-5 étoiles |
| **Chip/Tag** | Pastille/Étiquette | Petit élément affichant un nom (jeu, joueur) |
| **Avatar** | Photo de profil | Image ronde représentant un joueur |

---

## 📊 Seuils et minimums

| Règle | Valeur | Raison |
|-------|--------|--------|
| Joueurs min. pour Match Score | 2 | Nécessite un groupe |
| Joueurs max. par session | 12 | Limite pratique |
| Parties min. pour classement Champions | 3 | Échantillon significatif |
| Paris min. pour classement Oracles | 5 | Échantillon significatif |
| Parties min. pour "Meilleur jeu" | 3 | Éviter le hasard |
| Caractères min. nom joueur | 2 | Identifiable |
| Caractères max. nom joueur | 50 | Lisibilité |
| Caractères max. nom jeu | 100 | Lisibilité |

---

## 💬 Expressions courantes

```
"Lancer une partie" → Démarrer une nouvelle session
"Placer ses jetons" → Faire un pari
"Le match est parfait" → Score de 90-100%
"Monter dans le classement" → Améliorer son rang
"Lire dans le jeu" → Prédire correctement le vainqueur
"Le hasard fait bien les choses" → Victoire inattendue
```

---

*Document créé par Paracelsus — Content Writer*
*Dernière mise à jour : 2026-02-03*
