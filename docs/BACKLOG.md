# BACKLOG.md - Backlog Produit MVP

**Projet :** Prophet & Profiler  
**Version :** MVP v1.0  
**Date :** 2026-02-03  
**Analyste :** Reynauld

---

## Légende

### Priorités
- **MUST** = Indispensable pour le MVP (release bloquante)
- **SHOULD** = Importante mais peut être reportée si nécessaire
- **COULD** = Nice-to-have, ajoute du polish

### Complexité
- **S** (Small) = 1-2 jours
- **M** (Medium) = 3-5 jours  
- **L** (Large) = 1-2 semaines

---

## MUST (Features indispensables)

| ID | Feature | User Stories | Complexité | Dépendances |
|----|---------|--------------|------------|-------------|
| M1 | **Création profil joueur** | US-001, US-002 | S | - |
| M2 | **Catalogue de jeux** | US-005, US-006 | S | - |
| M3 | **Match Score - Sélection groupe** | US-009 | S | M1 |
| M4 | **Match Score - Calcul algo** | US-010, US-011 | M | M2, M3 |
| M5 | **Création session** | US-012 | S | M1, M2 |
| M6 | **Phase de paris** | US-013 | M | M5 |
| M7 | **Saisie résultat** | US-014 | S | M6 |
| M8 | **Classement Champions** | US-016 | S | M7 |
| M9 | **Classement Oracles** | US-017 | S | M7 |
| M10 | **Navigation onglets** | US-019 | S | Toutes les vues |
| M11 | **Persistance SQLite** | - | M | Toutes |

**Total MUST :** 11 features  
**Charge estimée :** ~35-40 jours

---

## SHOULD (Features importantes)

| ID | Feature | User Stories | Complexité | Dépendances | Justification |
|----|---------|--------------|------------|-------------|---------------|
| S1 | **Modification/suppression joueurs** | US-003, US-004 | S | M1 | Gestion d'erreurs essentielle |
| S2 | **Modification/suppression jeux** | US-007, US-008 | S | M2 | Gestion d'erreurs essentielle |
| S3 | **Stats personnelles** | US-018 | M | M8, M9 | Engagement utilisateur |
| S4 | **Historique sessions** | US-015 | S | M7 | Référence et traçabilité |
| S5 | **Page d'accueil rapide** | US-020 | S | M8, M9 | UX améliorée |
| S6 | **Photos joueurs/jeux** | Partie de US-001, US-005 | M | M1, M2 | Expérience premium |

**Total SHOULD :** 6 features  
**Charge estimée :** ~15-18 jours

---

## COULD (Nice-to-have)

| ID | Feature | User Stories | Complexité | Dépendances | Justification |
|----|---------|--------------|------------|-------------|---------------|
| C1 | **Animations Match Score** | US-010 | S | M4 | Delight visuel |
| C2 | **Radar chart comparatif** | US-011 | M | M4 | Visualisation pro |
| C3 | **Export stats** | - | S | S3 | Partage externe |
| C4 | **Dark mode** | - | S | M10 | Accessibilité |
| C5 | **Tri/filtres catalogue** | - | S | M2 | Gros catalogues |
| C6 | **Recherche joueurs/jeux** | - | S | M1, M2 | Gros catalogues |
| C7 | **Session en cours (état)** | Extension US-012 | M | M5 | Pause/reprise |
| C8 | **Achievements/Badges** | - | M | Toutes | Gamification |
| C9 | **Temps de partie** | Extension US-012 | S | M5 | Stats complètes |
| C10 | **Commentaires session** | Extension US-014 | S | M7 | Contexte social |

**Total COULD :** 10 features  
**Charge estimée :** ~15-20 jours

---

## Planning suggéré

### Sprint 1 - Fondations (Semaine 1-2)
- [ ] M11 : Persistance SQLite
- [ ] M1 : Création profil joueur  
- [ ] M2 : Catalogue de jeux

### Sprint 2 - Match Score (Semaine 3-4)
- [ ] M3 : Match Score - Sélection groupe
- [ ] M4 : Match Score - Calcul algo
- [ ] C1/C2 : Polish visuel Match Score (si temps)

### Sprint 3 - Sessions (Semaine 5-6)
- [ ] M5 : Création session
- [ ] M6 : Phase de paris
- [ ] M7 : Saisie résultat
- [ ] S4 : Historique sessions

### Sprint 4 - Classements (Semaine 7-8)
- [ ] M8 : Classement Champions
- [ ] M9 : Classement Oracles
- [ ] S3 : Stats personnelles
- [ ] S5 : Page d'accueil rapide

### Sprint 5 - Polish & Release (Semaine 9)
- [ ] M10 : Navigation onglets (intégration finale)
- [ ] S1, S2 : Modification/suppression
- [ ] S6 : Photos
- [ ] Bug fixes et optimisation

---

## Notes de planification

1. **Risque principal :** L'algorithme Match Score (M4) doit être validé rapidement - faire un prototype en semaine 1
2. **Hypothèse :** Un seul cercle d'amis = pas de gestion multi-groupe nécessaire
3. **Découverte :** Les photos (S6) prennent plus de temps que prévu sur mobile - à prioriser tôt si possible
4. **Coupe possible :** Si retard, déplacer S3 (Stats perso) en v1.1

---
