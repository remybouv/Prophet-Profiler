// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bet_session_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailablePlayersResponse _$AvailablePlayersResponseFromJson(
        Map<String, dynamic> json) =>
    AvailablePlayersResponse(
      players: (json['players'] as List<dynamic>)
          .map((e) => PlayerSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
    );

Map<String, dynamic> _$AvailablePlayersResponseToJson(
        AvailablePlayersResponse instance) =>
    <String, dynamic>{
      'players': instance.players.map((e) => e.toJson()).toList(),
      'totalCount': instance.totalCount,
    };

PlayerSummaryDto _$PlayerSummaryDtoFromJson(Map<String, dynamic> json) =>
    PlayerSummaryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      totalSessions: (json['totalSessions'] as num).toInt(),
      totalWins: (json['totalWins'] as num).toInt(),
    );

Map<String, dynamic> _$PlayerSummaryDtoToJson(PlayerSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'photoUrl': instance.photoUrl,
      'totalSessions': instance.totalSessions,
      'totalWins': instance.totalWins,
    };

CreateBetSessionRequest _$CreateBetSessionRequestFromJson(
        Map<String, dynamic> json) =>
    CreateBetSessionRequest(
      boardGameId: json['boardGameId'] as String,
      playerIds: (json['playerIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CreateBetSessionRequestToJson(
        CreateBetSessionRequest instance) =>
    <String, dynamic>{
      'boardGameId': instance.boardGameId,
      'playerIds': instance.playerIds,
      'date': instance.date?.toIso8601String(),
      'location': instance.location,
      'notes': instance.notes,
    };

SessionActiveDetails _$SessionActiveDetailsFromJson(
        Map<String, dynamic> json) =>
    SessionActiveDetails(
      sessionId: json['sessionId'] as String,
      boardGameName: json['boardGameName'] as String,
      boardGameImageUrl: json['boardGameImageUrl'] as String?,
      status: json['status'] as String,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String?,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => ParticipantBetInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      bets: (json['bets'] as List<dynamic>)
          .map((e) => BetDetailDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentWinnerId: json['currentWinnerId'] as String?,
      currentWinnerName: json['currentWinnerName'] as String?,
      totalPointsInPlay: (json['totalPointsInPlay'] as num).toInt(),
      allPlayersHaveBet: json['allPlayersHaveBet'] as bool,
      canStartPlaying: json['canStartPlaying'] as bool,
    );

Map<String, dynamic> _$SessionActiveDetailsToJson(
        SessionActiveDetails instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'boardGameName': instance.boardGameName,
      'boardGameImageUrl': instance.boardGameImageUrl,
      'status': instance.status,
      'date': instance.date.toIso8601String(),
      'location': instance.location,
      'participants': instance.participants.map((e) => e.toJson()).toList(),
      'bets': instance.bets.map((e) => e.toJson()).toList(),
      'currentWinnerId': instance.currentWinnerId,
      'currentWinnerName': instance.currentWinnerName,
      'totalPointsInPlay': instance.totalPointsInPlay,
      'allPlayersHaveBet': instance.allPlayersHaveBet,
      'canStartPlaying': instance.canStartPlaying,
    };

ParticipantBetInfo _$ParticipantBetInfoFromJson(Map<String, dynamic> json) =>
    ParticipantBetInfo(
      playerId: json['playerId'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      hasPlacedBet: json['hasPlacedBet'] as bool,
      betOnPlayerId: json['betOnPlayerId'] as String?,
      betOnPlayerName: json['betOnPlayerName'] as String?,
      betPlacedAt: json['betPlacedAt'] == null
          ? null
          : DateTime.parse(json['betPlacedAt'] as String),
    );

Map<String, dynamic> _$ParticipantBetInfoToJson(
        ParticipantBetInfo instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'name': instance.name,
      'photoUrl': instance.photoUrl,
      'hasPlacedBet': instance.hasPlacedBet,
      'betOnPlayerId': instance.betOnPlayerId,
      'betOnPlayerName': instance.betOnPlayerName,
      'betPlacedAt': instance.betPlacedAt?.toIso8601String(),
    };

BetDetailDto _$BetDetailDtoFromJson(Map<String, dynamic> json) =>
    BetDetailDto(
      betId: json['betId'] as String,
      bettorId: json['bettorId'] as String,
      bettorName: json['bettorName'] as String,
      bettorPhotoUrl: json['bettorPhotoUrl'] as String?,
      predictedWinnerId: json['predictedWinnerId'] as String,
      predictedWinnerName: json['predictedWinnerName'] as String,
      placedAt: DateTime.parse(json['placedAt'] as String),
      isCorrect: json['isCorrect'] as bool?,
      pointsEarned: (json['pointsEarned'] as num).toInt(),
    );

Map<String, dynamic> _$BetDetailDtoToJson(BetDetailDto instance) =>
    <String, dynamic>{
      'betId': instance.betId,
      'bettorId': instance.bettorId,
      'bettorName': instance.bettorName,
      'bettorPhotoUrl': instance.bettorPhotoUrl,
      'predictedWinnerId': instance.predictedWinnerId,
      'predictedWinnerName': instance.predictedWinnerName,
      'placedAt': instance.placedAt.toIso8601String(),
      'isCorrect': instance.isCorrect,
      'pointsEarned': instance.pointsEarned,
    };

SetWinnerRequest _$SetWinnerRequestFromJson(Map<String, dynamic> json) =>
    SetWinnerRequest(
      winnerId: json['winnerId'] as String,
    );

Map<String, dynamic> _$SetWinnerRequestToJson(SetWinnerRequest instance) =>
    <String, dynamic>{
      'winnerId': instance.winnerId,
    };

SetWinnerResponse _$SetWinnerResponseFromJson(Map<String, dynamic> json) =>
    SetWinnerResponse(
      sessionId: json['sessionId'] as String,
      winnerId: json['winnerId'] as String,
      winnerName: json['winnerName'] as String,
      newStatus: json['newStatus'] as String,
      betResolutions: (json['betResolutions'] as List<dynamic>)
          .map((e) => BetResolutionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPointsAwarded: (json['totalPointsAwarded'] as num).toInt(),
      totalPointsDeducted: (json['totalPointsDeducted'] as num).toInt(),
    );

Map<String, dynamic> _$SetWinnerResponseToJson(SetWinnerResponse instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'winnerId': instance.winnerId,
      'winnerName': instance.winnerName,
      'newStatus': instance.newStatus,
      'betResolutions':
          instance.betResolutions.map((e) => e.toJson()).toList(),
      'totalPointsAwarded': instance.totalPointsAwarded,
      'totalPointsDeducted': instance.totalPointsDeducted,
    };

BetResolutionDto _$BetResolutionDtoFromJson(Map<String, dynamic> json) =>
    BetResolutionDto(
      bettorId: json['bettorId'] as String,
      bettorName: json['bettorName'] as String,
      bettorPhotoUrl: json['bettorPhotoUrl'] as String?,
      predictedWinnerId: json['predictedWinnerId'] as String,
      isCorrect: json['isCorrect'] as bool,
      pointsEarned: (json['pointsEarned'] as num).toInt(),
      resultEmoji: json['resultEmoji'] as String,
    );

Map<String, dynamic> _$BetResolutionDtoToJson(BetResolutionDto instance) =>
    <String, dynamic>{
      'bettorId': instance.bettorId,
      'bettorName': instance.bettorName,
      'bettorPhotoUrl': instance.bettorPhotoUrl,
      'predictedWinnerId': instance.predictedWinnerId,
      'isCorrect': instance.isCorrect,
      'pointsEarned': instance.pointsEarned,
      'resultEmoji': instance.resultEmoji,
    };

ActiveSessionInfo _$ActiveSessionInfoFromJson(Map<String, dynamic> json) =>
    ActiveSessionInfo(
      sessionId: json['sessionId'] as String?,
      boardGameName: json['boardGameName'] as String?,
      status: json['status'] as String?,
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
      participantCount: (json['participantCount'] as num?)?.toInt(),
      betsPlacedCount: (json['betsPlacedCount'] as num?)?.toInt(),
      hasActiveSession: json['hasActiveSession'] as bool,
    );

Map<String, dynamic> _$ActiveSessionInfoToJson(ActiveSessionInfo instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'boardGameName': instance.boardGameName,
      'status': instance.status,
      'date': instance.date?.toIso8601String(),
      'participantCount': instance.participantCount,
      'betsPlacedCount': instance.betsPlacedCount,
      'hasActiveSession': instance.hasActiveSession,
    };

HomepageDataResponse _$HomepageDataResponseFromJson(
        Map<String, dynamic> json) =>
    HomepageDataResponse(
      activeSession: json['activeSession'] == null
          ? null
          : ActiveSessionInfo.fromJson(
              json['activeSession'] as Map<String, dynamic>),
      totalPlayers: (json['totalPlayers'] as num).toInt(),
      totalGames: (json['totalGames'] as num).toInt(),
      recentSessions: (json['recentSessions'] as List<dynamic>)
          .map((e) => RecentSessionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HomepageDataResponseToJson(
        HomepageDataResponse instance) =>
    <String, dynamic>{
      'activeSession': instance.activeSession?.toJson(),
      'totalPlayers': instance.totalPlayers,
      'totalGames': instance.totalGames,
      'recentSessions':
          instance.recentSessions.map((e) => e.toJson()).toList(),
    };

RecentSessionDto _$RecentSessionDtoFromJson(Map<String, dynamic> json) =>
    RecentSessionDto(
      sessionId: json['sessionId'] as String,
      boardGameName: json['boardGameName'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      winnerName: json['winnerName'] as String?,
    );

Map<String, dynamic> _$RecentSessionDtoToJson(RecentSessionDto instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'boardGameName': instance.boardGameName,
      'date': instance.date.toIso8601String(),
      'status': instance.status,
      'winnerName': instance.winnerName,
    };

PlaceBetRequestV2 _$PlaceBetRequestV2FromJson(Map<String, dynamic> json) =>
    PlaceBetRequestV2(
      bettorId: json['bettorId'] as String,
      predictedWinnerId: json['predictedWinnerId'] as String,
    );

Map<String, dynamic> _$PlaceBetRequestV2ToJson(PlaceBetRequestV2 instance) =>
    <String, dynamic>{
      'bettorId': instance.bettorId,
      'predictedWinnerId': instance.predictedWinnerId,
    };
