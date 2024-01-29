import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/game/game_entity.dart';
import 'package:mafia_board/data/entity/game/day_info_entity.dart';
import 'package:mafia_board/data/entity/game/player_entity.dart';
import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/game_results_model.dart';
import 'package:mafia_board/domain/model/game_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:uuid/uuid.dart';

class GameRepoImpl extends GameRepo {
  GameEntity? _currentGame;
  final List<DayInfoEntity> _dayInfoList = [];
  final FirebaseFirestore firestore;

  GameRepoImpl({
    required this.firestore,
  });

  @override
  Future<GameEntity> createGame({
    required String clubId,
    required GameStatus gameStatus,
  }) async {
    _currentGame = GameEntity(
      clubId: clubId,
      gameStatus: gameStatus.name,
      finishGameType: FinishGameType.none.name,
      startedInMills: DateTime.now().millisecondsSinceEpoch,
    );
    return _currentGame!;
  }

  @override
  Future<List<DayInfoEntity>> getAllDaysInfo() async {
    return _dayInfoList;
  }

  @override
  Future<int> getCurrentDay() async {
    final int? currentDay = (await getLastValidDayInfo())?.day;
    return currentDay ?? -1;
  }

  @override
  Future<DayInfoEntity?> getLastValidDayInfo() async {
    return _dayInfoList
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
    _dayInfoList.clear();
  }

  @override
  Future<bool> updateDayInfo(DayInfoEntity? dayInfoModel) async {
    if (dayInfoModel == null) {
      return false;
    }

    final index = _dayInfoList
        .indexWhere((existingDayInfo) => existingDayInfo.id == dayInfoModel.id);

    if (index != -1) {
      _dayInfoList[index] = dayInfoModel;
      return true;
    }
    return false;
  }

  @override
  Future<void> add(DayInfoEntity dayInfoModel) async {
    _dayInfoList.add(dayInfoModel);
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
    return _dayInfoList
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
    _dayInfoList.add(entity);
    return entity;
  }

  @override
  Future<GameEntity?> getLastActiveGame() async {
    return _currentGame;
  }

  @override
  Future<GameEntity?> finishCurrentGame(FinishGameType finishGameType) async {
    final currentGame = _currentGame;
    if (currentGame == null) {
      return null;
    }

    currentGame.gameStatus = GameStatus.finished.name;
    currentGame.finishGameType = finishGameType.name;
    return currentGame;
  }

  @override
  Future<bool> removeGameData() async {
    _currentGame = null;
    _dayInfoList.clear();
    return true;
  }

  @override
  Future<void> saveGameResults({
    required ClubModel clubModel,
    required GameResultsModel gameResultsModel,
  }) async {
    //create game
    /*final doc =
    await firestore.collection(FirestoreKeys.gamesCollectionKey).add(
      {
        FirestoreKeys.clubTitleFieldKey: name,
        FirestoreKeys.clubDescriptionFieldKey: clubDescription,
        FirestoreKeys.clubMembersIdsFieldKey: [userId],
        FirestoreKeys.clubAdminsIdsFieldKey: [userId],
      },
    );*/
  }

  @override
  Future<GameEntity> saveGame() async {
    if(_currentGame != null) {
      final doc = await firestore.collection(FirestoreKeys.gamesCollectionKey)
          .add(
          _currentGame?.toFirestoreMap() ?? {}
      );
      _currentGame?.id = doc.id;
      return _currentGame!;
    }

    throw InvalidDataError('Game is not created');
  }
}
