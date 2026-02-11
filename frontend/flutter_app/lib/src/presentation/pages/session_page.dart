import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:prophet_profiler/src/core/theme/widgets_theme.dart';
import 'package:prophet_profiler/src/data/models/bet_model.dart';
import 'package:prophet_profiler/src/data/models/player_model.dart';
import 'package:prophet_profiler/src/presentation/blocs/bets_bloc.dart';
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
class SessionPage extends StatelessWidget {
  final String? sessionId;

  const SessionPage({
    super.key,
    this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BetsBloc(),
      child: _SessionPageView(sessionId: sessionId),
    );
  }
}

class _SessionPageView extends StatefulWidget {
  final String? sessionId;

  const _SessionPageView({this.sessionId});

  @override
  State<_SessionPageView> createState() => _SessionPageViewState();
}

class _SessionPageViewState extends State<_SessionPageView> {
  final ApiService _apiService = ApiService();
  bool _isLoadingSession = true;
  bool _isPlacingBet = false;
  String? _error;

  // Données de session chargées depuis l'API
  SessionStatus _sessionStatus = SessionStatus.betting;
  List<Player> _participants = [];
  List<Player> _allPlayers = []; // Tous les joueurs disponibles pour sélection
  Player? _currentPlayer; // Le joueur qui parie (sélectionné par l'utilisateur)
  String? _sessionName;
  DateTime? _sessionDate;
  bool _showBettorSelector = false; // Afficher le sélecteur de parieur

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    if (widget.sessionId == null) {
      // Mode sans session - charger uniquement les joueurs disponibles
      await _loadPlayersOnly();
      return;
    }

    try {
      setState(() {
        _isLoadingSession = true;
        _error = null;
      });

      // Charger les joueurs
      final players = await _apiService.getPlayers();
      
      // Charger les détails de la session
      await _loadSessionDetails(widget.sessionId!);

      setState(() {
        _allPlayers = players;
        _participants = players;
        // Aucun parieur sélectionné par défaut - l'utilisateur doit choisir
        _currentPlayer = null;
        _showBettorSelector = true;
        _isLoadingSession = false;
      });

      // Charger le résumé des paris via le BLoC
      if (mounted) {
        final betsBloc = context.read<BetsBloc>();
        betsBloc.setParticipants(_participants);
        // Ne pas définir le currentPlayer ici - attendre la sélection
        await betsBloc.loadBetsSummary(widget.sessionId!);
      }

      developer.log('✅ Données de session chargées', name: 'SessionPage');
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement: $e';
        _isLoadingSession = false;
      });
      developer.log('❌ Erreur chargement session: $e', name: 'SessionPage');
    }
  }

  Future<void> _loadPlayersOnly() async {
    try {
      setState(() {
        _isLoadingSession = true;
        _error = null;
      });

      final players = await _apiService.getPlayers();

      setState(() {
        _allPlayers = players;
        _participants = players; // Par défaut tous les joueurs sont participants
        _currentPlayer = null; // Aucun parieur sélectionné par défaut
        _showBettorSelector = true; // Forcer l'affichage du sélecteur
        _sessionName = 'Nouvelle Session';
        _sessionDate = DateTime.now();
        _isLoadingSession = false;
      });

      // Créer un résumé vide pour le mode sans session
      if (mounted) {
        final betsBloc = context.read<BetsBloc>();
        betsBloc.setParticipants(_participants);
      }

      developer.log('✅ Joueurs chargés (mode sans session)', name: 'SessionPage');
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement: $e';
        _isLoadingSession = false;
      });
      developer.log('❌ Erreur chargement joueurs: $e', name: 'SessionPage');
    }
  }

  Future<void> _loadSessionDetails(String sessionId) async {
    try {
      final sessionData = await _apiService.getSession(sessionId);
      setState(() {
        _sessionName = sessionData['name'] ?? 'Session #$sessionId';
        _sessionDate = sessionData['date'] != null 
            ? DateTime.parse(sessionData['date']) 
            : DateTime.now();
        _sessionStatus = _parseSessionStatus(sessionData['status']);
      });
    } catch (e) {
      // Si l'endpoint n'est pas encore disponible, utiliser les valeurs par défaut
      developer.log('⚠️ Endpoint getSession non disponible, utilisation des valeurs par défaut', name: 'SessionPage');
      setState(() {
        _sessionName = 'Session #$sessionId';
        _sessionDate = DateTime.now();
        _sessionStatus = SessionStatus.betting;
      });
    }
  }

  SessionStatus _parseSessionStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'planning':
        return SessionStatus.planning;
      case 'betting':
        return SessionStatus.betting;
      case 'inprogress':
      case 'in_progress':
        return SessionStatus.inProgress;
      case 'completed':
        return SessionStatus.completed;
      default:
        return SessionStatus.betting;
    }
  }

  Future<void> _placeBet(Player selectedPlayer) async {
    if (_currentPlayer == null || widget.sessionId == null) return;

    try {
      setState(() {
        _isPlacingBet = true;
      });

      final betsBloc = context.read<BetsBloc>();
      final success = await betsBloc.placeBet(
        sessionId: widget.sessionId!,
        bettorId: _currentPlayer!.id,
        predictedWinnerId: selectedPlayer.id,
      );

      if (success && mounted) {
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
        developer.log('✅ Pari placé sur ${selectedPlayer.name}', name: 'SessionPage');
      }
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
    final betsBloc = context.read<BetsBloc>();
    if (betsBloc.state.betsSummary == null) return;

    BetResultsDialog.show(
      context: context,
      betsSummary: betsBloc.state.betsSummary!,
      currentPlayerId: _currentPlayer?.id ?? '',
    );
  }

  void _selectBettor(Player player) {
    setState(() {
      _currentPlayer = player;
      _showBettorSelector = false;
    });
    
    // Mettre à jour le BLoC avec le parieur sélectionné
    final betsBloc = context.read<BetsBloc>();
    betsBloc.setCurrentPlayer(player);
    
    HapticFeedback.mediumImpact();
    developer.log('👤 Parieur sélectionné: ${player.name}', name: 'SessionPage');
  }

  void _changeBettor() {
    setState(() {
      _showBettorSelector = true;
    });
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
      body: _isLoadingSession
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
      child: Consumer<BetsBloc>(
        builder: (context, betsBloc, child) {
          final betsSummary = betsBloc.state.betsSummary;
          final sessionStatus = betsSummary?.sessionStatus ?? _sessionStatus;
          final isLoadingBets = betsBloc.state.isLoading;

          // Si aucun parieur n'est sélectionné, afficher le sélecteur en premier
          if (_currentPlayer == null && _allPlayers.isNotEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSessionHeader(betsSummary, sessionStatus),
                const SizedBox(height: 24),
                _buildBettorSelectorSection(),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header de session avec le parieur actuel
              _buildSessionHeader(betsSummary, sessionStatus),
              const SizedBox(height: 24),
              // Indicateur de chargement des paris
              if (isLoadingBets)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: AppColors.gold,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              // Message d'erreur des paris
              if (betsBloc.state.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.rust.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.rust),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: AppColors.rust, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          betsBloc.state.error!,
                          style: TextStyle(color: AppColors.rust, fontSize: 12),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          betsBloc.clearError();
                          if (widget.sessionId != null) {
                            betsBloc.loadBetsSummary(widget.sessionId!);
                          }
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              // Afficher qui parie actuellement
              if (_currentPlayer != null)
                _buildCurrentBettorCard(),
              if (_currentPlayer != null)
                const SizedBox(height: 16),
              // Bouton de pari (si applicable)
              if (_canPlaceBets(sessionStatus) || _hasUserBet(betsBloc) || sessionStatus == SessionStatus.betting)
                _buildBetSection(betsBloc, sessionStatus),
              if (_canPlaceBets(sessionStatus) || _hasUserBet(betsBloc)) const SizedBox(height: 24),
              // Participants
              _buildParticipantsSection(),
            ],
          );
        },
      ),
    );
  }

  /// Carte affichant le parieur actuel avec option pour changer
  Widget _buildCurrentBettorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
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
                  'Vous pariez en tant que',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentPlayer!.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _changeBettor,
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: const Text('Changer'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  /// Section de sélection du parieur
  Widget _buildBettorSelectorSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
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
                  Icons.person_outline,
                  color: AppColors.gold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Qui êtes-vous ?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cream,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sélectionnez votre profil pour parier',
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
          const Divider(color: AppColors.surfaceVariant),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _allPlayers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final player = _allPlayers[index];
              return _BettorSelectionCard(
                player: player,
                onTap: () => _selectBettor(player),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSessionHeader(BetsSummary? betsSummary, SessionStatus sessionStatus) {
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
                  color: _getStatusColor(sessionStatus).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor(sessionStatus)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(sessionStatus),
                      size: 14,
                      color: _getStatusColor(sessionStatus),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      sessionStatus.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(sessionStatus),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (betsSummary != null)
                Text(
                  '${betsSummary.totalBets}/${betsSummary.totalParticipants} paris',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _sessionName ?? 'Session #${widget.sessionId ?? '1'}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Soirée jeux du ${_formatDate(_sessionDate ?? DateTime.now())}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetSection(BetsBloc betsBloc, SessionStatus sessionStatus) {
    final hasEnoughPlayers = _participants.length >= 2;
    final hasUserBet = _hasUserBet(betsBloc);
    final canPlaceBets = _canPlaceBets(sessionStatus);

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
                    Text(
                      canPlaceBets ? 'Paris ouverts' : 'Paris fermés',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cream,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasEnoughPlayers
                          ? canPlaceBets
                              ? 'Placez votre pari sur le futur champion'
                              : hasUserBet
                                  ? 'Vous avez déjà parié !'
                                  : 'Les paris sont fermés pour cette session'
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
            betsCount: betsBloc.state.betsSummary?.totalBets ?? 0,
            totalParticipants: _participants.length,
            hasUserBet: hasUserBet,
            isEnabled: hasEnoughPlayers && canPlaceBets,
            onPressed: hasUserBet ? _showBetResults : _showBetSelection,
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
              developer.log('👤 Joueur tapé: ${player.name}', name: 'SessionPage');
            },
          ),
      ],
    );
  }

  bool _canPlaceBets(SessionStatus sessionStatus) {
    return sessionStatus == SessionStatus.betting && _participants.length >= 2;
  }

  bool _hasUserBet(BetsBloc betsBloc) {
    return betsBloc.state.hasUserBet;
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
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

  IconData _getStatusIcon(SessionStatus status) {
    switch (status) {
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

/// Carte de sélection d'un parieur
class _BettorSelectionCard extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;

  const _BettorSelectionCard({
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                _buildAvatar(),
                const SizedBox(width: 16),
                // Nom
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cream,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Appuyez pour sélectionner',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Flèche
                Icon(
                  Icons.chevron_right,
                  color: AppColors.gold,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.surfaceVariant,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: player.photoUrl != null
            ? Image.network(
                player.photoUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholder();
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.person,
          size: 24,
          color: AppColors.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
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
      final results = await Future.wait([
        _apiService.getPlayers(),
        _apiService.getGames(),
      ]);
      
      setState(() {
        _players = results[0] as List<Player>;
        _games = results[1] as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: AppColors.rust,
          ),
        );
      }
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
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.rust,
          ),
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
