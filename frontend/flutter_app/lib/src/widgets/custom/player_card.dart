import 'package:flutter/material.dart';
import 'package:prophet_profiler/src/core/theme/widgets_theme.dart';
import 'package:prophet_profiler/src/data/models/player_model.dart';

class PlayerCardList extends StatelessWidget {
  final List<Player> players;
  final Function(Player) onPlayerTap;

  const PlayerCardList({
    super.key,
    required this.players,
    required this.onPlayerTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.gold,
              child: Text(player.name[0].toUpperCase()),
            ),
            title: Text(player.name),
            subtitle: Text('Agg: ${player.profile?.aggressivity ?? 3} | Pat: ${player.profile?.patience ?? 3}'),
            onTap: () => onPlayerTap(player),
          ),
        );
      },
    );
  }
}
