import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prophet_profiler/src/core/theme/widgets_theme.dart';
import 'package:prophet_profiler/src/data/models/player_model.dart';

/// Dialog pour sélectionner sur quel joueur parier
/// 
/// Affiche la liste des participants avec leurs photos/noms
/// Soi-même est grisé/désactivé (auto-pari interdit)
class BetSelectionDialog extends StatefulWidget {
  final List<Player> participants;
  final Player currentPlayer;
  final Function(Player) onPlayerSelected;

  const BetSelectionDialog({
    super.key,
    required this.participants,
    required this.currentPlayer,
    required this.onPlayerSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required List<Player> participants,
    required Player currentPlayer,
    required Function(Player) onPlayerSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BetSelectionDialog(
        participants: participants,
        currentPlayer: currentPlayer,
        onPlayerSelected: onPlayerSelected,
      ),
    );
  }

  @override
  State<BetSelectionDialog> createState() => _BetSelectionDialogState();
}

class _BetSelectionDialogState extends State<BetSelectionDialog> {
  Player? _selectedPlayer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.royalIndigo,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
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
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.casino,
                        color: AppColors.gold,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Qui sera le champion ?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sélectionnez un joueur pour placer votre pari',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Info auto-pari interdit
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.rust.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.rust.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.block,
                            size: 16,
                            color: AppColors.rust,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Auto-pari interdit',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.rust,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Liste des participants
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.participants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final player = widget.participants[index];
                    final isCurrentUser = player.id == widget.currentPlayer.id;
                    final isSelected = _selectedPlayer?.id == player.id;

                    return _PlayerBetCard(
                      player: player,
                      isCurrentUser: isCurrentUser,
                      isSelected: isSelected,
                      onTap: isCurrentUser 
                          ? null 
                          : () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedPlayer = player;
                              });
                            },
                    );
                  },
                ),
              ),
              // Bouton de confirmation
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedPlayer != null) ...[
                        Text(
                          'Vous pariez sur : ${_selectedPlayer!.name}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gold,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _selectedPlayer != null
                              ? () {
                                  HapticFeedback.mediumImpact();
                                  _showConfirmationDialog(_selectedPlayer!);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.royalIndigo,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: AppColors.surfaceVariant,
                          ),
                          icon: const Icon(Icons.check_circle),
                          label: Text(
                            _selectedPlayer != null
                                ? 'Parier sur ${_selectedPlayer!.name}'
                                : 'Sélectionnez un joueur',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showConfirmationDialog(Player player) {
    Navigator.pop(context);
    BetConfirmationDialog.show(
      context: context,
      selectedPlayer: player,
      onConfirm: () => widget.onPlayerSelected(player),
    );
  }
}

/// Carte de joueur pour la sélection de pari
class _PlayerBetCard extends StatelessWidget {
  final Player player;
  final bool isCurrentUser;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PlayerBetCard({
    required this.player,
    required this.isCurrentUser,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isCurrentUser ? 0.4 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.gold.withOpacity(0.15) 
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.gold 
                : isCurrentUser 
                    ? AppColors.surfaceVariant 
                    : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? AppColors.gold 
                                : AppColors.cream,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isCurrentUser)
                          Row(
                            children: [
                              Icon(
                                Icons.block,
                                size: 14,
                                color: AppColors.rust,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Vous ne pouvez pas parier sur vous-même',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.rust,
                                ),
                              ),
                            ],
                          )
                        else
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
                  // Checkmark si sélectionné
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.royalIndigo,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.gold : AppColors.surfaceVariant,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
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
          size: 28,
          color: AppColors.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }
}

/// Dialog de confirmation du pari
class BetConfirmationDialog extends StatelessWidget {
  final Player selectedPlayer;
  final VoidCallback onConfirm;

  const BetConfirmationDialog({
    super.key,
    required this.selectedPlayer,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required Player selectedPlayer,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BetConfirmationDialog(
        selectedPlayer: selectedPlayer,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.casino,
                color: AppColors.gold,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            // Titre
            const Text(
              'Confirmer votre pari',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 16),
            // Avatar du joueur sélectionné
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: selectedPlayer.photoUrl != null
                    ? Image.network(
                        selectedPlayer.photoUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.surfaceVariant,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            // Nom du joueur
            Text(
              selectedPlayer.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.cream,
              ),
            ),
            const SizedBox(height: 20),
            // Avertissement
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.rust.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.rust.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.rust,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vous ne pourrez plus modifier ce pari une fois confirmé.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.rust,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.surfaceVariant),
                      foregroundColor: AppColors.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.royalIndigo,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirmer',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
