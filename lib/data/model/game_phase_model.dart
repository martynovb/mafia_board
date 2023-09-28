import 'package:mafia_board/data/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/presentation/maf_logger.dart';
import 'package:collection/collection.dart';

const _tag = 'GamePhaseModel';

class GamePhaseModel {
  PlayerModel? readyToSpeakPlayer;
  List<PlayerModel> spokenPlayers = [];
  int currentDay = 0;
  bool isStarted = false;

  Map<int, List<SpeakPhaseAction>> speakPhasesByDays = {};
  Map<int, List<VotePhaseAction>> votePhasesByDays = {};
  Map<int, List<NightPhaseAction>> nightPhasesByDays = {};

  bool isNightPhaseFinished() {
    MafLogger.d(_tag, 'isNightPhaseFinished');
    NightPhaseAction? phase;
    if (nightPhasesByDays.containsKey(currentDay)) {
      phase = nightPhasesByDays[currentDay]
          ?.firstWhereOrNull((element) => !element.isFinished);
    }
    MafLogger.d(_tag, 'isNightPhaseFinished: ${phase == null}');
    return phase == null;
  }

  bool isVotingPhaseFinished() {
    MafLogger.d(_tag, 'isVotingPhaseFinished');
    VotePhaseAction? phase;
    if (votePhasesByDays.containsKey(currentDay)) {
      phase = votePhasesByDays[currentDay]
          ?.firstWhereOrNull((element) => !element.isVoted);
    }
    MafLogger.d(_tag, 'isVotingPhaseFinished: ${phase == null}');
    return phase == null;
  }

  bool isSpeakPhaseFinished() {
    MafLogger.d(_tag, 'isSpeakPhaseFinished');
    SpeakPhaseAction? phase;
    if (speakPhasesByDays.containsKey(currentDay)) {
      phase = speakPhasesByDays[currentDay]
          ?.firstWhereOrNull((element) => !element.isFinished);
    }
    MafLogger.d(_tag, 'isSpeakPhaseFinished: ${phase == null}');
    return phase == null;
  }

  void addVotePhase(VotePhaseAction votePhaseAction) {
    MafLogger.d(_tag, 'addVotePhase: ${votePhaseAction.toString()}');
    if (votePhasesByDays.containsKey(currentDay)) {
      final phaseList = votePhasesByDays[currentDay]!;
      phaseList.add(votePhaseAction);
      MafLogger.d(
          _tag, 'votePhaseAction success, phaseList: ${phaseList.length}');
    } else {
      MafLogger.d(_tag, 'votePhaseAction success, created new phase list');
      votePhasesByDays[currentDay] = [votePhaseAction];
    }
  }

  void addNightPhase(NightPhaseAction nightPhaseAction) {
    MafLogger.d(_tag, 'addNightPhase: ${nightPhaseAction.toString()}');
    if (nightPhasesByDays.containsKey(currentDay)) {
      final phaseList = nightPhasesByDays[currentDay]!;
      phaseList.add(nightPhaseAction);
      MafLogger.d(
          _tag, 'addNightPhase success, phaseList: ${phaseList.length}');
    } else {
      MafLogger.d(_tag, 'addNightPhase success, created new phase list');
      nightPhasesByDays[currentDay] = [nightPhaseAction];
    }
  }

  void addSpeakPhase(SpeakPhaseAction speakPhaseAction) {
    MafLogger.d(_tag, 'addSpeakPhase: ${speakPhaseAction.toString()}');
    if (speakPhasesByDays.containsKey(currentDay)) {
      final phaseList = speakPhasesByDays[currentDay]!;
      phaseList.add(speakPhaseAction);
      MafLogger.d(
          _tag, 'addSpeakPhase success, phaseList: ${phaseList.length}');
    } else {
      MafLogger.d(_tag, 'addSpeakPhase success, created new phase list');
      speakPhasesByDays[currentDay] = [speakPhaseAction];
    }
  }

  SpeakPhaseAction? getCurrentSpeakPhase() => speakPhasesByDays[currentDay]
      ?.firstWhereOrNull((phase) => !phase.isFinished);

  VotePhaseAction? getCurrentVotePhase() =>
      votePhasesByDays[currentDay]?.firstWhereOrNull((phase) => !phase.isVoted);

  NightPhaseAction? getCurrentNightPhase() => nightPhasesByDays[currentDay]
      ?.firstWhereOrNull((phase) => !phase.isFinished);

  List<VotePhaseAction> getUniqueTodaysVotePhases() {
    List<VotePhaseAction> todaysPhases = votePhasesByDays[currentDay] ?? [];

    final seenIds = <int>{};
    return todaysPhases.where((phase) {
      final id = phase.playerOnVote.id;

      if (seenIds.add(id)) {
        return true;
      }
      return false;
    }).toList();
  }

  List<VotePhaseAction> getAllTodaysVotePhases() =>
      votePhasesByDays[currentDay] ?? [];

  bool updateSpeakPhase(SpeakPhaseAction speakPhaseAction) {
    MafLogger.d(_tag, 'updateSpeakPhase: $speakPhaseAction');
    if (speakPhasesByDays.containsKey(currentDay)) {
      final phaseList = speakPhasesByDays[currentDay]!;
      final index = phaseList.indexOf(speakPhaseAction);
      phaseList[index] = speakPhaseAction;
      return true;
    }
    return false;
  }

  bool updateVotePhase(VotePhaseAction votePhaseAction) {
    MafLogger.d(_tag, 'updateVotePhase: $votePhaseAction');
    if (votePhasesByDays.containsKey(currentDay)) {
      final phaseList = votePhasesByDays[currentDay]!;
      final index = phaseList.indexOf(votePhaseAction);
      phaseList[index] = votePhaseAction;
      return true;
    }
    return false;
  }

  bool updateNightPhase(NightPhaseAction nightPhaseAction) {
    MafLogger.d(_tag, 'updateNightPhase: $nightPhaseAction');
    if (nightPhasesByDays.containsKey(currentDay)) {
      final phaseList = nightPhasesByDays[currentDay]!;
      final index = phaseList.indexOf(nightPhaseAction);
      phaseList[index] = nightPhaseAction;
      return true;
    }
    return false;
  }
}
