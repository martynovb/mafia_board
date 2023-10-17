import 'package:mafia_board/data/model/game_info_model.dart';
import 'package:mafia_board/data/model/phase_type.dart';
import 'package:mafia_board/data/model/player_model.dart';

abstract class GameInfoRepo {
  Future<int> getCurrentDay();

  Future<List<GameInfoModel>> getAllGameInfo();

  Future<GameInfoModel?> getLastValidGameInfoByDay();

  Future<GameInfoModel?> getLastGameInfoByDay();

  Future<void> mutePlayer(PlayerModel player);

  Future<void> updateGameInfo(GameInfoModel gameInfoModel);

  Future<void> deleteAll();

  Future<void> add(GameInfoModel gameInfoModel);

  Future<void> setCurrentPhaseType({required PhaseType phaseType});
}
