import 'package:class_to_string/class_to_string.dart';
import 'package:mafia_board/data/entity/game/player_entity.dart';
import 'package:mafia_board/domain/model/club_member_model.dart';
import 'package:mafia_board/domain/model/role.dart';

class PlayerModel {
  String? id;
  String tempId;
  ClubMemberModel? clubMember;
  int fouls;
  Role role;
  bool isDisqualified;
  bool isKilled;
  bool isMuted;
  bool isKicked;
  bool isPPK;
  int seatNumber;

  double bestMove;
  double compensation;
  double gamePoints;
  double bonus;
  bool isFirstKilled;

  PlayerModel({
    required this.tempId,
    required this.clubMember,
    required this.role,
    required this.seatNumber,
    this.fouls = 0,
    this.isDisqualified = false,
    this.isKilled = false,
    this.isMuted = false,
    this.isKicked = false,
    this.isPPK = false,
    this.bestMove = 0.0,
    this.compensation = 0.0,
    this.gamePoints = 0.0,
    this.bonus = 0.0,
    this.isFirstKilled = false,
  });

  double total() => bestMove + compensation + gamePoints + bonus;

  PlayerModel.empty(this.seatNumber)
      : tempId = '',
        clubMember = ClubMemberModel.empty(),
        role = Role.none,
        fouls = 0,
        isDisqualified = false,
        isKilled = false,
        isMuted = false,
        isKicked = false,
        isPPK = false,
        bestMove = 0.0,
        compensation = 0.0,
        gamePoints = 0.0,
        bonus = 0.0,
        isFirstKilled = false;

  PlayerModel.fromEntity(PlayerEntity? entity)
      : tempId = '',
        clubMember = ClubMemberModel.fromEntity(entity?.clubMember),
        seatNumber = entity?.seatNumber ?? -1,
        role = roleMapper(entity?.role),
        fouls = entity?.fouls ?? -1,
        isDisqualified = entity?.isRemoved ?? false,
        isKilled = entity?.isKilled ?? false,
        isMuted = entity?.isMuted ?? false,
        isKicked = entity?.isKicked ?? false,
        isPPK = entity?.isKicked ?? false,
        bestMove = entity?.bestMove ?? 0.0,
        compensation = entity?.compensation ?? 0.0,
        gamePoints = entity?.gamePoints ?? 0.0,
        bonus = entity?.bonus ?? 0.0,
        isFirstKilled = entity?.isFirstKilled ?? false;

  PlayerEntity toEntity() {
    return PlayerEntity(
      tempId: tempId,
      clubMember: clubMember?.toEntity(),
      role: role.name,
      seatNumber: seatNumber,
      fouls: fouls,
      isRemoved: isDisqualified,
      isKilled: isKilled,
      isMuted: isMuted,
      isKicked: isKicked,
      isPPK: isPPK,
      bestMove: bestMove,
      compensation: compensation,
      gamePoints: gamePoints,
      bonus: bonus,
      isFirstKilled: isFirstKilled,
    );
  }

  void reset() {
    clubMember = null;
    role = Role.none;
    fouls = 0;
    isDisqualified = false;
    isKilled = false;
    isMuted = false;
    isKicked = false;
    isPPK = false;
    bestMove = 0.0;
    compensation = 0.0;
    gamePoints = 0.0;
    bonus = 0.0;
    isFirstKilled = false;
  }

  set user(ClubMemberModel? clubMember) => clubMember = clubMember;

  String? get clubMemberId => clubMember?.id;

  String get nickname => clubMember?.user.nickname ?? '';

  bool isInGame() => !isDisqualified && !isKilled && !isKicked && !isPPK;

  @override
  String toString() {
    return (
      ClassToString('PlayerModel')
        ..add('id', tempId)
        ..add('clubMember', clubMember)
        ..add('fouls', fouls)
        ..add('role', role)
        ..add('seatNumber', seatNumber)
        ..add('isDisqualified', isDisqualified)
        ..add('isMuted', isMuted)
        ..add('isKicked', isKicked)
        ..add('isPPK', isPPK)
        ..add('isInGame', isInGame())
        ..add('bestMove', bestMove)
        ..add('compensation', compensation)
        ..add('gamePoints', gamePoints)
        ..add('bonus', bonus)
        ..add('isFirstKilled', isFirstKilled),
    ).toString();
  }
}
