import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prophet_profiler/src/core/theme/widgets_theme.dart';
import 'package:prophet_profiler/src/presentation/blocs/homepage_bloc.dart';
import 'package:prophet_profiler/src/presentation/pages/bet_creation_page.dart';
import 'package:prophet_profiler/src/presentation/pages/active_session_page.dart';
import 'package:prophet_profiler/src/presentation/pages/players_page.dart';
import 'package:prophet_profiler/src/presentation/pages/games_page.dart';
import 'package:prophet_profiler/src/presentation/pages/rankings_page.dart';

/// Homepage avec boutons conditionnels
/// 
/// Features:
/// - Bouton "Session Active" (disabled si pas de session)
/// - Bouton "Nouvelle Session" (toujours actif)
/// - Affichage de la session en cours si existe
/// - Activité récente
/// 
/// NOTE: UI finale à compléter avec wireframes Baldwin
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomepageBloc(),
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatefulWidget {
  const _HomePageView();

  @override
  State<_HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<HomepageBloc>();
      bloc.loadData();
      bloc.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    context.read<HomepageBloc>().stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalIndigo,
      appBar: AppBar(
        title: const Text('Prophet & Profiler'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.read<HomepageBloc>().refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<HomepageBloc>(
        builder: (context, bloc, child) {
          final state = bloc.state;

          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }

          return RefreshIndicator(
            onRefresh: () => bloc.refresh(),
            color: AppColors.gold,
            backgroundColor: AppColors.surface,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 24),

                // Session Active Card (si existe)
                if (state.hasActiveSession) ...[
                  _buildActiveSessionCard(state),
                  const SizedBox(height: 24),
                ],

                // Actions principales
                _buildQuickActions(state),
                const SizedBox(height: 24),

                // Statistiques rapides
                _buildQuickStats(state),
                const SizedBox(height: 24),

                // Sessions récentes
                _buildRecentSessions(state),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) => _onNavigationSelected(index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Joueurs'),
          NavigationDestination(icon: Icon(Icons.casino), label: 'Jeux'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Classements'),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
          color: AppColors.gold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.casino,
              size: 48,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Qui sera le champion de ce soir ?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Pariez sur le vainqueur et gagnez des points !',
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

  Widget _buildActiveSessionCard(HomepageState state) {
    final session = state.activeSession!;
    final isBetting = session.status?.toLowerCase() == 'betting';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBetting ? AppColors.gold : AppColors.teal,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isBetting ? AppColors.gold : AppColors.teal).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isBetting ? AppColors.gold : AppColors.teal).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state.activeSessionStatusText,
                  style: TextStyle(
                    color: isBetting ? AppColors.gold : AppColors.teal,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActiveSessionPage(
                        sessionId: state.activeSessionId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, color: AppColors.gold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            session.boardGameName ?? 'Session active',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${session.participantCount} participants • ${state.betsStatusText}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActiveSessionPage(
                    sessionId: state.activeSessionId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isBetting ? AppColors.gold : AppColors.teal,
              foregroundColor: AppColors.royalIndigo,
              minimumSize: const Size(double.infinity, 48),
            ),
            icon: Icon(isBetting ? Icons.casino : Icons.play_arrow),
            label: Text(isBetting ? 'Placer mon pari' : 'Voir la partie'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(HomepageState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.cream,
          ),
        ),
        const SizedBox(height: 16),
        
        // Bouton Session Active (conditionnel)
        if (state.hasActiveSession)
          ElevatedButton.icon(
            onPressed: () {
              developer.log('🎲 Navigation Session Active', name: 'HomePage');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActiveSessionPage(
                    sessionId: state.activeSessionId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.royalIndigo,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.casino),
            label: const Text(
              'Session active',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          )
        else
          // Bouton disabled si pas de session active
          ElevatedButton.icon(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold.withOpacity(0.3),
              foregroundColor: AppColors.onSurfaceVariant,
              disabledBackgroundColor: AppColors.surface,
              disabledForegroundColor: AppColors.onSurfaceVariant.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.casino_outlined),
            label: Column(
              children: [
                const Text(
                  'Session active',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  'Aucune session en cours',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 12),
        
        // Bouton Nouvelle Session (toujours actif)
        OutlinedButton.icon(
          onPressed: () {
            developer.log('➕ Navigation Nouvelle Session', name: 'HomePage');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BetCreationPage()),
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.gold),
            foregroundColor: AppColors.gold,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text(
            'Nouvelle Session',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(HomepageState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.people,
            value: state.totalPlayers.toString(),
            label: 'Joueurs',
          ),
          _buildStatItem(
            icon: Icons.casino,
            value: state.totalGames.toString(),
            label: 'Jeux',
          ),
          _buildStatItem(
            icon: Icons.emoji_events,
            value: state.recentSessions.where((s) => s.isCompleted).length.toString(),
            label: 'Parties',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.gold, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.cream,
            fontSize: 20,
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

  Widget _buildRecentSessions(HomepageState state) {
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
              const Icon(Icons.history, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Sessions récentes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.recentSessions.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.casino_outlined,
                    size: 48,
                    color: AppColors.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune session récente',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            )
          else
            ...state.recentSessions.take(3).map((session) => _buildSessionItem(session)),
        ],
      ),
    );
  }

  Widget _buildSessionItem(RecentSessionDto session) {
    final isCompleted = session.isCompleted;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.teal.withOpacity(0.2)
              : AppColors.gold.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isCompleted ? Icons.check_circle : Icons.casino,
          color: isCompleted ? AppColors.teal : AppColors.gold,
        ),
      ),
      title: Text(
        session.boardGameName,
        style: const TextStyle(
          color: AppColors.cream,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        isCompleted && session.winnerName != null
            ? '🏆 ${session.winnerName}'
            : '${session.date.day}/${session.date.month}/${session.date.year}',
        style: TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }

  void _onNavigationSelected(int index) {
    developer.log('📱 Navigation vers index: $index', name: 'HomePage');
    switch (index) {
      case 0: // Accueil - déjà là
        break;
      case 1: // Joueurs
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PlayersPage()),
        );
        break;
      case 2: // Jeux
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GamesPage()),
        );
        break;
      case 3: // Classements
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RankingsPage()),
        );
        break;
    }
  }
}
