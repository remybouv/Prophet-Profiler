import 'package:flutter/material.dart';
import 'package:prophet_profiler/src/core/theme/widgets_theme.dart';
import 'package:prophet_profiler/src/data/models/bet_model.dart';

/// Dialog affichant les résultats des paris après une session
/// 
/// - Qui a parié sur qui (liste visible)
/// - Gagnant affiché
/// - Points gagnés/perdus
class BetResultsDialog extends StatelessWidget {
  final BetsSummary betsSummary;
  final String currentPlayerId;

  const BetResultsDialog({
    super.key,
    required this.betsSummary,
    required this.currentPlayerId,
  });

  static Future<void> show({
    required BuildContext context,
    required BetsSummary betsSummary,
    required String currentPlayerId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BetResultsDialog(
        betsSummary: betsSummary,
        currentPlayerId: currentPlayerId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actualWinnerId = betsSummary.actualWinnerId;
    final hasWinner = actualWinnerId != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.royalIndigo,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header avec gagnant
              _buildWinnerHeader(hasWinner),
              const SizedBox(height: 16),
              // Stats
              _buildStatsRow(),
              const Divider(height: 32, indent: 16, endIndent: 16),
              // Liste des paris
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: betsSummary.bets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final bet = betsSummary.bets[index];
                    final isCurrentUser = bet.bettorId == currentPlayerId;
                    final isWinner = hasWinner && bet.predictedWinnerId == actualWinnerId;

                    return _BetResultCard(
                      bet: bet,
                      isCurrentUser: isCurrentUser,
                      isWinner: isWinner,
                      actualWinnerName: betsSummary.actualWinnerName,
                    );
                  },
                ),
              ),
              // Bouton fermer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.royalIndigo,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.surfaceVariant.withOpacity(0.3),
                    ),
                  ),
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.cream,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Fermer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWinnerHeader(bool hasWinner) {
    if (!hasWinner) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Session en cours',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withOpacity(0.3),
            AppColors.gold.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: AppColors.royalIndigo,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'CHAMPION',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.royalIndigo,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            betsSummary.actualWinnerName ?? 'Inconnu',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'a remporté cette session !',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final totalBets = betsSummary.totalBets;
    final correctBets = betsSummary.bets.where((b) => 
      b.predictedWinnerId == betsSummary.actualWinnerId
    ).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.people,
              value: '$totalBets',
              label: 'Paris placés',
              color: AppColors.cream,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle,
              value: '$correctBets',
              label: 'Prédictions correctes',
              color: AppColors.teal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.percent,
              value: totalBets > 0 
                  ? '${((correctBets / totalBets) * 100).round()}%' 
                  : '0%',
              label: 'Taux de réussite',
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de statistique
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Carte de résultat de pari
class _BetResultCard extends StatelessWidget {
  final Bet bet;
  final bool isCurrentUser;
  final bool isWinner;
  final String? actualWinnerName;

  const _BetResultCard({
    required this.bet,
    required this.isCurrentUser,
    required this.isWinner,
    this.actualWinnerName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? AppColors.gold.withOpacity(0.1) 
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser 
              ? AppColors.gold.withOpacity(0.3) 
              : Colors.transparent,
          width: isCurrentUser ? 1 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar du parieur
            _buildAvatar(bet.bettorPhotoUrl, isCurrentUser),
            const SizedBox(width: 12),
            // Flèche
            Icon(
              Icons.arrow_forward,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            // Avatar du choix
            _buildAvatar(bet.predictedWinnerPhotoUrl, false),
            const SizedBox(width: 16),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bet.bettorName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                      color: isCurrentUser ? AppColors.gold : AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'a parié sur ${bet.predictedWinnerName}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Badge résultat
            _buildResultBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? photoUrl, bool highlight) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: highlight ? AppColors.gold : AppColors.surfaceVariant,
          width: highlight ? 2 : 1,
        ),
      ),
      child: ClipOval(
        child: photoUrl != null
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
              )
            : Container(
                color: AppColors.surfaceVariant,
                child: Icon(
                  Icons.person,
                  size: 22,
                  color: AppColors.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
      ),
    );
  }

  Widget _buildResultBadge() {
    if (isWinner) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.teal.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.teal),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 14,
              color: AppColors.teal,
            ),
            const SizedBox(width: 4),
            Text(
              '+10',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.teal,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.rust.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.rust),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cancel,
              size: 14,
              color: AppColors.rust,
            ),
            const SizedBox(width: 4),
            Text(
              '-5',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.rust,
              ),
            ),
          ],
        ),
      );
    }
  }
}
