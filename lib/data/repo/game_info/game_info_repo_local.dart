import 'package:collection/collection.dart';
import 'package:mafia_board/data/model/game_info_model.dart';
import 'package:mafia_board/data/model/phase_type.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/repo/game_info/game_info_repo.dart';

class GameInfoRepoLocal extends GameInfoRepo {
  final List<GameInfoModel> _list = [];

  @override
  Future<List<GameInfoModel>> getAllGameInfo() async {
    return _list;
  }

  @override
  Future<int> getCurrentDay() async {
    final int? currentDay = (await getLastGameInfoByDay())?.day;
    return currentDay ?? -1;
  }

  @override
  Future<GameInfoModel?> getLastGameInfoByDay() async {
    return _list
        .sorted(
          (a, b) => a.day.compareTo(b.day),
        )
        .firstOrNull;
  }

  @override
  Future<void> mutePlayer(PlayerModel player) async {
    final lastGameInfo = await getLastGameInfoByDay();
    if (lastGameInfo != null) {
      lastGameInfo.addMutedPlayer(player);
      updateGameInfo(lastGameInfo);
    }
  }

  @override
  Future<void> deleteAll() async {
    _list.clear();
  }

  @override
  Future<bool> updateGameInfo(GameInfoModel gameInfoModel) async {
    final index = _list.indexWhere(
        (existingGameInfo) => existingGameInfo.id == gameInfoModel.id);

    if (index != -1) {
      _list[index] = gameInfoModel;
      return true;
    }
    return false;
  }

  @override
  Future<void> add(GameInfoModel gameInfoModel) async {
    _list.add(gameInfoModel);
  }

  @override
  Future<void> setCurrentPhaseType({required PhaseType phaseType}) async {
    final lastGameInfo = await getLastGameInfoByDay();
    if (lastGameInfo != null) {
      lastGameInfo.currentPhase = phaseType;
      updateGameInfo(lastGameInfo);
    }
  }
}
