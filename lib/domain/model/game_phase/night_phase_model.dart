import 'package:mafia_board/data/constants/constants.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/domain/model/game_phase/game_phase_model.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/domain/model/phase_status.dart';

class NightPhaseModel extends GamePhaseModel {
  final Role role;
  final List<PlayerModel> playersForWakeUp;
  final Duration timeForNight;
  PlayerModel? killedPlayer;
  PlayerModel? checkedPlayer;

  NightPhaseModel({
    required super.currentDay,
    required super.tempId,
    super.id,
    super.dayInfoId,
    super.gameId,
    super.status = PhaseStatus.notStarted,
    required this.role,
    this.playersForWakeUp = const [],
    this.timeForNight = Constants.timeForNight,
    this.killedPlayer,
    this.checkedPlayer,
  });

  static NightPhaseModel fromFirebaseMap({
    required String id,
    required Map<String, dynamic> map,
    required PlayerModel? killedPlayer,
    required PlayerModel? checkedPlayer,
    required List<PlayerModel> playersForWakeUp,
  }) {
    return NightPhaseModel(
      id: id,
      tempId: map[FirestoreKeys.tempIdFieldKey],
      currentDay: map[FirestoreKeys.gamePhaseDayFieldKey],
      gameId: map[FirestoreKeys.gameIdFieldKey],
      status: PhaseStatus.finished,
      role: roleMapper(map[FirestoreKeys.roleFieldKey]),
      killedPlayer: killedPlayer,
      checkedPlayer: checkedPlayer,
      playersForWakeUp: playersForWakeUp,
      dayInfoId: map[FirestoreKeys.dayInfoIdFieldKey],
    )..updatedAt = DateTime.fromMillisecondsSinceEpoch(
        map[FirestoreKeys.updatedAtFieldKey] ?? 0);
  }

  @override
  PhaseType get phaseType => PhaseType.night;

  void kill(PlayerModel? player) {
    killedPlayer = player;
    updatedAt = DateTime.now();
  }

  void revokeKill() {
    killedPlayer = null;
    updatedAt = DateTime.now();
  }

  void check(PlayerModel? player) {
    checkedPlayer = player;
    updatedAt = DateTime.now();
  }

  void revokeCheck() {
    checkedPlayer = null;
    updatedAt = DateTime.now();
  }

  @override
  Map<String, dynamic> toFirestoreMap() {
    return super.toFirestoreMap()
      ..addAll(
        {
          FirestoreKeys.nightPhaseRoleFieldKey: role.name,
          FirestoreKeys.nightPhasePlayersForWakeUpTempIdsFieldKey:
              playersForWakeUp.map(
            (players) => players.tempId,
          ),
          FirestoreKeys.nightPhaseKilledPlayerTempIdFieldKey:
              killedPlayer?.tempId,
          FirestoreKeys.nightPhaseCheckedPlayerTempIdFieldKey:
              checkedPlayer?.tempId,
        },
      );
  }

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll(
        {
          'role': role.name,
          'playersForWakeUp':
              playersForWakeUp.map((players) => players.toMap()).toList(),
          'killedPlayer': killedPlayer?.toMap(),
          'checkedPlayer': checkedPlayer?.toMap(),
        },
      );
  }
}
