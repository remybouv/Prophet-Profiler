// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bet _$BetFromJson(Map<String, dynamic> json) => Bet(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      bettorId: json['bettorId'] as String,
      bettorName: json['bettorName'] as String,
      bettorPhotoUrl: json['bettorPhotoUrl'] as String?,
      predictedWinnerId: json['predictedWinnerId'] as String,
      predictedWinnerName: json['predictedWinnerName'] as String,
      predictedWinnerPhotoUrl: json['predictedWinnerPhotoUrl'] as String?,
      placedAt: DateTime.parse(json['placedAt'] as String),
    );

Map<String, dynamic> _$BetToJson(Bet instance) => <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'bettorId': instance.bettorId,
      'bettorName': instance.bettorName,
      'bettorPhotoUrl': instance.bettorPhotoUrl,
      'predictedWinnerId': instance.predictedWinnerId,
      'predictedWinnerName': instance.predictedWinnerName,
      'predictedWinnerPhotoUrl': instance.predictedWinnerPhotoUrl,
      'placedAt': instance.placedAt.toIso8601String(),
    };

BetsSummary _$BetsSummaryFromJson(Map<String, dynamic> json) => BetsSummary(
      sessionId: json['sessionId'] as String,
      sessionStatus: $enumDecode(_$SessionStatusEnumMap, json['sessionStatus']),
      totalBets: (json['totalBets'] as num).toInt(),
      totalParticipants: (json['totalParticipants'] as num).toInt(),
      bets: (json['bets'] as List<dynamic>)
          .map((e) => Bet.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentUserBetOn: json['currentUserBetOn'] as String?,
      actualWinnerId: json['actualWinnerId'] as String?,
      actualWinnerName: json['actualWinnerName'] as String?,
    );

Map<String, dynamic> _$BetsSummaryToJson(BetsSummary instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'sessionStatus': _$SessionStatusEnumMap[instance.sessionStatus]!,
      'totalBets': instance.totalBets,
      'totalParticipants': instance.totalParticipants,
      'bets': instance.bets.map((e) => e.toJson()).toList(),
      'currentUserBetOn': instance.currentUserBetOn,
      'actualWinnerId': instance.actualWinnerId,
      'actualWinnerName': instance.actualWinnerName,
    };

const _$SessionStatusEnumMap = {
  SessionStatus.planning: 'Planning',
  SessionStatus.betting: 'Betting',
  SessionStatus.inProgress: 'InProgress',
  SessionStatus.completed: 'Completed',
};

BetHistory _$BetHistoryFromJson(Map<String, dynamic> json) => BetHistory(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      totalBets: (json['totalBets'] as num).toInt(),
      wonBets: (json['wonBets'] as num).toInt(),
      lostBets: (json['lostBets'] as num).toInt(),
      winRate: (json['winRate'] as num).toDouble(),
      history: (json['history'] as List<dynamic>)
          .map((e) => BetHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BetHistoryToJson(BetHistory instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'totalBets': instance.totalBets,
      'wonBets': instance.wonBets,
      'lostBets': instance.lostBets,
      'winRate': instance.winRate,
      'history': instance.history.map((e) => e.toJson()).toList(),
    };

BetHistoryItem _$BetHistoryItemFromJson(Map<String, dynamic> json) =>
    BetHistoryItem(
      betId: json['betId'] as String,
      sessionId: json['sessionId'] as String,
      gameName: json['gameName'] as String,
      sessionDate: DateTime.parse(json['sessionDate'] as String),
      predictedWinnerId: json['predictedWinnerId'] as String,
      predictedWinnerName: json['predictedWinnerName'] as String,
      actualWinnerId: json['actualWinnerId'] as String?,
      actualWinnerName: json['actualWinnerName'] as String?,
      isWin: json['isWin'] as bool?,
      pointsEarned: (json['pointsEarned'] as num).toInt(),
    );

Map<String, dynamic> _$BetHistoryItemToJson(BetHistoryItem instance) =>
    <String, dynamic>{
      'betId': instance.betId,
      'sessionId': instance.sessionId,
      'gameName': instance.gameName,
      'sessionDate': instance.sessionDate.toIso8601String(),
      'predictedWinnerId': instance.predictedWinnerId,
      'predictedWinnerName': instance.predictedWinnerName,
      'actualWinnerId': instance.actualWinnerId,
      'actualWinnerName': instance.actualWinnerName,
      'isWin': instance.isWin,
      'pointsEarned': instance.pointsEarned,
    };

PlaceBetRequest _$PlaceBetRequestFromJson(Map<String, dynamic> json) =>
    PlaceBetRequest(
      bettorId: json['bettorId'] as String,
      predictedWinnerId: json['predictedWinnerId'] as String,
    );

Map<String, dynamic> _$PlaceBetRequestToJson(PlaceBetRequest instance) =>
    <String, dynamic>{
      'bettorId': instance.bettorId,
      'predictedWinnerId': instance.predictedWinnerId,
    };
