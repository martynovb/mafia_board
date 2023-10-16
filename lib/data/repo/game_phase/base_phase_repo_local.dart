import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:mafia_board/data/model/game_phase/game_phase_action.dart';
import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';

class BasePhaseRepoLocal<GamePhase extends GamePhaseAction>
    extends GamePhaseRepo<GamePhase> {
  @protected
  final List<GamePhase> list = [];

  @override
  void add({required GamePhase gamePhase}) {
    list.add(gamePhase);
  }

  @override
  void addAll({required List<GamePhase> gamePhases}) {
    list.addAll(gamePhases);
  }

  @override
  List<GamePhase> getAllPhasesByDay({int? day}) {
    return list.isEmpty
        ? []
        : list
            .where((phase) => phase.currentDay == (day ?? _findMaxDay()))
            .toList();
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
  bool isFinished({int? day}) {
    return !list.any(
      (phase) =>
          phase.currentDay == (day ?? _findMaxDay()) &&
          phase.status != PhaseStatus.finished,
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
    final index = list.indexWhere((phase) => phase.id == gamePhase.id);

    if (index != -1) {
      list[index] = gamePhase;
      return true;
    }
    return false;
  }

  @override
  GamePhase? getCurrentPhase({int? day}) {
    return list.firstWhereOrNull(
      (element) =>
          element.currentDay == (day ?? _findMaxDay()) &&
          element.status != PhaseStatus.finished,
    );
  }

  @override
  List<GamePhase> getAllPhases() {
    return list;
  }

  @override
  void deleteAll() {
    list.clear();
  }

  int _findMaxDay() {
    return list
        .map((phase) => phase.currentDay)
        .reduce((value, element) => value > element ? value : element);
  }
}
