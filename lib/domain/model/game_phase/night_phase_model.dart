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
    String? id,
    required int currentDay,
    required this.role,
    this.playersForWakeUp = const [],
    this.timeForNight = Constants.timeForNight,
    PhaseStatus status = PhaseStatus.notStarted,
    this.killedPlayer,
    this.checkedPlayer,
  }) : super(
          id: id,
          currentDay: currentDay,
          status: status,
        );

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
          FirestoreKeys.nightPhaseKilledPlayerTempIdFieldKey: killedPlayer?.tempId,
          FirestoreKeys.nightPhaseCheckedPlayerTempIdFieldKey: checkedPlayer?.tempId,
        },
      );
  }
}
