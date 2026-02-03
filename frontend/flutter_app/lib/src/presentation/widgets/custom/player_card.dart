import 'package:flutter/material.dart';
import '../../../core/theme/widgets_theme.dart';
import '../../../data/models/player_model.dart';
import 'four_axis_rating.dart';

/// Carte joueur affichant photo, nom et les 4 barres de profil
/// 
/// Style: Royal Indigo avec bordure dorée
class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback? onTap;
  final bool compact;

  const PlayerCard({
    super.key,
    required this.player,
    this.onTap,
    this.compact = false,
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
          color: cardTheme.borderColor,
          width: cardTheme.borderWidth,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: cardTheme.borderRadius,
        child: Padding(
          padding: cardTheme.padding,
          child: compact ? _buildCompactLayout(context) : _buildFullLayout(context),
        ),
      ),
    );
  }

  Widget _buildFullLayout(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header avec photo et nom
        Row(
          children: [
            // Avatar du joueur
            _buildAvatar(),
            const SizedBox(width: 16),
            // Nom et info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Profil Poker',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Icône chevron
            Icon(
              Icons.chevron_right,
              color: AppColors.gold.withOpacity(0.5),
            ),
          ],
        ),
        const Divider(height: 24, color: AppColors.surfaceVariant),
        // Barres de profil compactes
        FourAxisRatingCompact(
          aggressivity: player.profile.aggressivity,
          patience: player.profile.patience,
          analysis: player.profile.analysis,
          bluff: player.profile.bluff,
        ),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _buildAvatar(size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                player.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Mini barres horizontales
              _buildMiniBars(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar({double size = 64}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.gold,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: player.photoUrl != null
            ? Image.network(
                player.photoUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholder(size);
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder(size);
                },
              )
            : _buildPlaceholder(size),
      ),
    );
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Icon(
          Icons.person,
          size: size * 0.5,
          color: AppColors.gold.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildMiniBars() {
    return Row(
      children: [
        _buildMiniBar(AppColors.aggressivity, player.profile.aggressivity / 5),
        const SizedBox(width: 4),
        _buildMiniBar(AppColors.patience, player.profile.patience / 5),
        const SizedBox(width: 4),
        _buildMiniBar(AppColors.analysis, player.profile.analysis / 5),
        const SizedBox(width: 4),
        _buildMiniBar(AppColors.bluff, player.profile.bluff / 5),
      ],
    );
  }

  Widget _buildMiniBar(Color color, double value) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(2),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
        return PlayerCard(
          player: player,
          onTap: onPlayerTap != null ? () => onPlayerTap!(player) : null,
          compact: compact,
        );
      },
    );
  }
}

/// Grid de cartes joueur pour affichage en grille
class PlayerCardGrid extends StatelessWidget {
  final List<Player> players;
  final Function(Player)? onPlayerTap;

  const PlayerCardGrid({
    super.key,
    required this.players,
    this.onPlayerTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return PlayerCard(
          player: player,
          onTap: onPlayerTap != null ? () => onPlayerTap!(player) : null,
          compact: true,
        );
      },
    );
  }
}
