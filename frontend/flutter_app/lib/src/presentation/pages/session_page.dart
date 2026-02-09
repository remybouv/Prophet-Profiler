import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prophet_profiler/src/core/theme/widgets_theme.dart';
import 'package:prophet_profiler/src/data/models/bet_model.dart';
import 'package:prophet_profiler/src/data/models/player_model.dart';
import 'package:prophet_profiler/src/services/api_service.dart';
import 'package:prophet_profiler/src/presentation/widgets/custom/bet_button.dart';
import 'package:prophet_profiler/src/widgets/custom/bet_selection_dialog.dart';
import 'package:prophet_profiler/src/widgets/custom/bet_results_dialog.dart';
import 'package:prophet_profiler/src/widgets/custom/player_card.dart';

/// Page de session de jeu avec système de paris intégré
/// 
/// Affiche :
/// - Les informations de la session
/// - Les participants
/// - Le bouton "Qui sera le champion ?" (visible uniquement en mode Betting)
/// - Les résultats des paris (après la session)
class SessionPage extends StatefulWidget {
  final String? sessionId;

  const SessionPage({
    super.key,
    this.sessionId,
  });

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isPlacingBet = false;
  String? _error;

  // Données de session simulées (à remplacer par l'API réelle)
  SessionStatus _sessionStatus = SessionStatus.betting;
  List<Player> _participants = [];
  Player? _currentPlayer;
  BetsSummary? _betsSummary;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // TODO: Remplacer par l'appel API réel
      // Simuler le chargement des données
      await Future.delayed(const Duration(milliseconds: 500));

      // Charger les joueurs pour la démo
      final players = await _apiService.getPlayers();
      
      setState(() {
        _participants = players;
        // Pour la démo, prendre le premier joueur comme utilisateur courant
        _currentPlayer = players.isNotEmpty ? players.first : null;
        _betsSummary = _generateMockBetsSummary();
        _isLoading = false;
      });

      developer.log('✅ Données de session chargées', name: 'SessionPage');
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
      developer.log('❌ Erreur chargement session: $e', name: 'SessionPage');
    }
  }

  // Données simulées pour la démo
  BetsSummary _generateMockBetsSummary() {
    final bets = <Bet>[];
    
    // Simuler quelques paris
    if (_participants.length >= 2) {
      bets.add(Bet(
        id: '1',
        sessionId: widget.sessionId ?? 'session-1',
        bettorId: _participants[0].id,
        bettorName: _participants[0].name,
        bettorPhotoUrl: _participants[0].photoUrl,
        predictedWinnerId: _participants[1].id,
        predictedWinnerName: _participants[1].name,
        predictedWinnerPhotoUrl: _participants[1].photoUrl,
        placedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ));
    }

    return BetsSummary(
      sessionId: widget.sessionId ?? 'session-1',
      sessionStatus: _sessionStatus,
      totalBets: bets.length,
      totalParticipants: _participants.length,
      bets: bets,
      currentUserBetOn: null,
      actualWinnerId: null,
      actualWinnerName: null,
    );
  }

  Future<void> _placeBet(Player selectedPlayer) async {
    if (_currentPlayer == null || widget.sessionId == null) return;

    try {
      setState(() {
        _isPlacingBet = true;
      });

      // Appel API pour placer le pari
      await _apiService.placeBet(
        widget.sessionId!,
        _currentPlayer!.id,
        selectedPlayer.id,
      );

      // Recharger les données
      await _loadSessionData();

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Pari placé sur ${selectedPlayer.name} !'),
            backgroundColor: AppColors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      developer.log('✅ Pari placé sur ${selectedPlayer.name}', name: 'SessionPage');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: AppColors.rust,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      developer.log('❌ Erreur placement pari: $e', name: 'SessionPage');
    } finally {
      setState(() {
        _isPlacingBet = false;
      });
    }
  }

  void _showBetSelection() {
    developer.log('🔥 Bouton "Qui sera le champion" cliqué !', name: 'SessionPage');
    
    if (_currentPlayer == null || _participants.length < 2) {
      developer.log('❌ Conditions non remplies: currentPlayer=$_currentPlayer, participants=${_participants.length}', name: 'SessionPage');
      return;
    }

    developer.log('✅ Affichage du dialog de sélection', name: 'SessionPage');
    BetSelectionDialog.show(
      context: context,
      participants: _participants,
      currentPlayer: _currentPlayer!,
      onPlayerSelected: _placeBet,
    );
  }

  void _showBetResults() {
    if (_betsSummary == null) return;

    BetResultsDialog.show(
      context: context,
      betsSummary: _betsSummary!,
      currentPlayerId: _currentPlayer?.id ?? '',
    );
  }

  bool get _canPlaceBets {
    return _sessionStatus == SessionStatus.betting && _participants.length >= 2;
  }

  bool get _hasUserBet {
    if (_currentPlayer == null || _betsSummary == null) return false;
    return _betsSummary!.hasPlayerBet(_currentPlayer!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalIndigo,
      appBar: AppBar(
        title: const Text('Session de jeu'),
        actions: [
          // Bouton pour voir les résultats si session terminée
          if (_sessionStatus == SessionStatus.completed)
            IconButton(
              onPressed: _showBetResults,
              icon: const Icon(Icons.emoji_events),
              tooltip: 'Résultats',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.rust,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(color: AppColors.cream),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadSessionData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadSessionData,
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header de session
          _buildSessionHeader(),
          const SizedBox(height: 24),
          // Bouton de pari (si applicable)
          if (_canPlaceBets || _hasUserBet || _sessionStatus == SessionStatus.betting)
            _buildBetSection(),
          if (_canPlaceBets || _hasUserBet) const SizedBox(height: 24),
          // Participants
          _buildParticipantsSection(),
        ],
      ),
    );
  }

  Widget _buildSessionHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(),
                      size: 14,
                      color: _getStatusColor(),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _sessionStatus.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_betsSummary != null)
                Text(
                  '${_betsSummary!.totalBets}/${_betsSummary!.totalParticipants} paris',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Session #1',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Soirée jeux du ${_formatDate(DateTime.now())}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetSection() {
    final hasEnoughPlayers = _participants.length >= 2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.casino,
                  color: AppColors.gold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paris ouverts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cream,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasEnoughPlayers
                          ? 'Placez votre pari sur le futur champion'
                          : 'Minimum 2 joueurs requis pour parier',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          BetButton(
            betsCount: _betsSummary?.totalBets ?? 0,
            totalParticipants: _participants.length,
            hasUserBet: _hasUserBet,
            isEnabled: hasEnoughPlayers,
            onPressed: _hasUserBet ? _showBetResults : _showBetSelection,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participants (${_participants.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.cream,
          ),
        ),
        const SizedBox(height: 12),
        if (_participants.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Aucun participant',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
          )
        else
          PlayerCardList(
            players: _participants,
            compact: true,
            onPlayerTap: (player) {
              // TODO: Naviguer vers le profil du joueur
              developer.log('👤 Joueur tapé: ${player.name}', name: 'SessionPage');
            },
          ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_sessionStatus) {
      case SessionStatus.planning:
        return AppColors.onSurfaceVariant;
      case SessionStatus.betting:
        return AppColors.gold;
      case SessionStatus.inProgress:
        return AppColors.teal;
      case SessionStatus.completed:
        return AppColors.slate;
    }
  }

  IconData _getStatusIcon() {
    switch (_sessionStatus) {
      case SessionStatus.planning:
        return Icons.schedule;
      case SessionStatus.betting:
        return Icons.casino;
      case SessionStatus.inProgress:
        return Icons.play_arrow;
      case SessionStatus.completed:
        return Icons.check_circle;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Page de création de session (modifiée pour inclure les paris)
class NewSessionWithBetPage extends StatefulWidget {
  const NewSessionWithBetPage({super.key});

  @override
  State<NewSessionWithBetPage> createState() => _NewSessionWithBetPageState();
}

class _NewSessionWithBetPageState extends State<NewSessionWithBetPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isCreating = false;
  List<Player> _players = [];
  List<Player> _selectedPlayers = [];
  String? _selectedGameId;
  List<dynamic> _games = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final players = await _apiService.getPlayers();
      final games = await _apiService.getGames();
      
      setState(() {
        _players = players;
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createSession() async {
    if (_selectedPlayers.length < 2 || _selectedGameId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez au moins 2 joueurs et un jeu'),
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final response = await _apiService.createSession({
        'gameId': _selectedGameId,
        'playerIds': _selectedPlayers.map((p) => p.id).toList(),
        'status': 'Betting',
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SessionPage(
              sessionId: response['id']?.toString(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  void _togglePlayer(Player player) {
    setState(() {
      if (_selectedPlayers.contains(player)) {
        _selectedPlayers.remove(player);
      } else {
        _selectedPlayers.add(player);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Session'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sélection du jeu
                  _buildGameSelection(),
                  const SizedBox(height: 24),
                  // Sélection des joueurs
                  _buildPlayerSelection(),
                  const Spacer(),
                  // Bouton créer
                  ElevatedButton.icon(
                    onPressed: _isCreating ? null : _createSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.royalIndigo,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.royalIndigo,
                            ),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(
                      _isCreating
                          ? 'Création...'
                          : 'Démarrer la session (${_selectedPlayers.length} joueurs)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGameSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jeu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.cream,
          ),
        ),
        const SizedBox(height: 8),
        if (_games.isEmpty)
          const Text(
            'Aucun jeu disponible',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _games.map((game) {
              final isSelected = _selectedGameId == game['id']?.toString();
              return ChoiceChip(
                label: Text(game['name']?.toString() ?? 'Jeu'),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedGameId = game['id']?.toString();
                  });
                },
                selectedColor: AppColors.gold,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.royalIndigo : AppColors.cream,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildPlayerSelection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Joueurs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _selectedPlayers.length >= 2
                      ? AppColors.teal.withOpacity(0.2)
                      : AppColors.rust.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedPlayers.length} sélectionné(s)',
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedPlayers.length >= 2
                        ? AppColors.teal
                        : AppColors.rust,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_players.isEmpty)
            const Text(
              'Aucun joueur disponible',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  final player = _players[index];
                  final isSelected = _selectedPlayers.contains(player);
                  
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) => _togglePlayer(player),
                    title: Text(
                      player.name,
                      style: const TextStyle(color: AppColors.cream),
                    ),
                    secondary: CircleAvatar(
                      backgroundImage: player.photoUrl != null
                          ? NetworkImage(player.photoUrl!)
                          : null,
                      child: player.photoUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    activeColor: AppColors.gold,
                    checkColor: AppColors.royalIndigo,
                    tileColor: isSelected
                        ? AppColors.gold.withOpacity(0.1)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
