import 'package:mafia_board/data/model/game_phase_model.dart';

class GamePhaseRepository {
  GamePhaseModel? _gamePhase;

  GamePhaseModel getCurrentGamePhase() {
    return _gamePhase ??= GamePhaseModel();
  }

  void setCurrentGamePhase(GamePhaseModel gamePhase) {
    _gamePhase = gamePhase;
  }

  void resetGamePhase() {
    _gamePhase = GamePhaseModel();
  }
}
