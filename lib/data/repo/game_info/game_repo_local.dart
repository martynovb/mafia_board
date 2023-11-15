import 'package:collection/collection.dart';
import 'package:mafia_board/data/entity/game/game_entity.dart';
import 'package:mafia_board/data/entity/game/game_info_entity.dart';
import 'package:mafia_board/data/entity/game/player_entity.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/model/game_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:uuid/uuid.dart';

class GameRepoLocal extends GameRepo {
  final List<GameEntity> _gamesList = [];
  final List<DayInfoEntity> _list = [];
  final PlayersRepo playersRepo;

  GameRepoLocal({required this.playersRepo});

  @override
  Future<GameEntity> createGame({
    required String clubId,
    required GameStatus gameStatus,
  }) async {
    final players = playersRepo.getAllPlayers();
    final gameEntity = GameEntity(
      id: const Uuid().v1(),
      clubId: clubId,
      players: players.map((playerModel) => playerModel.toEntity()).toList(),
      gameStatus: gameStatus.name,
    );
    _gamesList.add(gameEntity);
    return gameEntity;
  }

  @override
  Future<List<DayInfoEntity>> getAllDaysInfo() async {
    return _list;
  }

  @override
  Future<int> getCurrentDay() async {
    final int? currentDay = (await getLastValidDayInfo())?.day;
    return currentDay ?? -1;
  }

  @override
  Future<DayInfoEntity?> getLastValidDayInfo() async {
    return _list
        .where((dayInfo) => dayInfo.currentPhase != PhaseType.none.name)
        .sorted((a, b) => a.day?.compareTo(b.day ?? -1) ?? -1)
        .lastOrNull;
  }

  @override
  Future<void> mutePlayer(PlayerModel player) async {
    final lastDayInfo = await getLastValidDayInfo();
    if (lastDayInfo != null) {
      lastDayInfo.mutedPlayers?.add(player.toEntity());
      await updateDayInfo(lastDayInfo);
    }
  }

  @override
  Future<void> deleteAll() async {
    _list.clear();
  }

  @override
  Future<bool> updateDayInfo(DayInfoEntity? dayInfoModel) async {
    if (dayInfoModel == null) {
      return false;
    }

    final index = _list
        .indexWhere((existingDayInfo) => existingDayInfo.id == dayInfoModel.id);

    if (index != -1) {
      _list[index] = dayInfoModel;
      return true;
    }
    return false;
  }

  @override
  Future<void> add(DayInfoEntity dayInfoModel) async {
    _list.add(dayInfoModel);
  }

  @override
  Future<void> setCurrentPhaseType({required PhaseType phaseType}) async {
    final lastDayInfo = await getLastValidDayInfo();
    if (lastDayInfo != null) {
      lastDayInfo.currentPhase = phaseType.name;
      await updateDayInfo(lastDayInfo);
    }
  }

  @override
  Future<DayInfoEntity?> getLastDayInfo() async {
    return _list
        .sorted((a, b) => a.day?.compareTo(b.day ?? -1) ?? -1)
        .lastOrNull;
  }

  @override
  Future<DayInfoEntity> createDayInfo({
    int? day,
    PhaseType? currentPhase,
    List<PlayerEntity>? mutedPlayers,
  }) async {
    final currentGame = await getLastActiveGame();
    final entity = DayInfoEntity(
      id: const Uuid().v1(),
      gameId: currentGame?.id,
      day: day,
      createdAt: DateTime.now(),
      removedPlayers: [],
      mutedPlayers: mutedPlayers,
      playersWithFoul: [],
      currentPhase: currentPhase?.name,
    );
    _list.add(entity);
    return entity;
  }

  @override
  Future<GameEntity?> getLastActiveGame() async => _gamesList.firstWhereOrNull(
      (game) => game.gameStatus == GameStatus.inProgress.name);

  @override
  Future<GameEntity?> finishCurrentGame() async {
    final currentGame = await getLastActiveGame();
    if (currentGame == null) {
      return null;
    }

    currentGame.gameStatus = GameStatus.finished.name;
    final indexOf = _gamesList.lastIndexOf(currentGame);
    _gamesList[indexOf] = currentGame;
    return currentGame;
  }
}
