import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:mafia_board/domain/model/game_phase/game_phase_action.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';

class BasePhaseRepoLocal<GamePhase extends GamePhaseAction>
    extends GamePhaseRepo<GamePhase> {
  @protected
  final Set<GamePhase> list = {};

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
      list.removeWhere((phase) => phase.id == gamePhase.id);
    }
  }

  @override
  bool update({required GamePhase gamePhase}) {
    final existedGamePhase = list.firstWhereOrNull((phase) => phase.id == gamePhase.id);

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
}
