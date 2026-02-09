import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import '../../../core/theme/widgets_theme.dart';
import '../../../data/models/player_model.dart';
import '../../../services/api_service.dart';
import 'session_page.dart';

/// Page de création de session avec sélection des participants
/// 
/// Étapes :
/// 1. Choisir le jeu
/// 2. Sélectionner les participants (minimum 2)
/// 3. Créer la session et démarrer les paris
class NewSessionPage extends StatefulWidget {
  const NewSessionPage({super.key});

  @override
  State<NewSessionPage> createState() => _NewSessionPageState();
}

class _NewSessionPageState extends State<NewSessionPage> {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  Future<void> _createSession() async {
    if (_selectedPlayers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez au moins 2 joueurs'),
          backgroundColor: AppColors.rust,
        ),
      );
      return;
    }

    if (_selectedGameId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez un jeu'),
          backgroundColor: AppColors.rust,
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
        HapticFeedback.mediumImpact();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SessionPage(
              sessionId: response['id']?.toString(),
            ),
          ),
        );
      }

      developer.log('✅ Session créée avec ${_selectedPlayers.length} participants', name: 'NewSessionPage');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.rust,
          ),
        );
      }
      developer.log('❌ Erreur création session: $e', name: 'NewSessionPage');
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

  void _selectAll() {
    setState(() {
      _selectedPlayers = List.from(_players);
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedPlayers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalIndigo,
      appBar: AppBar(
        title: const Text('Nouvelle Session'),
        actions: [
          if (!_isLoading && _players.isNotEmpty)
            TextButton.icon(
              onPressed: _selectedPlayers.length == _players.length ? _deselectAll : _selectAll,
              icon: Icon(
                _selectedPlayers.length == _players.length ? Icons.deselect : Icons.select_all,
                color: AppColors.gold,
              ),
              label: Text(
                _selectedPlayers.length == _players.length ? 'Tout désélec.' : 'Tout sélec.',
                style: const TextStyle(color: AppColors.gold),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header avec infos
        _buildHeader(),
        const SizedBox(height: 16),
        // Sélection du jeu
        _buildGameSelection(),
        const SizedBox(height: 16),
        // Sélection des joueurs
        _buildPlayerSelection(),
        // Bouton créer
        _buildCreateButton(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nouvelle session de jeu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cream,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sélectionnez un jeu et les participants',
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
        ],
      ),
    );
  }

  Widget _buildGameSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.videogame_asset, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Jeu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                ),
              ),
              const Spacer(),
              if (_selectedGameId != null)
                TextButton.icon(
                  onPressed: () => setState(() => _selectedGameId = null),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Modifier'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_games.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: AppColors.rust),
                  SizedBox(width: 12),
                  Text(
                    'Aucun jeu disponible',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
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
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerSelection() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: AppColors.gold, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Participants',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _selectedPlayers.length >= 2
                        ? AppColors.teal.withOpacity(0.2)
                        : AppColors.rust.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedPlayers.length}/${_players.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedPlayers.length >= 2
                          ? AppColors.teal
                          : AppColors.rust,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                // Indicateur visuel si minimum atteint
                if (_selectedPlayers.length < 2)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber, size: 14, color: AppColors.rust.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        'Min: 2',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.rust.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_players.isEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 48, color: AppColors.onSurfaceVariant),
                        SizedBox(height: 12),
                        Text(
                          'Aucun joueur disponible',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _players.length,
                  padding: const EdgeInsets.only(bottom: 8),
                  itemBuilder: (context, index) {
                    final player = _players[index];
                    final isSelected = _selectedPlayers.contains(player);
                    
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.gold.withOpacity(0.1)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.gold.withOpacity(0.5)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) => _togglePlayer(player),
                        title: Text(
                          player.name,
                          style: TextStyle(
                            color: AppColors.cream,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        subtitle: isSelected
                            ? const Text(
                                'Participant',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gold,
                                ),
                              )
                            : null,
                        secondary: CircleAvatar(
                          radius: 22,
                          backgroundImage: player.photoUrl != null
                              ? NetworkImage(player.photoUrl!)
                              : null,
                          backgroundColor: AppColors.surfaceVariant,
                          child: player.photoUrl == null
                              ? const Icon(Icons.person, color: AppColors.onSurfaceVariant)
                              : null,
                        ),
                        activeColor: AppColors.gold,
                        checkColor: AppColors.royalIndigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    final isValid = _selectedPlayers.length >= 2 && _selectedGameId != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Résumé de la sélection
            if (isValid)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.teal, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedPlayers.length} joueurs prêts',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _selectedGameId == null
                      ? 'Sélectionnez un jeu'
                      : 'Sélectionnez au moins 2 joueurs',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isCreating || !isValid ? null : _createSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.royalIndigo,
                  disabledBackgroundColor: AppColors.surfaceVariant,
                  disabledForegroundColor: AppColors.onSurfaceVariant.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isValid ? 4 : 0,
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
                      : 'Démarrer la session',
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
    );
  }
}
