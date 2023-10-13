import 'package:mafia_board/data/model/game_phase/game_phase_action.dart';

abstract class GamePhaseRepo<GamePhase extends GamePhaseAction> {
  bool isExist({required int day});

  bool isFinished({int? day});

  void add({required GamePhase gamePhase});

  void addAll({required List<GamePhase> gamePhases});

  GamePhase? getLastPhase();

  void remove({required GamePhase gamePhaseAction});

  bool update({required GamePhase gamePhase});

  List<GamePhase> getAllPhasesByDay({int? day});
}
