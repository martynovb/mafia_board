import 'package:mafia_board/data/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';

class GamePhaseModel {
  PlayerModel? readyToSpeakPlayer;
  List<PlayerModel> spokenPlayers = [];
  int currentDay = 0;
  bool isStarted = false;

  List<MapEntry<int, SpeakPhaseAction>> speakPhasesByDays = [];
  List<MapEntry<int, VotePhaseAction>> votePhasesByDays = [];
  List<MapEntry<int, NightPhaseAction>> nightPhasesByDays = [];

  bool isNightPhaseFinished() {
    bool isFinished = true;
    for (var mapEntry in nightPhasesByDays) {
      if (mapEntry.key == currentDay) {
        isFinished = mapEntry.value.isFinished;
      }
    }
    return isFinished;
  }

  bool isVotingPhaseFinished() {
    bool isFinished = true;
    for (var mapEntry in votePhasesByDays) {
      if (mapEntry.key == currentDay) {
        isFinished = mapEntry.value.isVoted;
      }
    }
    return isFinished;
  }

  bool isSpeakPhaseFinished() {
    bool isFinished = true;
    for (var mapEntry in speakPhasesByDays) {
      if (mapEntry.key == currentDay) {
        isFinished = mapEntry.value.isFinished;
      }
    }
    return isFinished;
  }

  void addVotePhase(VotePhaseAction votePhaseAction) {
    votePhasesByDays.add(MapEntry(currentDay, votePhaseAction));
  }

  void addNightPhase(NightPhaseAction nightPhaseAction) {
    nightPhasesByDays.add(MapEntry(currentDay, nightPhaseAction));
  }

  void addSpeakPhase(SpeakPhaseAction speakPhaseAction) {
    speakPhasesByDays.add(MapEntry(currentDay, speakPhaseAction));
  }

  SpeakPhaseAction getCurrentSpeakPhase() => speakPhasesByDays
      .where(
        (mapEntry) => mapEntry.key == currentDay && !mapEntry.value.isFinished,
      )
      .map((mapEntry) => mapEntry.value)
      .first;

  VotePhaseAction getCurrentVotePhase() => votePhasesByDays
      .where(
        (mapEntry) => mapEntry.key == currentDay && !mapEntry.value.isVoted,
      )
      .map((mapEntry) => mapEntry.value)
      .first;

  NightPhaseAction getCurrentNightPhase() => nightPhasesByDays
      .where(
        (mapEntry) => mapEntry.key == currentDay && !mapEntry.value.isFinished,
      )
      .map((mapEntry) => mapEntry.value)
      .first;

  void updateSpeakPhase(SpeakPhaseAction speakPhaseAction) {
    final speakPhaseIndex = speakPhasesByDays.indexWhere((mapEntry) =>
        mapEntry.key == currentDay && mapEntry.value == speakPhaseAction);
    speakPhasesByDays[speakPhaseIndex] = MapEntry(currentDay, speakPhaseAction);
  }

  void updateVotePhase(VotePhaseAction votePhaseAction) {
    final votePhaseIndex = votePhasesByDays.indexWhere((mapEntry) =>
        mapEntry.key == currentDay && mapEntry.value == votePhaseAction);
    votePhasesByDays[votePhaseIndex] = MapEntry(currentDay, votePhaseAction);
  }

  void updateNightPhase(NightPhaseAction nightPhaseAction) {
    final nightPhaseIndex = nightPhasesByDays.indexWhere((mapEntry) =>
        mapEntry.key == currentDay && mapEntry.value == nightPhaseAction);
    nightPhasesByDays[nightPhaseIndex] = MapEntry(currentDay, nightPhaseAction);
  }
}
