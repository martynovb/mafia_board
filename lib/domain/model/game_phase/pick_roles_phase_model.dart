import 'package:mafia_board/domain/model/game_phase/game_phase_model.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';

class PickRolePhaseModel extends GamePhaseModel {
  final List<PlayerModel> allPlayers;

  PickRolePhaseModel({
    required int currentDay,
    required this.allPlayers,
    PhaseStatus phaseStatus = PhaseStatus.notStarted,
  }) : super(
          currentDay: currentDay,
          status: phaseStatus,
        );

  @override
  PhaseType get phaseType => PhaseType.info;
}
