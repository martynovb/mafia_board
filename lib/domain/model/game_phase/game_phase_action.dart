import 'package:mafia_board/domain/model/phase_status.dart';

abstract class GamePhaseAction {
  final int id = DateTime.now().millisecondsSinceEpoch;
  final int currentDay;
  final DateTime createdAt = DateTime.now();
  PhaseStatus status;

  GamePhaseAction({
    required this.currentDay,
    this.status = PhaseStatus.notStarted,
  });

  set updateStatus(PhaseStatus status) => this.status = status;

}
