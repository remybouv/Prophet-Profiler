import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_model.g.dart';

@JsonSerializable()
class Game extends Equatable {
  final String id;
  final String gameName;

  const Game({
    required this.id,
    required this.gameName
  });

  factory Game.fromJson(Map<String,dynamic> json) => _$GameFromJson(json);
  Map<String, dynamic> toJson() => _$GameToJson(this);

  @override
  List<Object?> get props => [
        id,
       gameName
      ];
}