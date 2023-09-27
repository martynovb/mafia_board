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

  PlayerModel(
    this.id,
    this.nickname,
    this.fouls,
    this.role,
    this.score, {
    this.isRemoved = false,
    this.isKilled = false,
    this.isMuted = false,
  });

  bool isAvailable() => !isRemoved && !isKilled;

  PlayerModel.empty({this.id = 0})
      : nickname = '',
        role = Role.NONE,
        fouls = 0,
        score = 0,
        isRemoved = false,
        isMuted = false,
        isKilled = false;

  @override
  String toString() {
    return 'PlayerModel{id: $id, nickname: $nickname, fouls: $fouls, role: $role, score: $score, isRemoved: $isRemoved}';
  }
}
