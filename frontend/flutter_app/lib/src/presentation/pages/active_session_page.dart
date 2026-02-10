import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:prophet_profiler/src/core/theme/widgets_theme.dart';
import 'package:prophet_profiler/src/data/models/bet_session_models.dart';
import 'package:prophet_profiler/src/presentation/blocs/active_session_bloc.dart';
import 'package:prophet_profiler/src/presentation/pages/home_page_v2.dart';

/// Page Session Active V2
/// 
/// Fonctionnalités:
/// - Récapitulatif des paris placés
/// - Sélection du gagnant (dropdown)
/// - Attribution automatique des points
/// - Statut en temps réel
/// 
/// NOTE: UI finale à compléter avec wireframes Baldwin
class ActiveSessionPage extends StatelessWidget {
  final String? sessionId;

  const ActiveSessionPage({
    super.key,
    this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ActiveSessionBloc(),
      child: _ActiveSessionPageView(sessionId: sessionId),
    );
  }
}

class _ActiveSessionPageView extends StatefulWidget {
  final String? sessionId;

  const _ActiveSessionPageView({this.sessionId});

  @override
  State<_ActiveSessionPageView> createState() => _ActiveSessionPageViewState();
}

class _ActiveSessionPageViewState extends State<_ActiveSessionPageView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  void _initialize() {
    final bloc = context.read<ActiveSessionBloc>();
    
    // TODO: Récupérer l'ID du joueur courant depuis le stockage local/auth
    // Pour l'instant, on prend le premier participant comme joueur courant
    
    if (widget.sessionId != null) {
      bloc.loadSession(widget.sessionId!).then((_) {
        // Auto-refresh si la session est active
        final state = bloc.state;
        if (state.sessionDetails?.isBetting == true || 
            state.sessionDetails?.isPlaying == true) {
          bloc.startAutoRefresh(widget.sessionId!);
        }
        
        // Définir le joueur courant (à remplacer par auth réelle)
        if (state.sessionDetails?.participants.isNotEmpty == true) {
          final firstPlayer = state.sessionDetails!.participants.first;
          bloc.setCurrentPlayer(firstPlayer.playerId, firstPlayer.name);
        }
      });
    }
  }

  @override
  void dispose() {
    context.read<ActiveSessionBloc>().stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalIndigo,
      appBar: AppBar(
        title: const Text('Session Active'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.read<ActiveSessionBloc>().refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<ActiveSessionBloc>(
        builder: (context, bloc, child) {
          final state = bloc.state;

          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }

          if (state.error != null) {
            return _buildErrorState(state.error!);
          }

          if (state.sessionDetails == null) {
            return _buildNoSessionState();
          }

          return _buildSessionContent(state);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.rust),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(color: AppColors.cream),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (widget.sessionId != null) {
                context.read<ActiveSessionBloc>().loadSession(widget.sessionId!);
              }
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSessionState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.casino_outlined, size: 64, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          const Text(
            'Aucune session active',
            style: TextStyle(color: AppColors.cream, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez une nouvelle session pour commencer',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePageV2()),
            ),
            icon: const Icon(Icons.home),
            label: const Text('Retour à l\'accueil'),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionContent(ActiveSessionState state) {
    final details = state.sessionDetails!;

    return RefreshIndicator(
      onRefresh: () => context.read<ActiveSessionBloc>().refresh(),
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header de session
          _buildSessionHeader(details),
          const SizedBox(height: 16),

          // Message de succès si présent
          if (state.successMessage != null) ...[
            _buildSuccessBanner(state.successMessage!),
            const SizedBox(height: 16),
          ],

          // Section paris (si betting)
          if (details.isBetting) ...[
            _buildBettingSection(state),
            const SizedBox(height: 16),
          ],

          // Section gagnant (si playing ou tous ont parié)
          if (details.isPlaying || (details.isBetting && details.allPlayersHaveBet)) ...[
            _buildWinnerSelectionSection(state),
            const SizedBox(height: 16),
          ],

          // Section résultats (si completed)
          if (details.isCompleted && state.winnerResult != null) ...[
            _buildResultsSection(state.winnerResult!),
            const SizedBox(height: 16),
          ],

          // Liste des participants
          _buildParticipantsSection(details),
        ],
      ),
    );
  }

  Widget _buildSessionHeader(SessionActiveDetails details) {
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
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(details.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor(details.status)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(details.status),
                      size: 14,
                      color: _getStatusColor(details.status),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusText(details.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(details.status),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${details.bets.length}/${details.participants.length} paris',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            details.boardGameName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${details.date.day}/${details.date.month}/${details.date.year}' +
                (details.location != null ? ' • ${details.location}' : ''),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.teal),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.teal),
            ),
          ),
          IconButton(
            onPressed: () => context.read<ActiveSessionBloc>().clearSuccess(),
            icon: const Icon(Icons.close, color: AppColors.teal, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildBettingSection(ActiveSessionState state) {
    final details = state.sessionDetails!;
    final currentPlayer = state.currentPlayerInfo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.casino, color: AppColors.gold),
              const SizedBox(width: 8),
              const Text(
                'Paris ouverts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Si le joueur courant n'a pas encore parié
          if (currentPlayer?.hasPlacedBet == false) ...[
            Text(
              'Sur qui pariez-vous, ${state.currentPlayerName}?',
              style: const TextStyle(color: AppColors.cream),
            ),
            const SizedBox(height: 12),
            _buildBetDropdown(state),
          ] else if (currentPlayer?.hasPlacedBet == true) ...[
            _buildUserBetInfo(currentPlayer!),
          ],
          
          // Bouton démarrer si tous ont parié
          if (details.allPlayersHaveBet && details.isBetting) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showStartPlayingConfirmation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Démarrer la partie'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBetDropdown(ActiveSessionState state) {
    final details = state.sessionDetails!;
    final participants = details.participants;

    return DropdownButtonFormField<String>(
      hint: const Text('Sélectionnez un champion'),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.royalIndigo.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.cream),
      items: participants
          .where((p) => p.playerId != state.currentPlayerId) // Pas auto-pari
          .map((p) => DropdownMenuItem(
                value: p.playerId,
                child: Text(p.name),
              ))
          .toList(),
      onChanged: state.isPlacingBet
          ? null
          : (value) async {
              if (value != null) {
                HapticFeedback.mediumImpact();
                final success = await context
                    .read<ActiveSessionBloc>()
                    .placeBet(value);
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Pari placé !'),
                      backgroundColor: AppColors.teal,
                    ),
                  );
                }
              }
            },
    );
  }

  Widget _buildUserBetInfo(ParticipantBetInfo player) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vous avez parié sur',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                ),
                Text(
                  player.betOnPlayerName ?? 'Inconnu',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerSelectionSection(ActiveSessionState state) {
    final details = state.sessionDetails!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: AppColors.gold),
              const SizedBox(width: 8),
              const Text(
                'Sélection du gagnant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Qui est le champion de cette partie ?',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: details.currentWinnerId,
            hint: const Text('Sélectionnez le gagnant'),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.royalIndigo.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: AppColors.surface,
            style: const TextStyle(color: AppColors.cream),
            items: details.participants
                .map((p) => DropdownMenuItem(
                      value: p.playerId,
                      child: Text(p.name),
                    ))
                .toList(),
            onChanged: state.isSettingWinner
                ? null
                : (value) async {
                    if (value != null) {
                      await _showWinnerConfirmation(value);
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(SetWinnerResponse result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: AppColors.gold),
              const SizedBox(width: 8),
              const Text(
                'Résultats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                const Text(
                  '🏆 Champion',
                  style: TextStyle(color: AppColors.gold, fontSize: 14),
                ),
                Text(
                  result.winnerName,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          ...result.betResolutions.map((r) => _buildBetResultItem(r)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPointsStat('Points attribués', result.totalPointsAwarded, AppColors.teal),
              _buildPointsStat('Points retirés', result.totalPointsDeducted, AppColors.rust),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBetResultItem(BetResolutionDto resolution) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(resolution.resultEmoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              resolution.bettorName,
              style: const TextStyle(color: AppColors.cream),
            ),
          ),
          Text(
            '${resolution.pointsEarned > 0 ? '+' : ''}${resolution.pointsEarned} pts',
            style: TextStyle(
              color: resolution.isCorrect ? AppColors.teal : AppColors.rust,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsSection(SessionActiveDetails details) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(
                'Participants (${details.participants.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...details.participants.map((p) => _buildParticipantItem(p)),
        ],
      ),
    );
  }

  Widget _buildParticipantItem(ParticipantBetInfo participant) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: participant.hasPlacedBet
            ? AppColors.teal.withOpacity(0.3)
            : AppColors.onSurfaceVariant.withOpacity(0.3),
        child: Icon(
          participant.hasPlacedBet ? Icons.check : Icons.pending,
          color: participant.hasPlacedBet ? AppColors.teal : AppColors.onSurfaceVariant,
          size: 18,
        ),
      ),
      title: Text(
        participant.name,
        style: const TextStyle(color: AppColors.cream),
      ),
      subtitle: participant.hasPlacedBet
          ? Text(
              'A parié sur ${participant.betOnPlayerName}',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            )
          : Text(
              'En attente du pari...',
              style: TextStyle(
                color: AppColors.rust.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
    );
  }

  Future<void> _showStartPlayingConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Démarrer la partie ?', style: TextStyle(color: AppColors.cream)),
        content: const Text(
          'Tous les joueurs ont parié. Voulez-vous démarrer la partie ?',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
            child: const Text('Démarrer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<ActiveSessionBloc>().startPlaying();
    }
  }

  Future<void> _showWinnerConfirmation(String winnerId) async {
    final participant = context
        .read<ActiveSessionBloc>()
        .state
        .sessionDetails
        ?.participants
        .firstWhere((p) => p.playerId == winnerId);

    if (participant == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Confirmer le gagnant ?', style: TextStyle(color: AppColors.cream)),
        content: Text(
          '${participant.name} est le champion de cette partie ?',
          style: const TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      HapticFeedback.heavyImpact();
      await context.read<ActiveSessionBloc>().setWinner(winnerId);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'betting':
        return AppColors.gold;
      case 'playing':
        return AppColors.teal;
      case 'completed':
        return AppColors.slate;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'betting':
        return Icons.casino;
      case 'playing':
        return Icons.play_arrow;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'betting':
        return 'Paris ouverts';
      case 'playing':
        return 'Partie en cours';
      case 'completed':
        return 'Terminée';
      default:
        return status;
    }
  }
}
