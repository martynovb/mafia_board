import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:mafia_board/data/entity/game/day_info_entity.dart';
import 'package:mafia_board/domain/model/game_phase/game_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_model.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';

import '../../constants/firestore_keys.dart';

class BasePhaseRepo<GamePhase extends GamePhaseModel>
    extends GamePhaseRepo<GamePhase> {
  final FirebaseFirestore firestore;

  @protected
  final Set<GamePhase> list = {};

  BasePhaseRepo({
    required this.firestore,
  });

  @override
  Future<void> add({required GamePhase gamePhase}) async {
    list.add(gamePhase);
  }

  @override
  void addAll({required List<GamePhase> gamePhases}) {
    list.addAll(gamePhases);
  }

  @override
  List<GamePhase> getAllPhasesByDay({required int day}) {
    return list.isEmpty
        ? []
        : list.where((phase) => phase.currentDay == day).toList();
  }

  @override
  GamePhase? getLastPhase() {
    return list.lastOrNull;
  }

  @override
  bool isExist({required int day}) {
    return list.any((phase) => phase.currentDay == day);
  }

  @override
  bool isFinished({required int day}) {
    return !list.any(
      (phase) =>
          phase.currentDay == day && phase.status != PhaseStatus.finished,
    );
  }

  @override
  void remove({required GamePhase gamePhase}) {
    if (list.isNotEmpty) {
      list.removeWhere((phase) => phase.tempId == gamePhase.tempId);
    }
  }

  @override
  bool update({required GamePhase gamePhase}) {
    final existedGamePhase =
        list.firstWhereOrNull((phase) => phase.tempId == gamePhase.tempId);

    if (existedGamePhase != null) {
      list.add(gamePhase);
      return true;
    }
    return false;
  }

  @override
  GamePhase? getCurrentPhase({required int day}) {
    return list.firstWhereOrNull(
      (element) =>
          element.currentDay == day && element.status != PhaseStatus.finished,
    );
  }

  @override
  List<GamePhase> getAllPhases() {
    return list.toList();
  }

  @override
  void deleteAll() {
    list.clear();
  }

  @override
  Future<void> saveGamePhases({
    required String gameId,
    required List<DayInfoEntity> dayInfoList,
  }) async {
    CollectionReference ref = firestore.collection(
      FirestoreKeys.gamePhaseCollectionKey,
    );

    WriteBatch batch = firestore.batch();

    // set dayInfoId for phases
    for (var dayInfo in dayInfoList) {
      final phases = list.where(
        (gamePhase) => gamePhase.currentDay == dayInfo.day,
      );
      for (var phase in phases) {
        phase.dayInfoId = dayInfo.id;
        phase.gameId = gameId;
        DocumentReference docRef = ref.doc();
        batch.set(docRef, phase.toFirestoreMap());
      }
    }

    await batch.commit();
  }

  @override
  Future<void> deleteAllGamePhasesByGameId({
    required String gameId,
    required PhaseType phaseType,
  }) async {
    final batch = firestore.batch();

    final collectionRef = FirebaseFirestore.instance
        .collection(FirestoreKeys.gamePhaseCollectionKey)
        .where(FirestoreKeys.gameIdFieldKey, isEqualTo: gameId)
        .where(FirestoreKeys.gamePhaseTypeFieldKey, isEqualTo: phaseType.name);

    final snapshots = await collectionRef.get();

    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  @override
  Future<List<GamePhaseModel>> fetchAllGamePhasesByGameId({
    required String gameId,
    required List<PlayerModel> players,
  }) async {
    final gamePhasesSnapshot = await firestore
        .collection(FirestoreKeys.gamePhaseCollectionKey)
        .where(FirestoreKeys.gameIdFieldKey, isEqualTo: gameId)
        .get();

    final gamePhases = <GamePhaseModel>[];
    for (var doc in gamePhasesSnapshot.docs) {
      final data = doc.data();
      final gamePhaseType = data[FirestoreKeys.gamePhaseTypeFieldKey];

      // parse NightGamePhase
      if (gamePhaseType == PhaseType.night.name) {
        final killedPlayer = players.firstWhereOrNull((player) =>
            player.tempId ==
            data[FirestoreKeys.nightPhaseKilledPlayerTempIdFieldKey]);

        final checkedPlayer = players.firstWhereOrNull((player) =>
            player.tempId ==
            data[FirestoreKeys.nightPhaseCheckedPlayerTempIdFieldKey]);

        final playersForWakeUp = players
            .where((player) => data[FirestoreKeys.nightPhasePlayersForWakeUpTempIdsFieldKey]?.contains(player.tempId) ?? false)
            .toList();

        gamePhases.add(
          NightPhaseModel.fromFirebaseMap(
            id: doc.id,
            map: data,
            killedPlayer: killedPlayer ?? PlayerModel.empty(),
            checkedPlayer: checkedPlayer,
            playersForWakeUp: playersForWakeUp,
          ),
        );
      }
      // parse SpeakGamePhase
      else if (gamePhaseType == PhaseType.speak.name) {
        final bestMove = players
            .where((player) => data[FirestoreKeys.speakPhaseBestMoveTempIdsFieldKey]?.contains(player.tempId) ?? false)
            .toList();

        gamePhases.add(
          SpeakPhaseModel.fromFirebaseMap(
            id: doc.id,
            map: data,
            bestMove: bestMove,
          ),
        );
      }
      // parse VoteGamePhase
      else if (gamePhaseType == PhaseType.vote.name) {
        final votedPlayers = players
            .where((player) => data[FirestoreKeys.votePhaseVotedPlayersTempIdsFieldKey]?.contains(player.tempId) ?? false)
            .toSet();

        final playersToKick = players
            .where((player) => data[FirestoreKeys.votePhasePlayersToKickTempIdsFieldKey]?.contains(player.tempId) ?? false)
            .toList();

        final playerOnVote = players.firstWhereOrNull((player) =>
            player.tempId ==
            data[FirestoreKeys.votePhasePlayerOnVoteTempIdFieldKey]);

        final whoPutOnVote = players.firstWhereOrNull((player) =>
            player.tempId ==
            data[FirestoreKeys.votePhaseWhoPutOnVoteTempIdFieldKey]);

        gamePhases.add(
          VotePhaseModel.fromFirebaseMap(
            id: doc.id,
            map: data,
            votedPlayers: votedPlayers,
            playersToKick: playersToKick,
            playerOnVote: playerOnVote ?? PlayerModel.empty(),
            whoPutOnVote: whoPutOnVote,
          ),
        );
      }
    }
    return gamePhases;
  }
}
