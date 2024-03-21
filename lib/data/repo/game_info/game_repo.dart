import 'package:mafia_board/data/entity/game/game_entity.dart';
import 'package:mafia_board/data/entity/game/day_info_entity.dart';
import 'package:mafia_board/data/entity/game/player_entity.dart';
import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/game_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/winner_type.dart';

abstract class GameRepo {
  Future<GameEntity> fetchGame({required String gameId});

  Future<List<DayInfoEntity>> fetchAllDayInfoByGameId({
    required String gameId,
    required List<PlayerEntity> players,
  });

  Future<GameEntity> saveGame({
    required WinnerType winnerType,
    required int mafsLeft,
  });

  Future<void> removeGame({required String gameId});

  Future<void> removeAllDayInfoByGameId({required String gameId});

  Future<List<DayInfoEntity>> saveDayInfoList();

  Future<bool> removeGameData();

  Future<List<GameEntity>> fetchAllGamesByClubId({required String clubId});

  Future<GameEntity> createGame({
    required String clubId,
    required GameStatus gameStatus,
  });

  Future<GameEntity?> finishCurrentGame(FinishGameType finishGameType);

  Future<GameEntity?> getLastActiveGame();

  Future<DayInfoEntity> createDayInfo({
    int? day,
    PhaseType? currentPhase,
    List<PlayerEntity>? mutedPlayers,
  });

  Future<int> getCurrentDay();

  Future<List<DayInfoEntity>> getAllDaysInfo();

  Future<DayInfoEntity?> getLastValidDayInfo();

  Future<DayInfoEntity?> getLastDayInfo();

  Future<void> mutePlayer(PlayerModel player);

  Future<void> updateDayInfo(DayInfoEntity? dayInfoModel);

  Future<void> deleteAll();

  Future<void> add(DayInfoEntity dayInfoModel);

  Future<void> setCurrentPhaseType({required PhaseType phaseType});
}
