import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:mafia_board/data/entity/game/day_info_entity.dart';
import 'package:mafia_board/domain/model/game_phase/game_phase_model.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';

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
  Future<void> saveGamePhases(List<DayInfoEntity> dayInfoList) async {
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
        DocumentReference docRef = ref.doc();
        batch.set(docRef, phase.toFirestoreMap());
      }
    }

    await batch.commit();
  }
}
