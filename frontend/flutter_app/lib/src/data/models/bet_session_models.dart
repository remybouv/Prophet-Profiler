import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bet_session_models.g.dart';

/// Modèles pour la Page Création Paris

@JsonSerializable()
class AvailablePlayersResponse extends Equatable {
  final List<PlayerSummaryDto> players;
  final int totalCount;

  const AvailablePlayersResponse({
    required this.players,
    required this.totalCount,
  });

  factory AvailablePlayersResponse.fromJson(Map<String, dynamic> json) =>
      _$AvailablePlayersResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AvailablePlayersResponseToJson(this);

  @override
  List<Object?> get props => [players, totalCount];
}

@JsonSerializable()
class PlayerSummaryDto extends Equatable {
  final String id;
  final String name;
  final String? photoUrl;
  final int totalSessions;
  final int totalWins;

  const PlayerSummaryDto({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.totalSessions,
    required this.totalWins,
  });

  factory PlayerSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$PlayerSummaryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerSummaryDtoToJson(this);

  @override
  List<Object?> get props => [id, name, photoUrl, totalSessions, totalWins];
}

@JsonSerializable()
class CreateBetSessionRequest extends Equatable {
  final String boardGameId;
  final List<String> playerIds;
  final DateTime? date;
  final String? location;
  final String? notes;

  const CreateBetSessionRequest({
    required this.boardGameId,
    required this.playerIds,
    this.date,
    this.location,
    this.notes,
  });

  factory CreateBetSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBetSessionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateBetSessionRequestToJson(this);

  @override
  List<Object?> get props => [boardGameId, playerIds, date, location, notes];
}

/// Modèles pour la Page Session Active

@JsonSerializable()
class SessionActiveDetails extends Equatable {
  final String sessionId;
  final String boardGameName;
  final String? boardGameImageUrl;
  final String status; // SessionStatus as string
  final DateTime date;
  final String? location;
  final List<ParticipantBetInfo> participants;
  final List<BetDetailDto> bets;
  final String? currentWinnerId;
  final String? currentWinnerName;
  final int totalPointsInPlay;
  final bool allPlayersHaveBet;
  final bool canStartPlaying;

  const SessionActiveDetails({
    required this.sessionId,
    required this.boardGameName,
    this.boardGameImageUrl,
    required this.status,
    required this.date,
    this.location,
    required this.participants,
    required this.bets,
    this.currentWinnerId,
    this.currentWinnerName,
    required this.totalPointsInPlay,
    required this.allPlayersHaveBet,
    required this.canStartPlaying,
  });

  factory SessionActiveDetails.fromJson(Map<String, dynamic> json) =>
      _$SessionActiveDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$SessionActiveDetailsToJson(this);

  bool get isBetting => status.toLowerCase() == 'betting';
  bool get isPlaying => status.toLowerCase() == 'playing';
  bool get isCompleted => status.toLowerCase() == 'completed';

  @override
  List<Object?> get props => [
        sessionId,
        boardGameName,
        status,
        date,
        participants,
        bets,
        currentWinnerId,
        totalPointsInPlay,
        allPlayersHaveBet,
        canStartPlaying,
      ];
}

@JsonSerializable()
class ParticipantBetInfo extends Equatable {
  final String playerId;
  final String name;
  final String? photoUrl;
  final bool hasPlacedBet;
  final String? betOnPlayerId;
  final String? betOnPlayerName;
  final DateTime? betPlacedAt;

  const ParticipantBetInfo({
    required this.playerId,
    required this.name,
    this.photoUrl,
    required this.hasPlacedBet,
    this.betOnPlayerId,
    this.betOnPlayerName,
    this.betPlacedAt,
  });

  factory ParticipantBetInfo.fromJson(Map<String, dynamic> json) =>
      _$ParticipantBetInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipantBetInfoToJson(this);

  @override
  List<Object?> get props => [
        playerId,
        name,
        photoUrl,
        hasPlacedBet,
        betOnPlayerId,
        betOnPlayerName,
        betPlacedAt,
      ];
}

@JsonSerializable()
class BetDetailDto extends Equatable {
  final String betId;
  final String bettorId;
  final String bettorName;
  final String? bettorPhotoUrl;
  final String predictedWinnerId;
  final String predictedWinnerName;
  final DateTime placedAt;
  final bool? isCorrect;
  final int pointsEarned;

  const BetDetailDto({
    required this.betId,
    required this.bettorId,
    required this.bettorName,
    this.bettorPhotoUrl,
    required this.predictedWinnerId,
    required this.predictedWinnerName,
    required this.placedAt,
    this.isCorrect,
    required this.pointsEarned,
  });

  factory BetDetailDto.fromJson(Map<String, dynamic> json) =>
      _$BetDetailDtoFromJson(json);
  Map<String, dynamic> toJson() => _$BetDetailDtoToJson(this);

  @override
  List<Object?> get props => [
        betId,
        bettorId,
        bettorName,
        predictedWinnerId,
        predictedWinnerName,
        placedAt,
        isCorrect,
        pointsEarned,
      ];
}

/// Modèles pour la sélection du gagnant

@JsonSerializable()
class SetWinnerRequest extends Equatable {
  final String winnerId;

  const SetWinnerRequest({required this.winnerId});

  factory SetWinnerRequest.fromJson(Map<String, dynamic> json) =>
      _$SetWinnerRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SetWinnerRequestToJson(this);

  @override
  List<Object?> get props => [winnerId];
}

@JsonSerializable()
class SetWinnerResponse extends Equatable {
  final String sessionId;
  final String winnerId;
  final String winnerName;
  final String newStatus;
  final List<BetResolutionDto> betResolutions;
  final int totalPointsAwarded;
  final int totalPointsDeducted;

  const SetWinnerResponse({
    required this.sessionId,
    required this.winnerId,
    required this.winnerName,
    required this.newStatus,
    required this.betResolutions,
    required this.totalPointsAwarded,
    required this.totalPointsDeducted,
  });

  factory SetWinnerResponse.fromJson(Map<String, dynamic> json) =>
      _$SetWinnerResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SetWinnerResponseToJson(this);

  @override
  List<Object?> get props => [
        sessionId,
        winnerId,
        winnerName,
        newStatus,
        betResolutions,
        totalPointsAwarded,
        totalPointsDeducted,
      ];
}

@JsonSerializable()
class BetResolutionDto extends Equatable {
  final String bettorId;
  final String bettorName;
  final String? bettorPhotoUrl;
  final String predictedWinnerId;
  final bool isCorrect;
  final int pointsEarned;
  final String resultEmoji;

  const BetResolutionDto({
    required this.bettorId,
    required this.bettorName,
    this.bettorPhotoUrl,
    required this.predictedWinnerId,
    required this.isCorrect,
    required this.pointsEarned,
    required this.resultEmoji,
  });

  factory BetResolutionDto.fromJson(Map<String, dynamic> json) =>
      _$BetResolutionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$BetResolutionDtoToJson(this);

  @override
  List<Object?> get props => [
        bettorId,
        bettorName,
        predictedWinnerId,
        isCorrect,
        pointsEarned,
        resultEmoji,
      ];
}

/// Modèles pour la Homepage

@JsonSerializable()
class ActiveSessionInfo extends Equatable {
  final String? sessionId;
  final String? boardGameName;
  final String? status;
  final DateTime? date;
  final int? participantCount;
  final int? betsPlacedCount;
  final bool hasActiveSession;

  const ActiveSessionInfo({
    this.sessionId,
    this.boardGameName,
    this.status,
    this.date,
    this.participantCount,
    this.betsPlacedCount,
    required this.hasActiveSession,
  });

  factory ActiveSessionInfo.fromJson(Map<String, dynamic> json) =>
      _$ActiveSessionInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ActiveSessionInfoToJson(this);

  @override
  List<Object?> get props => [
        sessionId,
        boardGameName,
        status,
        date,
        participantCount,
        betsPlacedCount,
        hasActiveSession,
      ];
}

@JsonSerializable()
class HomepageDataResponse extends Equatable {
  final ActiveSessionInfo? activeSession;
  final int totalPlayers;
  final int totalGames;
  final List<RecentSessionDto> recentSessions;

  const HomepageDataResponse({
    this.activeSession,
    required this.totalPlayers,
    required this.totalGames,
    required this.recentSessions,
  });

  factory HomepageDataResponse.fromJson(Map<String, dynamic> json) =>
      _$HomepageDataResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HomepageDataResponseToJson(this);

  @override
  List<Object?> get props => [
        activeSession,
        totalPlayers,
        totalGames,
        recentSessions,
      ];
}

@JsonSerializable()
class RecentSessionDto extends Equatable {
  final String sessionId;
  final String boardGameName;
  final DateTime date;
  final String status;
  final String? winnerName;

  const RecentSessionDto({
    required this.sessionId,
    required this.boardGameName,
    required this.date,
    required this.status,
    this.winnerName,
  });

  factory RecentSessionDto.fromJson(Map<String, dynamic> json) =>
      _$RecentSessionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RecentSessionDtoToJson(this);

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isActive => 
      status.toLowerCase() == 'betting' || status.toLowerCase() == 'playing';

  @override
  List<Object?> get props => [
        sessionId,
        boardGameName,
        date,
        status,
        winnerName,
      ];
}

/// Requête pour placer un pari (format API)
@JsonSerializable()
class PlaceBetRequestV2 extends Equatable {
  final String bettorId;
  final String predictedWinnerId;

  const PlaceBetRequestV2({
    required this.bettorId,
    required this.predictedWinnerId,
  });

  factory PlaceBetRequestV2.fromJson(Map<String, dynamic> json) =>
      _$PlaceBetRequestV2FromJson(json);
  Map<String, dynamic> toJson() => _$PlaceBetRequestV2ToJson(this);

  @override
  List<Object?> get props => [bettorId, predictedWinnerId];
}
