import 'package:class_to_string/class_to_string.dart';
import 'package:mafia_board/data/entity/game/player_entity.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/domain/model/user_model.dart';

class PlayerModel {
  UserModel? _user;
  int fouls;
  Role role;
  double score;
  bool isDisqualified;
  bool isKilled;
  bool isMuted;
  bool isKicked;
  bool isPPK;
  int seatNumber;

  PlayerModel(
    this._user,
    this.role,
    this.seatNumber, {
    this.fouls = 0,
    this.score = 0,
    this.isDisqualified = false,
    this.isKilled = false,
    this.isMuted = false,
    this.isKicked = false,
    this.isPPK = false,
  });

  PlayerModel.empty(this.seatNumber)
      : _user = UserModel.empty(),
        role = Role.NONE,
        fouls = 0,
        score = 0,
        isDisqualified = false,
        isKilled = false,
        isMuted = false,
        isKicked = false,
        isPPK = false;

  PlayerModel.fromEntity(PlayerEntity? entity)
      : _user = UserModel.fromEntity(entity?.user),
        seatNumber = entity?.seatNumber ?? -1,
        role = roleMapper(entity?.role),
        fouls = entity?.fouls ?? -1,
        score = entity?.score ?? -1,
        isDisqualified = entity?.isRemoved ?? false,
        isKilled = entity?.isKilled ?? false,
        isMuted = entity?.isMuted ?? false,
        isKicked = entity?.isKicked ?? false,
        isPPK = entity?.isKicked ?? false;

  PlayerEntity toEntity() {
    return PlayerEntity(
      user: _user?.toEntity(),
      role: role.name,
      seatNumber: seatNumber,
      fouls: fouls,
      score: score,
      isRemoved: isDisqualified,
      isKilled: isKilled,
      isMuted: isMuted,
      isKicked: isKicked,
      isPPK: isPPK,
    );
  }

  void reset(){
    _user = null;
    role = Role.NONE;
    fouls = 0;
    score = 0;
    isDisqualified = false;
    isKilled = false;
    isMuted = false;
    isKicked = false;
    isPPK = false;
  }

  set user(UserModel? user) => _user = user;

  String get id => _user?.id ?? '';

  String get nickname => _user?.nickname ?? '';

  bool isInGame() => !isDisqualified && !isKilled && !isKicked && !isPPK;

  @override
  String toString() {
    return (ClassToString('PlayerModel')
          ..add('id', id)
          ..add('user', _user)
          ..add('fouls', fouls)
          ..add('role', role)
          ..add('score', score)
          ..add('seatNumber', seatNumber)
          ..add('isDisqualified', isDisqualified)
          ..add('isMuted', isMuted)
          ..add('isKicked', isKicked)
          ..add('isPPK', isPPK)
          ..add('isInGame', isInGame()))
        .toString();
  }
}
