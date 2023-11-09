import 'package:mafia_board/domain/model/game_phase/game_phase_action.dart';

abstract class GamePhaseRepo<GamePhase extends GamePhaseAction> {
  bool isExist({required int day});

  bool isFinished({required int day});

  Future<void> add({required GamePhase gamePhase});

  void addAll({required List<GamePhase> gamePhases});

  GamePhase? getLastPhase();

  GamePhase? getCurrentPhase({required int day});

  void remove({required GamePhase gamePhase});

  bool update({required GamePhase gamePhase});

  List<GamePhase> getAllPhasesByDay({required int day});

  List<GamePhase> getAllPhases();

  void deleteAll();
}
