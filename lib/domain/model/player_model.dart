import 'package:class_to_string/class_to_string.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/domain/model/user_model.dart';

class PlayerModel {
  UserModel? _user;
  int fouls;
  Role role;
  double score;
  bool isRemoved;
  bool isKilled;
  bool isMuted;
  bool isKicked;
  int seatNumber;

  PlayerModel(
    this._user,
    this.role,
    this.seatNumber, {
    this.fouls = 0,
    this.score = 0,
    this.isRemoved = false,
    this.isKilled = false,
    this.isMuted = false,
    this.isKicked = false,
  });

  PlayerModel.empty(this.seatNumber)
      : role = Role.NONE,
        fouls = 0,
        score = 0,
        isRemoved = false,
        isKilled = false,
        isMuted = false,
        isKicked = false;

  set user(UserModel user) => _user = user;

  String get id => _user?.id ?? '';

  String get nickname => _user?.nickname ?? '';

  bool isInGame() => !isRemoved && !isKilled && !isKicked;

  @override
  String toString() {
    return (ClassToString('PlayerModel')
          ..add('id', id)
          ..add('user', _user)
          ..add('fouls', fouls)
          ..add('role', role)
          ..add('score', score)
          ..add('seatNumber', seatNumber)
          ..add('isRemoved', isRemoved)
          ..add('isMuted', isMuted)
          ..add('isKicked', isKicked)
          ..add('isAvailable', isInGame()))
        .toString();
  }
}
