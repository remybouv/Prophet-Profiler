import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prophet_profiler/src/core/theme/widgets_theme.dart';
import 'package:prophet_profiler/src/presentation/blocs/bet_creation_bloc.dart';
import 'package:prophet_profiler/src/presentation/pages/active_session_page.dart';

/// Page Création Paris V2
/// 
/// Nouveau workflow unifié:
/// 1. Sélection du jeu (dropdown)
/// 2. Sélection des joueurs (multi-select avec grid/list)
/// 3. Date et lieu optionnels
/// 4. Création directe en mode Betting
/// 
/// NOTE: UI finale à compléter avec wireframes Baldwin
class BetCreationPage extends StatelessWidget {
  const BetCreationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BetCreationBloc(),
      child: const _BetCreationPageView(),
    );
  }
}

class _BetCreationPageView extends StatefulWidget {
  const _BetCreationPageView();

  @override
  State<_BetCreationPageView> createState() => _BetCreationPageViewState();
}

class _BetCreationPageViewState extends State<_BetCreationPageView> {
  @override
  void initState() {
    super.initState();
    // Charger les données initiales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BetCreationBloc>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalIndigo,
      appBar: AppBar(
        title: const Text('Nouvelle Session'),
        centerTitle: true,
      ),
      body: Consumer<BetCreationBloc>(
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

          return _buildForm(state);
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
            onPressed: () => context.read<BetCreationBloc>().loadInitialData(),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BetCreationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 24),

          // Sélection du jeu
          _buildGameSelector(state),
          const SizedBox(height: 24),

          // Sélection des joueurs
          _buildPlayerSelector(state),
          const SizedBox(height: 24),

          // Date et lieu (optionnels)
          _buildOptionalFields(state),
          const SizedBox(height: 32),

          // Bouton créer
          _buildCreateButton(state),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.casino, size: 48, color: AppColors.gold),
          const SizedBox(height: 12),
          const Text(
            'Nouvelle Session de Paris',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez un jeu et les participants',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGameSelector(BetCreationState state) {
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
              const Icon(Icons.sports_esports, color: AppColors.gold),
              const SizedBox(width: 8),
              const Text(
                'Jeu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: state.selectedGameId,
            hint: const Text('Sélectionnez un jeu'),
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
            items: state.availableGames.map((game) {
              return DropdownMenuItem<String>(
                value: game['id']?.toString() ?? '',
                child: Text(game['name']?.toString() ?? 'Jeu inconnu'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<BetCreationBloc>().selectGame(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSelector(BetCreationState state) {
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
              const Text(
                'Participants',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
              const Spacer(),
              Text(
                '${state.selectedPlayerIds.length} sélectionné(s)',
                style: TextStyle(
                  fontSize: 14,
                  color: state.hasMinimumPlayers 
                      ? AppColors.teal 
                      : AppColors.rust,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!state.hasMinimumPlayers)
            Text(
              'Minimum 2 joueurs requis',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.rust.withOpacity(0.8),
              ),
            ),
          const SizedBox(height: 12),
          // Grid de sélection des joueurs
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.availablePlayers.map((player) {
              final isSelected = state.selectedPlayerIds.contains(player.id);
              return _PlayerChip(
                name: player.name,
                photoUrl: player.photoUrl,
                isSelected: isSelected,
                onTap: () => context.read<BetCreationBloc>().togglePlayerSelection(player.id),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalFields(BetCreationState state) {
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
              const Icon(Icons.settings, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              const Text(
                'Options (optionnel)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Date
          ListTile(
            leading: const Icon(Icons.calendar_today, color: AppColors.gold),
            title: Text(
              state.selectedDate != null
                  ? '${state.selectedDate!.day}/${state.selectedDate!.month}/${state.selectedDate!.year}'
                  : 'Aujourd\'hui',
              style: const TextStyle(color: AppColors.cream),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                context.read<BetCreationBloc>().setDate(date);
              }
            },
          ),
          // Lieu
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.location_on, color: AppColors.gold),
              hintText: 'Lieu (optionnel)',
              hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.5)),
              filled: true,
              fillColor: AppColors.royalIndigo.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: AppColors.cream),
            onChanged: (value) => context.read<BetCreationBloc>().setLocation(value),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(BetCreationState state) {
    return ElevatedButton.icon(
      onPressed: state.canCreate
          ? () async {
              final session = await context.read<BetCreationBloc>().createSession();
              if (session != null && mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActiveSessionPage(sessionId: session.sessionId),
                  ),
                );
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.royalIndigo,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBackgroundColor: AppColors.gold.withOpacity(0.3),
      ),
      icon: state.isCreating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.royalIndigo,
              ),
            )
          : const Icon(Icons.casino),
      label: Text(
        state.isCreating ? 'Création...' : 'Créer la Session',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Widget pour un joueur sélectionnable
class _PlayerChip extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlayerChip({
    required this.name,
    this.photoUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.gold.withOpacity(0.2) 
              : AppColors.royalIndigo.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.gold : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (photoUrl != null)
              CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(photoUrl!),
              )
            else
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.gold.withOpacity(0.3),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? AppColors.gold : AppColors.cream,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, color: AppColors.gold, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
