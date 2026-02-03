# OPEN_QUESTIONS.md - Questions Ouvertes et Décisions à Prendre

**Projet :** Prophet & Profiler  
**Date :** 2026-02-03  
**Analyste :** Reynauld

---

## 1. Algorithme de Matching (Match Score)

### ❓ Question 1 : La moyenne arithmétique est-elle le bon indicateur ?

**Problème :** Le profil du groupe est calculé comme la moyenne des joueurs. Mais cela masque les disparités extrêmes.

**Exemple critique :**
- Groupe : Alice (Agressivité=1), Bob (Agressivité=5) → Moyenne = 3
- Jeu A nécessite Agressivité=3 → Match parfait (100%)
- Pourtant, Alice va détester et Bob va s'ennuyer !

**Options envisagées :**

| Option | Description | Avantages | Inconvénients |
|--------|-------------|-----------|---------------|
| A | Garder la moyenne simple | Simple, rapide à calculer | Masque les conflits |
| B | Pénalité d'écart-type | Réduire le score si groupe hétérogène | Complexe à expliquer |
| C | "Warning outliers" | Alertes visuelles si joueur incompatible | N'empêche pas la sélection |
| D | Algo "satisfait tout le monde" | Score = min(fit individuel) | Très restrictif |

**Recommandation :** Option C pour MVP (alertes visuelles) + Option B en v2 si besoin.

---

### ❓ Question 2 : Poids des axes - Tous égaux ou pondérés ?

**Problème :** Certains axes sont-ils plus importants que d'autres pour le fun ?

**Hypothèses :**
- L'agressivité mal matchée crée plus de frustration
- Le bluff est moins critique pour l'expérience globale

**Options :**
- Poids uniformes (1,1,1,1) - plus simple
- Poids personnalisables par utilisateur
- Poids prédéfinis (ex: Agressivité=1.5, Bluff=0.8)

**Recommandation :** Poids uniformes pour MVP. Ajouter personnalisation en v2.

---

### ❓ Question 3 : Nombre de joueurs - Impact sur le Match Score ?

**Problème :** Un jeu peut être parfaitement matché mais avec le mauvais nombre de joueurs.

**Cas limites :**
- Jeu 2-4 joueurs, groupe de 5 → Impossible
- Jeu 4-8 joueurs, groupe de 4 → OK mais à la limite
- Jeu 2-10 joueurs, groupe de 2 → OK mais peut-être pas optimal

**Proposition :**
```
Si nb_joueurs hors range → Match Score = 0 (impossible)
Si nb_joueurs à la limite inférieure → -10% au score
Si nb_joueurs à la limite supérieure → -5% au score
Si nb_joueurs dans zone confort → pas de pénalité
```

**Décision requise :** Intégrer cette règle ? (Recommandé : OUI)

---

## 2. Gestion des Égalités

### ❓ Question 4 : Comment gérer les ex-aequo aux paris ?

**Scénario :** Alice parie sur Bob. Résultat : Bob et Charlie ex-aequo gagnants.

**Options :**

| Option | Règle | Impact joueur |
|--------|-------|---------------|
| A | Pari correct (doux) | Alice gagne 10 pts |
| B | Pari partiel | Alice gagne 10/2 = 5 pts |
| C | Pari incorrect (strict) | Alice gagne 0 pts |
| D | Bonus ex-aequo | Alice gagne 10 + bonus imprévu |

**Spécification actuelle (Option B modifiée) :**
- Pari sur X, X ex-aequo avec Y → Pari correct
- Points = 10 / nombre_de_gagnants

**Question ouverte :** Faut-il distinguer le cas où le parieur est lui-même ex-aequo ?
- Alice parie sur Bob, Alice et Bob ex-aequo
- Alice a-t-elle "bien parié" malgré tout ?

**Recommandation :** Non, le pari sur Bob est correct si Bob gagne (même ex-aequo). Pas de cas spécial.

---

### ❓ Question 5 : Égalité dans les classements Champions

**Scénario :** Alice et Bob ont même win rate (60%) et même nombre de parties (10).

**Règles de départage :**
1. Nombre de parties (plus = mieux) - DÉJÀ DANS LES SPECS
2. Parties récentes (victoires dans les 5 dernières parties)
3. Total de victoires absolu
4. Position aléatoire (alphabétique)

**Recommandation :** Option 2 (parties récentes) car plus dynamique et récompense la forme actuelle.

---

### ❓ Question 6 : Égalité dans les classements Oracles

**Scénario :** Alice et Bob ont même score Oracle (120 pts).

**Règles de départage :**
1. Précision (%) la plus haute
2. Nombre de paris (plus = plus fiable)
3. Pari le plus risqué gagnant (outsider)
4. Date du dernier pari gagnant

**Recommandation :** Option 1 puis 2 (précision puis nombre de paris).

---

## 3. Bonus et Système de Points

### ❓ Question 7 : Bonus "Outsider" ?

**Concept :** Récompenser les paris sur des outsiders (joueurs peu favoris).

**Calcul possible :**
```
Si un joueur a win rate < 30% et qu'on parie sur lui ET qu'il gagne :
Bonus = (30 - win_rate) / 2  → entre 0 et 15 points bonus
```

**Intérêt :** 
- ✅ Encourage les paris audacieux
- ✅ Rend le classement Oracle plus dynamique
- ❌ Complexifie le système de points
- ❌ Peut encourager les paris irrationnels

**Alternatives :**
- Badge "Coup de poker" sans points
- Multiplicateur de points selon improbabilité
- Pas de bonus (système simple)

**Recommandation :** Pour MVP, PAS de bonus outsider. Garder le système simple (10 pts / pari correct). À revisiter en v2 avec data réelle.

---

### ❓ Question 8 : Malus pour absence de pari ?

**Scénario :** Un joueur participe mais ne parie pas (oublie, abstention).

**Options :**
- Aucune conséquence (neutre)
- Malus de -5 points (incitation)
- Impossible de ne pas parier (bloquant)

**Recommandation :** Option 3 pour MVP - forcer le pari avant de pouvoir saisir le résultat. Plus simple à implémenter et garantit l'engagement.

---

### ❓ Question 9 : Points négatifs possibles ?

**Spécification actuelle :**
- Auto-pari gagnant : +15 pts (+10 base +5 bonus)
- Auto-pari perdant : -2 pts (pénalité narcissique)
- Paris incorrect : 0 pts

**Question :** Autoriser les scores Oracle négatifs ?

**Arguments :**
- ✅ Réalisme (série de mauvais paris = score négatif)
- ✅ Différencie les mauvais des très mauvais
- ❌ Démotivant
- ❌ Complexifie l'UI (afficher scores négatifs)

**Recommandation :** Score minimum = 0. Plancher à zéro pour éviter la frustration.

---

## 4. UX et Edge Cases

### ❓ Question 10 : Que faire si un joueur quitte le groupe ?

**Scénarios :**
1. **Suppression douce :** Joueur marqué "inactif", conserve l'historique
2. **Suppression dure :** Joueur supprimé, sessions impactées ?

**Impact sur les stats :**
- Classement Champions : doit-on garder un joueur inactif ?
- Historique : anonymiser ou garder le nom ?

**Recommandation :** 
- Suppression douce par défaut (flag "archivé")
- Possibilité de vraie suppression si aucune session
- Option "anonymiser l'historique" plutôt que supprimer

---

### ❓ Question 11 : Minimum de données pour les classements

**Spécification actuelle :**
- Champions : minimum 3 parties
- Oracles : minimum 5 paris

**Questions :**
- Ces seuils sont-ils adaptés ?
- Faut-il afficher les joueurs "en probation" (grisés) ?

**Recommandation :** 
- Garder les seuils
- Afficher les joueurs en dessous du seuil dans une section "Nouveaux" séparée

---

## 5. Questions pour l'équipe

### À valider avec Baldwin (UX) :
- [ ] Le radar chart est-il trop technique pour l'utilisateur moyen ?
- [ ] Faut-il un tutoriel à la première utilisation ?
- [ ] Dark mode obligatoire ou optionnel ?

### À valider avec l'équipe tech :
- [ ] SQLite suffisant ou besoin de relations complexes ?
- [ ] Gestion des photos : stockage local uniquement ?
- [ ] Export/import de la base possible (backup) ?

### À tester avec des utilisateurs :
- [ ] L'algorithme de matching correspond-il à l'intuition ?
- [ ] Le système de paris est-il fun ou contraignant ?
- [ ] Les classements motivent-ils ou stressent-ils ?

---

## Récapitulatif des décisions recommandées

| # | Question | Recommandation | Priorité |
|---|----------|----------------|----------|
| 1 | Moyenne vs écart-type | Option C (warning outliers) | Haute |
| 2 | Poids des axes | Uniformes pour MVP | Moyenne |
| 3 | Nombre de joueurs | Intégrer la pénalité | Haute |
| 4 | Égalité paris | Points divisés par nb gagnants | Haute |
| 5 | Égalité Champions | Départage par récence | Moyenne |
| 6 | Égalité Oracles | Précision puis nb paris | Moyenne |
| 7 | Bonus outsider | NON pour MVP | Basse |
| 8 | Malus absence pari | Obligation de parier | Haute |
| 9 | Points négatifs | Score minimum 0 | Moyenne |
| 10 | Départ joueur | Suppression douce | Moyenne |
| 11 | Min données classement | Seuils actuels + section "Nouveaux" | Basse |

---
