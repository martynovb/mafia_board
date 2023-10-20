import 'package:class_to_string/class_to_string.dart';
import 'package:mafia_board/data/model/role.dart';

class PlayerModel {
  int id;
  final String nickname;
  int fouls;
  final Role role;
  double score;
  bool isRemoved;
  bool isKilled;
  bool isMuted;
  bool isKicked;
  int playerNumber;

  PlayerModel(
    this.id,
    this.nickname,
    this.fouls,
    this.role,
    this.score,
    this.playerNumber, {
    this.isRemoved = false,
    this.isKilled = false,
    this.isMuted = false,
    this.isKicked = false,
  });

  bool isAvailable() => !isRemoved && !isKilled && !isKicked;

  PlayerModel.empty({required this.id, required this.playerNumber})
      : nickname = '',
        role = Role.NONE,
        fouls = 0,
        score = 0,
        isRemoved = false,
        isMuted = false,
        isKicked = false,
        isKilled = false;

  @override
  String toString() {
    return (ClassToString('PlayerModel')
          ..add('id', id)
          ..add('nickname', nickname)
          ..add('fouls', fouls)
          ..add('role', role)
          ..add('score', score)
          ..add('playerNumber', playerNumber)
          ..add('isRemoved', isRemoved)
          ..add('isMuted', isMuted)
          ..add('isKicked', isKicked)
          ..add('isAvailable', isAvailable()))
        .toString();
  }
}
