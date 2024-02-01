import 'package:mafia_board/data/entity/game/day_info_entity.dart';
import 'package:mafia_board/domain/model/game_phase/game_phase_model.dart';

abstract class GamePhaseRepo<GamePhase extends GamePhaseModel> {
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

  Future<void> saveGamePhases({
    required String gameId,
    required List<DayInfoEntity> dayInfoList,
  });
}
