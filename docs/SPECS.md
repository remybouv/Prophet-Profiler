# SPECS.md - Spécifications Fonctionnelles MVP

**Projet :** Prophet & Profiler  
**Version :** MVP v1.0  
**Date :** 2026-02-03  
**Analyste :** Reynauld

---

## 1. Gestion des Joueurs

### US-001 : Créer un profil joueur
**En tant qu'** utilisateur  
**Je veux** créer un profil pour un joueur avec son nom  
**Afin de** pouvoir le sélectionner dans les sessions de jeu

**Critères d'acceptation :**
- Nom obligatoire (2-50 caractères)
- Photo optionnelle (camera ou galerie)
- Pas de doublon sur le nom (insensible à la casse)

### US-002 : Noter un joueur sur les 4 axes
**En tant qu'** utilisateur  
**Je veux** évaluer un joueur sur Agressivité, Patience, Analyse et Bluff  
**Afin de** construire son profil comportemental

**Critères d'acceptation :**
- Notation sur 5 étoiles (1 à 5)
- Initialisé à 3 étoiles par défaut
- Modifiable à tout moment
- Affichage visuel : slider ou étoiles interactives

### US-003 : Modifier un profil
**En tant qu'** utilisateur  
**Je veux** modifier les informations d'un joueur  
**Afin de** corriger ou mettre à jour son profil

### US-004 : Supprimer un joueur
**En tant qu'** utilisateur  
**Je veux** supprimer un joueur  
**Afin de** gérer ma liste de contacts

**Critères d'acceptation :**
- Confirmation demandée si le joueur a des sessions historiques
- Conservation des anciennes sessions (anonymisation possible)

---

## 2. Catalogue de Jeux

### US-005 : Ajouter un jeu
**En tant qu'** utilisateur  
**Je veux** ajouter un jeu à mon catalogue  
**Afin de** pouvoir le sélectionner pour les sessions

**Critères d'acceptation :**
- Nom obligatoire (2-100 caractères)
- Photo de la boîte optionnelle
- Définition des 4 caractéristiques requises (1-5)

### US-006 : Définir les caractéristiques d'un jeu
**En tant qu'** utilisateur  
**Je veux** noter un jeu sur les mêmes 4 axes que les joueurs  
**Afin de** permettre le matching avec les profils

**Critères d'acceptation :**
- Agressivité : niveau d'interaction conflictuelle requis
- Patience : durée/complexité stratégique
- Analyse : niveau de réflexion nécessaire
- Bluff : importance du mensonge/dissimulation
- Échelle 1-5 pour chaque axe

### US-007 : Modifier un jeu
**En tant qu'** utilisateur  
**Je veux** modifier les informations d'un jeu  
**Afin de** affiner mon catalogue

### US-008 : Supprimer un jeu
**En tant qu'** utilisateur  
**Je veux** supprimer un jeu  
**Afin de** nettoyer mon catalogue

**Critères d'acceptation :**
- Impossible si des sessions existent avec ce jeu
- Message explicatif en cas de blocage

---

## 3. Match Score

### US-009 : Sélectionner les joueurs présents
**En tant qu'** utilisateur  
**Je veux** sélectionner les joueurs qui seront présents  
**Afin de** calculer le fit avec les jeux disponibles

**Critères d'acceptation :**
- Sélection multiple (minimum 2 joueurs)
- Affichage des profils avec photos
- Possibilité de créer un groupe rapide

### US-010 : Calculer le Match Score
**En tant qu'** utilisateur  
**Je veux** voir un score de compatibilité entre le groupe et chaque jeu  
**Afin de** choisir le jeu le plus adapté

**RÈGLES MÉTIER - Algorithme Match Score :**

```
Pour chaque jeu du catalogue :
    score_total = 0
    poids_total = 0
    
    Pour chaque axe (agressivité, patience, analyse, bluff) :
        # Profil du groupe = moyenne des joueurs sur cet axe
        profil_groupe = moyenne(joueurs[axe])
        
        # Profil requis par le jeu
        profil_jeu = jeu[axe]
        
        # Distance normalisée (0 = parfait, 1 = opposé)
        distance = |profil_groupe - profil_jeu| / 4
        
        # Score de fit pour cet axe (100 = parfait)
        score_axe = (1 - distance) * 100
        
        # Pondération : axes extrêmes (1 ou 5) ont plus d'importance
        poids = 1 + (|profil_jeu - 3| / 2)  # 1 à 2 de pondération
        
        score_total += score_axe * poids
        poids_total += poids
    
    match_score = arrondi(score_total / poids_total)
```

**Affichage des résultats :**
| Match Score | Label | Couleur |
|-------------|-------|---------|
| 90-100 | "Parfait pour ce groupe" | Vert |
| 75-89 | "Très bon choix" | Vert clair |
| 60-74 | "Ça peut le faire" | Orange |
| 40-59 | "Moyen" | Orange foncé |
| 0-39 | "À éviter" | Rouge |

### US-011 : Voir le détail du Match Score
**En tant qu'** utilisateur  
**Je veux** voir le détail des scores par axe  
**Afin de** comprendre pourquoi un jeu match ou non

**Affichage :**
- Radar chart comparatif (groupe vs jeu)
- Score détaillé par axe avec indicateur visuel
- Joueurs "outliers" identifiés (qui tirent le groupe vers un extrême)

---

## 4. Sessions de Jeu

### US-012 : Créer une session
**En tant qu'** utilisateur  
**Je veux** créer une session de jeu avec date, jeu et joueurs  
**Afin de** organiser une partie et lancer les paris

**Critères d'acceptation :**
- Date/heure (défaut = maintenant)
- Sélection du jeu (obligatoire)
- Sélection des joueurs présents (2-12 joueurs)
- Validation : nombre de joueurs compatible avec le jeu (warning si hors range)

### US-013 : Phase de paris
**En tant que** joueur participant  
**Je veux** miser sur qui je pense qui va gagner  
**Afin de** gagner des points d'Oracle

**RÈGLES MÉTIER - Système de Paris :**

```
Phase de paris :
1. Chaque joueur peut miser sur N'IMPORTE QUEL participant (y compris soi-même)
2. Un joueur ne peut miser que sur UNE SEULE personne
3. Les mises sont secrètes jusqu'à révélation
4. Durée illimitée (validation manuelle par l'organisateur)

Système de points :
- Paris correct : +10 points
- Paris incorrect : 0 point
- Auto-pari gagnant : +5 points bonus (confiance récompensée)
- Auto-pari perdant : -2 points (pénalité narcissique)

Égalité gérante :
Si le parieur mise sur X et qu'il y a égalité entre X et Y :
- Si X fait partie des ex-aequo : pari considéré correct
- Points divisés par nombre d'ex-aequo (10 / nb_gagnants)
```

### US-014 : Saisir le résultat
**En tant qu'** organisateur  
**Je veux** saisir qui a gagné la partie  
**Afin de** clôturer la session et calculer les points

**Critères d'acceptation :**
- Sélection du/des gagnants (multi-sélection possible)
- Validation avant enregistrement définitif
- Calcul automatique des points Oracles
- Impossible de modifier après confirmation (sauf admin override)

### US-015 : Voir l'historique des sessions
**En tant qu'** utilisateur  
**Je veux** consulter les sessions passées  
**Afin de** revoir l'historique et les statistiques

**Affichage :**
- Liste chronologique
- Détail : qui a parié sur qui, qui a gagné, points distribués

---

## 5. Classements

### US-016 : Voir le classement des Champions
**En tant qu'** utilisateur  
**Je veux** voir le classement des meilleurs gagnants  
**Afin de** connaître les meilleurs joueurs

**RÈGLES MÉTIER - Classement Champions :**

```
Calcul du Win Rate :
- Minimum 3 parties pour apparaître dans le classement
- Win Rate = (Nombre de victoires / Nombre de parties jouées) × 100
- Tri : Win Rate décroissant, puis nombre de parties (plus = mieux)
- Affichage : % + nombre de parties entre parenthèses

Ex-aequo : Si même win rate et même nombre de parties :
- Victoires récentes comme critère de départage
```

### US-017 : Voir le classement des Oracles
**En tant qu'** utilisateur  
**Je veux** voir le classement des meilleurs pronostiqueurs  
**Afin de** connaître les meilleurs devins

**RÈGLES MÉTIER - Classement Oracles :**

```
Calcul du Score Oracle :
- Minimum 5 paris pour apparaître dans le classement
- Score total cumulé (voir système de points paris)
- Précision = (Paris corrects / Total paris) × 100
- Tri : Score total décroissant

Affichage :
- Rang
- Nom du joueur
- Score total (points)
- Précision (%)
- Nombre de paris effectués
```

### US-018 : Voir mes statistiques personnelles
**En tant qu'** utilisateur  
**Je veux** voir mes statistiques détaillées  
**Afin de** suivre ma progression

**Données affichées :**
- Parties jouées / gagnées / win rate
- Points Oracle totaux
- Précision des prédictions
- Jeu favori (plus joué)
- Meilleur jeu (meilleur win rate, minimum 3 parties)
- Graphique d'évolution temporelle

---

## 6. Navigation & UX

### US-019 : Navigation par onglets
**En tant qu'** utilisateur  
**Je veux** naviguer facilement entre les sections  
**Afin de** accéder rapidement aux fonctionnalités

**Structure :**
- 🎮 Joueurs (liste des profils)
- 🎲 Jeux (catalogue)
- ⚡ Match (calcul fit groupe-jeu)
- 📅 Sessions (historique + nouvelle)
- 🏆 Classements

### US-020 : Page d'accueil rapide
**En tant qu'** utilisateur  
**Je veux** voir une vue d'ensemble à l'ouverture  
**Afin de** accéder rapidement aux actions principales

**Widgets :**
- Bouton "Nouvelle session" rapide
- Derniers résultats
- Classements rapides (top 3)
- Joueur à qui c'est le tour d'organiser (rotation)

---
