import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_model.g.dart';

@JsonSerializable()
class Game extends Equatable {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'name')
  final String gameName;

  const Game({
    required this.id,
    required this.gameName
  });

  factory Game.fromJson(Map<String,dynamic> json) => _$GameFromJson(json);
  
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': gameName
  };

  @override
  List<Object?> get props => [
        id,
       gameName
      ];
}