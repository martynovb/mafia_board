import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/game/game_entity.dart';
import 'package:mafia_board/data/entity/game/day_info_entity.dart';
import 'package:mafia_board/data/entity/game/player_entity.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/game_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/domain/model/winner_type.dart';
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

    final index = _dayInfoList.indexWhere(
        (existingDayInfo) => existingDayInfo.tempId == dayInfoModel.tempId);

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
    final entity = DayInfoEntity(
      tempId: const Uuid().v1(),
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
    currentGame.finishedInMills = DateTime.now().millisecondsSinceEpoch;
    return currentGame;
  }

  @override
  Future<bool> removeGameData() async {
    _currentGame = null;
    _dayInfoList.clear();
    return true;
  }

  @override
  Future<GameEntity> saveGame({
    required WinnerType winnerType,
    required int mafsLeft,
  }) async {
    if (_currentGame != null) {
      _currentGame?.winRole = winnerType.name;
      _currentGame?.mafsLeft = mafsLeft;
      final doc = await firestore
          .collection(FirestoreKeys.gamesCollectionKey)
          .add(_currentGame?.toFirestoreMap() ?? {});
      _currentGame?.id = doc.id;
    } else {
      throw InvalidDataError('Game is not saved');
    }

    return _currentGame!;
  }

  @override
  Future<void> removeGame({required String gameId}) async {
    await FirebaseFirestore.instance
        .collection(FirestoreKeys.gamesCollectionKey)
        .doc(gameId)
        .delete();
  }

  @override
  Future<List<DayInfoEntity>> saveDayInfoList() async {
    if (_currentGame == null || _currentGame?.id == null) {
      throw InvalidDataError('Game is not saved');
    }

    CollectionReference dayInfoRef = firestore.collection(
      FirestoreKeys.dayInfoCollectionKey,
    );

    WriteBatch batch = firestore.batch();

    for (var dayInfo in _dayInfoList) {
      dayInfo.gameId = _currentGame?.id;
      DocumentReference dayInfoDocRef = dayInfoRef.doc();
      batch.set(dayInfoDocRef, dayInfo.toFirestoreMap());
      dayInfo.id = dayInfoDocRef.id;
    }
    await batch.commit();

    return _dayInfoList;
  }

  @override
  Future<List<GameEntity>> fetchAllGamesByClubId({
    required String clubId,
  }) async {
    var gamesSnapshot = await FirebaseFirestore.instance
        .collection(FirestoreKeys.gamesCollectionKey)
        .where(FirestoreKeys.clubIdFieldKey, isEqualTo: clubId)
        .get();

    return gamesSnapshot.docs
        .map(
          (gameDoc) => GameEntity.fromFirestoreMap(
            id: gameDoc.id,
            data: gameDoc.data(),
          ),
        )
        .toList();
  }

  @override
  Future<void> removeAllDayInfoByGameId({required String gameId}) async {
    final batch = FirebaseFirestore.instance.batch();

    final collectionRef = FirebaseFirestore.instance
        .collection(FirestoreKeys.dayInfoCollectionKey)
        .where(FirestoreKeys.gameIdFieldKey, isEqualTo: gameId);
    final snapshots = await collectionRef.get();

    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  @override
  Future<GameEntity> fetchGame({required String gameId}) async {
    final gameData = await firestore.collection(FirestoreKeys.gamesCollectionKey).doc(gameId).get();
    return GameEntity.fromFirestoreMap(id: gameData.id, data: gameData.data());
  }

  @override
  Future<List<DayInfoEntity>> fetchAllDayInfoByGameId({
    required String gameId,
    required List<PlayerEntity> players,
  }) async {
    final dayInfoSnapshot = await firestore
        .collection(FirestoreKeys.dayInfoCollectionKey)
        .where(FirestoreKeys.gameIdFieldKey, isEqualTo: gameId)
        .get();

    return dayInfoSnapshot.docs.map(
      (doc) {
        final docData = doc.data();
        final removedPlayers = players
            .where((player) => docData[FirestoreKeys.removedPlayersTempIdsFieldKey]?.contains(player.tempId) ?? false)
            .toList();

        final mutedPlayers = players
            .where((player) => docData[FirestoreKeys.mutedPlayersTempIdsFieldKey]?.contains(player.tempId) ?? false)
            .toList();

        final playersWithFoul = players
            .where((player) => docData[FirestoreKeys.playersWithFoulTempIdsFieldKey]?.contains(player.tempId) ?? false)
            .toList();

        return DayInfoEntity.fromFirestoreMap(
          id: doc.id,
          data: docData,
          removedPlayers: removedPlayers,
          mutedPlayers: mutedPlayers,
          playersWithFoul: playersWithFoul,
        );
      },
    ).toList();
  }
}
