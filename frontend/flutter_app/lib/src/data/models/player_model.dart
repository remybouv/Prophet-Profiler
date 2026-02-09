import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'player_model.g.dart';

@JsonSerializable()
class Player extends Equatable {
  final String id;
  final String name;
  final String? photoUrl;
  final PlayerProfile profile;

  const Player({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.profile,
  });

  factory Player.fromJson(Map<String, dynamic> json) => 
      _$PlayerFromJson(json);
  
  /// Sérialisation pour l'API (format plat, compatible avec le backend)
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'photoUrl': photoUrl,
    'aggressivity': profile.aggressivity,
    'patience': profile.patience,
    'analysis': profile.analysis,
    'bluff': profile.bluff,
  };

  @override
  List<Object?> get props => [id, name, photoUrl, profile];
}

@JsonSerializable()
class PlayerProfile extends Equatable {
  @JsonKey(name: 'aggressivity')
  final int aggressivity; // 1-5
  @JsonKey(name: 'patience')
  final int patience;     // 1-5
  @JsonKey(name: 'analysis')
  final int analysis;     // 1-5
  @JsonKey(name: 'bluff')
  final int bluff;        // 1-5

  const PlayerProfile({
    required this.aggressivity,
    required this.patience,
    required this.analysis,
    required this.bluff,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => 
      _$PlayerProfileFromJson(json);
  
  Map<String, dynamic> toJson() => _$PlayerProfileToJson(this);

  @override
  List<Object?> get props => [aggressivity, patience, analysis, bluff];
}