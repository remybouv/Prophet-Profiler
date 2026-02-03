// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      id: json['id'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      profile: PlayerProfile.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'photoUrl': instance.photoUrl,
      'profile': instance.profile,
    };

PlayerProfile _$PlayerProfileFromJson(Map<String, dynamic> json) =>
    PlayerProfile(
      aggressivity: (json['aggressivity'] as num).toInt(),
      patience: (json['patience'] as num).toInt(),
      analysis: (json['analysis'] as num).toInt(),
      bluff: (json['bluff'] as num).toInt(),
    );

Map<String, dynamic> _$PlayerProfileToJson(PlayerProfile instance) =>
    <String, dynamic>{
      'aggressivity': instance.aggressivity,
      'patience': instance.patience,
      'analysis': instance.analysis,
      'bluff': instance.bluff,
    };
