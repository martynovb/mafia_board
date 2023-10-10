import 'package:mafia_board/data/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/phase_status.dart';
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

  final DateTime _createdAt = DateTime.now();

  DateTime get createdAt => _createdAt;

  void increaseDay(){
    currentDay++;
  }

  bool isSpeakingPhasesExist() {
    return speakPhasesByDays[currentDay]?.where((phase) => !phase.isLastWord).isNotEmpty ?? false;
  }

  bool isNightPhasesExist() {
    return nightPhasesByDays[currentDay]?.isNotEmpty ?? false;
  }

  bool isNightPhaseFinished() {
    NightPhaseAction? phase;
    if (nightPhasesByDays.containsKey(currentDay)) {
      phase = nightPhasesByDays[currentDay]?.firstWhereOrNull(
          (element) => element.status != PhaseStatus.finished);
    }
    MafLogger.d(_tag, 'isNightPhaseFinished: ${phase == null}');
    return phase == null;
  }

  bool isVotingPhaseFinished() {
    VotePhaseAction? phase;
    if (votePhasesByDays.containsKey(currentDay)) {
      phase = votePhasesByDays[currentDay]
          ?.firstWhereOrNull((element) => !element.isVoted);
    }
    MafLogger.d(_tag, 'isVotingPhaseFinished: ${phase == null}');
    return phase == null;
  }

  bool isSpeakPhaseFinished() {
    SpeakPhaseAction? phase;
    if (speakPhasesByDays.containsKey(currentDay)) {
      phase = speakPhasesByDays[currentDay]?.firstWhereOrNull(
          (element) => element.status != PhaseStatus.finished);
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

  void addAllNightPhases(List<NightPhaseAction> phases) {
    MafLogger.d(_tag, 'addAllSpeakPhases: ${phases.toString()}');
    if (nightPhasesByDays.containsKey(currentDay)) {
      final phaseList = nightPhasesByDays[currentDay]!;
      phaseList.addAll(phases);
      MafLogger.d(
          _tag, 'addSpeakPhase success, phaseList: ${phaseList.length}');
    } else {
      MafLogger.d(_tag, 'addSpeakPhase success, created new phase list');
      nightPhasesByDays[currentDay] = phases;
    }
  }

  void addSpeakPhase(SpeakPhaseAction speakPhaseAction, [int? day]) {
    MafLogger.d(_tag, 'addSpeakPhase: ${speakPhaseAction.toString()}');
    if (speakPhasesByDays.containsKey(day ?? currentDay)) {
      final phaseList = speakPhasesByDays[day ?? currentDay]!;
      phaseList.add(speakPhaseAction);
      MafLogger.d(
          _tag, 'addSpeakPhase success, phaseList: ${phaseList.length}');
    } else {
      MafLogger.d(_tag, 'addSpeakPhase success, created new phase list');
      speakPhasesByDays[day ?? currentDay] = [speakPhaseAction];
    }
  }

  void addAllSpeakPhases(List<SpeakPhaseAction> phases) {
    MafLogger.d(_tag, 'addAllSpeakPhases: ${phases.toString()}');
    if (speakPhasesByDays.containsKey(currentDay)) {
      final phaseList = speakPhasesByDays[currentDay]!;
      phaseList.addAll(phases);
      MafLogger.d(
          _tag, 'addSpeakPhase success, phaseList: ${phaseList.length}');
    } else {
      MafLogger.d(_tag, 'addSpeakPhase success, created new phase list');
      speakPhasesByDays[currentDay] = phases;
    }
  }

  SpeakPhaseAction? getCurrentSpeakPhase([int? day]) =>
      speakPhasesByDays[day ?? currentDay]?.firstWhereOrNull(
        (phase) =>
            phase.status == PhaseStatus.inProgress ||
            phase.status == PhaseStatus.notStarted,
      );

  bool? removeSpeakPhase(SpeakPhaseAction speakPhaseAction, [int? day]) =>
      speakPhasesByDays[day ?? currentDay]?.remove(speakPhaseAction);

  VotePhaseAction? getCurrentVotePhase() =>
      votePhasesByDays[currentDay]?.firstWhereOrNull((phase) => !phase.isVoted);

  NightPhaseAction? getCurrentNightPhase() => nightPhasesByDays[currentDay]
      ?.firstWhereOrNull((phase) => phase.status != PhaseStatus.finished);

  List<VotePhaseAction> getUniqueTodaysVotePhases([int? day]) {
    List<VotePhaseAction> todaysPhases =
        votePhasesByDays[day ?? currentDay] ?? [];
    List<VotePhaseAction> votePhases = [];
    List<VotePhaseAction> gunfightVotePhases = [];
    VotePhaseAction? askToKickAllPlayers;
    final seenIds = <int>{};
    for (var votePhase in todaysPhases) {
      final hashCode = votePhase.hashCode;
      if (seenIds.add(hashCode)) {
        if (votePhase.shouldKickAllPlayers) {
          askToKickAllPlayers = votePhase;
        }
        if (votePhase.isGunfight) {
          gunfightVotePhases.add(votePhase);
        } else {
          votePhases.add(votePhase);
        }
      }
    }

    if (askToKickAllPlayers != null) {
      return [askToKickAllPlayers];
    } else if (gunfightVotePhases.isNotEmpty) {
      return gunfightVotePhases;
    }

    return votePhases;
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

  bool voteAgainst({
    required PlayerModel currentPlayer,
    required PlayerModel voteAgainstPlayer,
  }) {
    return getAllTodaysVotePhases()
            .lastWhereOrNull(
              (phase) => phase.playerOnVote.id == voteAgainstPlayer.id,
            )
            ?.vote(currentPlayer) ??
        false;
  }

  bool cancelVoteAgainst({
    required PlayerModel currentPlayer,
    required PlayerModel voteAgainstPlayer,
  }) {
    return getAllTodaysVotePhases()
            .lastWhereOrNull(
              (phase) => phase.playerOnVote.id == voteAgainstPlayer.id,
            )
            ?.removeVote(currentPlayer) ??
        false;
  }
}