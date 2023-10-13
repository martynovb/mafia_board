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
    if (day != null) {
      return list.where((phase) => phase.currentDay == day).toList();
    } else {
      int maxDay = list
          .map((phase) => phase.currentDay)
          .reduce((value, element) => value > element ? value : element);

      return list.where((phase) => phase.currentDay == maxDay).toList();
    }
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
    if (day != null) {
      return list.any(
        (phase) =>
            phase.currentDay == day && phase.status != PhaseStatus.finished,
      );
    } else {
      int maxDay = list
          .map((phase) => phase.currentDay)
          .reduce((value, element) => value > element ? value : element);

      return list.any(
        (phase) =>
            phase.currentDay == maxDay && phase.status != PhaseStatus.finished,
      );
    }
  }

  @override
  void remove({required GamePhase gamePhase}) {
    list.removeWhere((phase) => phase.id == gamePhase.id);
  }

  @override
  bool update({required GamePhase gamePhase}) {
    final index = list.indexWhere((gamePhase) => gamePhase.id == gamePhase.id);

    if (index != -1) {
      list[index] = gamePhase;
      return true;
    }
    return false;
  }

  @override
  GamePhase? getCurrentPhase({int? day}) {
    if (day != null) {
      return list.firstWhereOrNull(
        (element) =>
            element.currentDay == day && element.status != PhaseStatus.finished,
      );
    } else {
      int maxDay = list
          .map((phase) => phase.currentDay)
          .reduce((value, element) => value > element ? value : element);

      return list.firstWhereOrNull(
        (element) =>
            element.currentDay == maxDay &&
            element.status != PhaseStatus.finished,
      );
    }
  }

  @override
  List<GamePhase> getAllPhases() {
    return list;
  }

  @override
  void deleteAll() {
    list.clear();
  }
}
