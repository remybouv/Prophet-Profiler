import 'package:flutter/material.dart';
import 'package:prophet_profiler/src/core/theme/widgets_theme.dart';
import 'package:prophet_profiler/src/data/models/player_model.dart';

/// Liste de cartes joueur avec séparateur
class PlayerCardList extends StatelessWidget {
  final List<Player> players;
  final Function(Player)? onPlayerTap;
  final bool compact;

  const PlayerCardList({
    super.key,
    required this.players,
    this.onPlayerTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: players.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final player = players[index];
        return _PlayerCard(
          player: player,
          onTap: onPlayerTap != null ? () => onPlayerTap!(player) : null,
          compact: compact,
        );
      },
    );
  }
}

/// Carte joueur simple
class _PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback? onTap;
  final bool compact;

  const _PlayerCard({
    required this.player,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(),
              const SizedBox(width: 12),
              // Nom et infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tap pour voir le profil',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Chevron
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.gold.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: compact ? 40 : 48,
      height: compact ? 40 : 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.gold,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: player.photoUrl != null
            ? Image.network(
                player.photoUrl!,
                fit: BoxFit.cover,
              )
            : Container(
                color: AppColors.surfaceVariant,
                child: Icon(
                  Icons.person,
                  size: compact ? 20 : 24,
                  color: AppColors.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
      ),
    );
  }
}
