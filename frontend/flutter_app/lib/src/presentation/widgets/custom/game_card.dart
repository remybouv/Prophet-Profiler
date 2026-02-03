import 'package:flutter/material.dart';
import '../../../core/theme/widgets_theme.dart';
import 'match_score_gauge.dart';
import 'four_axis_rating.dart';

/// Modèle de données pour une partie
class GameSession {
  final String id;
  final String name;
  final DateTime date;
  final String? location;
  final List<GamePlayer> players;
  final GameStatus status;
  final double? userMatchScore;

  const GameSession({
    required this.id,
    required this.name,
    required this.date,
    this.location,
    required this.players,
    this.status = GameStatus.upcoming,
    this.userMatchScore,
  });
}

class GamePlayer {
  final String playerId;
  final String name;
  final double matchScore;

  const GamePlayer({
    required this.playerId,
    required this.name,
    required this.matchScore,
  });
}

enum GameStatus { upcoming, active, completed, cancelled }

/// Carte jeu affichant les informations d'une partie avec Match Score
/// 
/// Style: Royal Indigo avec jauge de match score
class GameCard extends StatelessWidget {
  final GameSession game;
  final VoidCallback? onTap;
  final bool showMatchScore;

  const GameCard({
    super.key,
    required this.game,
    this.onTap,
    this.showMatchScore = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardThemeExt;

    return Card(
      margin: cardTheme.margin,
      elevation: cardTheme.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: cardTheme.borderRadius,
        side: BorderSide(
          color: _getStatusColor().withOpacity(0.5),
          width: cardTheme.borderWidth,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: cardTheme.borderRadius,
        child: Padding(
          padding: cardTheme.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 12),
              // Info date et lieu
              _buildInfoRow(context),
              const Divider(height: 20, color: AppColors.surfaceVariant),
              // Joueurs et Match Score
              if (showMatchScore && game.userMatchScore != null) ...[
                Row(
                  children: [
                    // Liste des joueurs
                    Expanded(
                      flex: 2,
                      child: _buildPlayersList(context),
                    ),
                    // Jauge Match Score
                    Expanded(
                      flex: 1,
                      child: MatchScoreGauge(
                        score: game.userMatchScore!,
                        label: 'Match',
                        size: 100,
                        strokeWidth: 8,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildPlayersList(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Icône statut
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        // Nom de la partie
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              _buildStatusChip(),
            ],
          ),
        ),
        // Chevron
        Icon(
          Icons.chevron_right,
          color: AppColors.gold.withOpacity(0.5),
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 14,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          _formatDate(game.date),
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        if (game.location != null) ...[
          const SizedBox(width: 16),
          Icon(
            Icons.location_on_outlined,
            size: 14,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              game.location!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlayersList(BuildContext context) {
    final theme = Theme.of(context);
    final playerCount = game.players.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people_outline,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              '$playerCount joueur${playerCount > 1 ? 's' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Avatar stack
        _buildAvatarStack(),
      ],
    );
  }

  Widget _buildAvatarStack() {
    const maxVisible = 4;
    final visiblePlayers = game.players.take(maxVisible).toList();
    final remaining = game.players.length - maxVisible;

    return SizedBox(
      height: 36,
      child: Stack(
        children: [
          for (var i = 0; i < visiblePlayers.length; i++)
            Positioned(
              left: i * 24.0,
              child: _buildPlayerAvatar(visiblePlayers[i], i),
            ),
          if (remaining > 0)
            Positioned(
              left: visiblePlayers.length * 24.0,
              child: _buildMoreIndicator(remaining),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerAvatar(GamePlayer player, int index) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.royalIndigoLight,
          width: 2,
        ),
        color: AppColors.surface,
      ),
      child: Center(
        child: Text(
          player.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _getMatchScoreColor(player.matchScore),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreIndicator(int count) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.royalIndigoLight,
          width: 2,
        ),
        color: AppColors.surfaceVariant,
      ),
      child: Center(
        child: Text(
          '+$count',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (game.status) {
      case GameStatus.active:
        return AppColors.success;
      case GameStatus.upcoming:
        return AppColors.gold;
      case GameStatus.completed:
        return AppColors.info;
      case GameStatus.cancelled:
        return AppColors.danger;
    }
  }

  IconData _getStatusIcon() {
    switch (game.status) {
      case GameStatus.active:
        return Icons.play_circle_outline;
      case GameStatus.upcoming:
        return Icons.schedule;
      case GameStatus.completed:
        return Icons.check_circle_outline;
      case GameStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _getStatusText() {
    switch (game.status) {
      case GameStatus.active:
        return 'En cours';
      case GameStatus.upcoming:
        return 'À venir';
      case GameStatus.completed:
        return 'Terminée';
      case GameStatus.cancelled:
        return 'Annulée';
    }
  }

  Color _getMatchScoreColor(double score) {
    if (score < 40) return AppColors.danger;
    if (score < 70) return AppColors.warning;
    return AppColors.success;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final gameDate = DateTime(date.year, date.month, date.day);

    if (gameDate == today) {
      return 'Aujourd\'hui, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (gameDate == today.add(const Duration(days: 1))) {
      return 'Demain, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Liste de cartes jeu
class GameCardList extends StatelessWidget {
  final List<GameSession> games;
  final Function(GameSession)? onGameTap;
  final bool showMatchScores;

  const GameCardList({
    super.key,
    required this.games,
    this.onGameTap,
    this.showMatchScores = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: games.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final game = games[index];
        return GameCard(
          game: game,
          onTap: onGameTap != null ? () => onGameTap!(game) : null,
          showMatchScore: showMatchScores,
        );
      },
    );
  }
}
