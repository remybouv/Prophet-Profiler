import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bet_model.g.dart';

/// Statut d'une session de jeu
enum SessionStatus {
  @JsonValue('Planning')
  planning,
  @JsonValue('Betting')
  betting,
  @JsonValue('InProgress')
  inProgress,
  @JsonValue('Completed')
  completed,
}

extension SessionStatusExtension on SessionStatus {
  String get displayName {
    switch (this) {
      case SessionStatus.planning:
        return 'Planification';
      case SessionStatus.betting:
        return 'Paris ouverts';
      case SessionStatus.inProgress:
        return 'En cours';
      case SessionStatus.completed:
        return 'Terminée';
    }
  }

  bool get canPlaceBets => this == SessionStatus.betting;
  bool get canViewResults => this == SessionStatus.completed;
}

/// Modèle représentant un pari
@JsonSerializable()
class Bet extends Equatable {
  final String id;
  final String sessionId;
  final String bettorId;
  final String bettorName;
  final String? bettorPhotoUrl;
  final String predictedWinnerId;
  final String predictedWinnerName;
  final String? predictedWinnerPhotoUrl;
  final DateTime placedAt;

  const Bet({
    required this.id,
    required this.sessionId,
    required this.bettorId,
    required this.bettorName,
    this.bettorPhotoUrl,
    required this.predictedWinnerId,
    required this.predictedWinnerName,
    this.predictedWinnerPhotoUrl,
    required this.placedAt,
  });

  factory Bet.fromJson(Map<String, dynamic> json) => _$BetFromJson(json);
  Map<String, dynamic> toJson() => _$BetToJson(this);

  @override
  List<Object?> get props => [
        id,
        sessionId,
        bettorId,
        bettorName,
        predictedWinnerId,
        predictedWinnerName,
        placedAt,
      ];
}

/// Résumé des paris d'une session
@JsonSerializable()
class BetsSummary extends Equatable {
  final String sessionId;
  final SessionStatus sessionStatus;
  final int totalBets;
  final int totalParticipants;
  final List<Bet> bets;
  final String? currentUserBetOn;
  final String? actualWinnerId;
  final String? actualWinnerName;

  const BetsSummary({
    required this.sessionId,
    required this.sessionStatus,
    required this.totalBets,
    required this.totalParticipants,
    required this.bets,
    this.currentUserBetOn,
    this.actualWinnerId,
    this.actualWinnerName,
  });

  factory BetsSummary.fromJson(Map<String, dynamic> json) =>
      _$BetsSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$BetsSummaryToJson(this);

  /// Pourcentage de participants ayant parié
  double get participationRate =>
      totalParticipants > 0 ? totalBets / totalParticipants : 0;

  /// Vérifier si un joueur a parié
  bool hasPlayerBet(String playerId) =>
      bets.any((bet) => bet.bettorId == playerId);

  /// Récupérer le pari d'un joueur
  Bet? getBetByPlayer(String playerId) =>
      bets.where((bet) => bet.bettorId == playerId).firstOrNull;

  @override
  List<Object?> get props => [
        sessionId,
        sessionStatus,
        totalBets,
        totalParticipants,
        bets,
        currentUserBetOn,
        actualWinnerId,
        actualWinnerName,
      ];
}

/// Historique des paris d'un joueur
@JsonSerializable()
class BetHistory extends Equatable {
  final String playerId;
  final String playerName;
  final int totalBets;
  final int wonBets;
  final int lostBets;
  final double winRate;
  final List<BetHistoryItem> history;

  const BetHistory({
    required this.playerId,
    required this.playerName,
    required this.totalBets,
    required this.wonBets,
    required this.lostBets,
    required this.winRate,
    required this.history,
  });

  factory BetHistory.fromJson(Map<String, dynamic> json) =>
      _$BetHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$BetHistoryToJson(this);

  @override
  List<Object?> get props => [
        playerId,
        playerName,
        totalBets,
        wonBets,
        lostBets,
        winRate,
        history,
      ];
}

/// Élément d'historique de pari
@JsonSerializable()
class BetHistoryItem extends Equatable {
  final String betId;
  final String sessionId;
  final String gameName;
  final DateTime sessionDate;
  final String predictedWinnerId;
  final String predictedWinnerName;
  final String? actualWinnerId;
  final String? actualWinnerName;
  final bool? isWin;
  final int pointsEarned;

  const BetHistoryItem({
    required this.betId,
    required this.sessionId,
    required this.gameName,
    required this.sessionDate,
    required this.predictedWinnerId,
    required this.predictedWinnerName,
    this.actualWinnerId,
    this.actualWinnerName,
    this.isWin,
    required this.pointsEarned,
  });

  factory BetHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$BetHistoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$BetHistoryItemToJson(this);

  bool get isCompleted => isWin != null;
  bool get hasWon => isWin == true;

  @override
  List<Object?> get props => [
        betId,
        sessionId,
        gameName,
        sessionDate,
        predictedWinnerId,
        predictedWinnerName,
        actualWinnerId,
        actualWinnerName,
        isWin,
        pointsEarned,
      ];
}

/// Requête pour placer un pari
@JsonSerializable()
class PlaceBetRequest extends Equatable {
  final String bettorId;
  final String predictedWinnerId;

  const PlaceBetRequest({
    required this.bettorId,
    required this.predictedWinnerId,
  });

  factory PlaceBetRequest.fromJson(Map<String, dynamic> json) =>
      _$PlaceBetRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PlaceBetRequestToJson(this);

  @override
  List<Object?> get props => [bettorId, predictedWinnerId];
}
