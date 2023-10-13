import 'package:mafia_board/data/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/presentation/maf_logger.dart';
import 'package:collection/collection.dart';

const _tag = 'GamePhaseModel';

class GamePhaseModel {
  int currentDay = 1;
  bool isStarted = false;

  final Map<int, List<SpeakPhaseAction>> _speakPhasesByDays = {};
  final Map<int, List<VotePhaseAction>> _votePhasesByDays = {};
  final Map<int, List<NightPhaseAction>> _nightPhasesByDays = {};

  final DateTime _createdAt = DateTime.now();

  DateTime get createdAt => _createdAt;

  void increaseDay(){
    currentDay++;
  }

  bool isSpeakingPhasesExist() {
    return _speakPhasesByDays[currentDay]?.where((phase) => !phase.isLastWord).isNotEmpty ?? false;
  }

  bool isNightPhasesExist() {
    return _nightPhasesByDays[currentDay]?.isNotEmpty ?? false;
  }

  bool isNightPhaseFinished() {
    NightPhaseAction? phase;
    if (_nightPhasesByDays.containsKey(currentDay)) {
      phase = _nightPhasesByDays[currentDay]?.firstWhereOrNull(
          (element) => element.status != PhaseStatus.finished);
    }
    MafLogger.d(_tag, 'isNightPhaseFinished: ${phase == null}');
    return phase == null;
  }

  bool isVotingPhaseFinished() {
    VotePhaseAction? phase;
    if (_votePhasesByDays.containsKey(currentDay)) {
      phase = _votePhasesByDays[currentDay]
          ?.firstWhereOrNull((element) => element.status != PhaseStatus.finished);
    }
    MafLogger.d(_tag, 'isVotingPhaseFinished: ${phase == null}');
    return phase == null;
  }

  bool isSpeakPhaseFinished() {
    SpeakPhaseAction? phase;
    if (_speakPhasesByDays.containsKey(currentDay)) {
      phase = _speakPhasesByDays[currentDay]?.firstWhereOrNull(
          (element) => element.status != PhaseStatus.finished);
    }
    MafLogger.d(_tag, 'isSpeakPhaseFinished: ${phase == null}');
    return phase == null;
  }

  void addVotePhase(VotePhaseAction votePhaseAction) {
    MafLogger.d(_tag, 'addVotePhase: ${votePhaseAction.toString()}');
    if (_votePhasesByDays.containsKey(currentDay)) {
      final phaseList = _votePhasesByDays[currentDay]!;
      phaseList.add(votePhaseAction);
      MafLogger.d(
          _tag, 'votePhaseAction success, phaseList: ${phaseList.length}');
    } else {
      MafLogger.d(_tag, 'votePhaseAction success, created new phase list');
      _votePhasesByDays[currentDay] = [votePhaseAction];
    }
  }

  void addNightPhase(NightPhaseAction nightPhaseAction) {
    MafLogger.d(_tag, 'addNightPhase: ${nightPhaseAction.toString()}');
    if (_nightPhasesByDays.containsKey(currentDay)) {
      final phaseList = _nightPhasesByDays[currentDay]!;
      phaseList.add(nightPhaseAction);
      MafLogger.d(
          _tag, 'addNightPhase success, phaseList: ${phaseList.length}');
    } else {
      MafLogger.d(_tag, 'addNightPhase success, created new phase list');
      _nightPhasesByDays[currentDay] = [nightPhaseAction];
    }
  }

  void addAllNightPhases(List<NightPhaseAction> phases) {
    MafLogger.d(_tag, 'addAllSpeakPhases: ${phases.toString()}');
    if (_nightPhasesByDays.containsKey(currentDay)) {
      final phaseList = _nightPhasesByDays[currentDay]!;
      phaseList.addAll(phases);
      MafLogger.d(
          _tag, 'addSpeakPhase success, phaseList: ${phaseList.length}');
    } else {
      MafLogger.d(_tag, 'addSpeakPhase success, created new phase list');
      _nightPhasesByDays[currentDay] = phases;
    }
  }

  void addSpeakPhase(SpeakPhaseAction speakPhaseAction, [int? day]) {
    MafLogger.d(_tag, 'addSpeakPhase: ${speakPhaseAction.toString()}');
    if (_speakPhasesByDays.containsKey(day ?? currentDay)) {
      final phaseList = _speakPhasesByDays[day ?? currentDay]!;
      phaseList.add(speakPhaseAction);
      MafLogger.d(
          _tag, 'addSpeakPhase success, phaseList: ${phaseList.length}');
    } else {
      MafLogger.d(_tag, 'addSpeakPhase success, created new phase list');
      _speakPhasesByDays[day ?? currentDay] = [speakPhaseAction];
    }
  }

  void addAllSpeakPhases(List<SpeakPhaseAction> phases) {
    MafLogger.d(_tag, 'addAllSpeakPhases: ${phases.toString()}');
    if (_speakPhasesByDays.containsKey(currentDay)) {
      final phaseList = _speakPhasesByDays[currentDay]!;
      phaseList.addAll(phases);
      MafLogger.d(
          _tag, 'addSpeakPhase success, phaseList: ${phaseList.length}');
    } else {
      MafLogger.d(_tag, 'addSpeakPhase success, created new phase list');
      _speakPhasesByDays[currentDay] = phases;
    }
  }

  SpeakPhaseAction? getCurrentSpeakPhase([int? day]) =>
      _speakPhasesByDays[day ?? currentDay]?.firstWhereOrNull(
        (phase) =>
            phase.status == PhaseStatus.inProgress ||
            phase.status == PhaseStatus.notStarted,
      );

  bool? removeSpeakPhase(SpeakPhaseAction speakPhaseAction, [int? day]) =>
      _speakPhasesByDays[day ?? currentDay]?.remove(speakPhaseAction);

  bool? removeVotePhase(VotePhaseAction votePhaseAction, [int? day]) =>
      _votePhasesByDays[day ?? currentDay]?.remove(votePhaseAction);

  VotePhaseAction? getCurrentVotePhase() =>
      _votePhasesByDays[currentDay]?.firstWhereOrNull((phase) => phase.status != PhaseStatus.finished);

  NightPhaseAction? getCurrentNightPhase() => _nightPhasesByDays[currentDay]
      ?.firstWhereOrNull((phase) => phase.status != PhaseStatus.finished);

  List<VotePhaseAction> getUniqueTodaysVotePhases([int? day]) {
    List<VotePhaseAction> todaysPhases =
        _votePhasesByDays[day ?? currentDay] ?? [];
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
      _votePhasesByDays[currentDay] ?? [];

  Map<int, List<NightPhaseAction>> getAllNightPhases() =>
      _nightPhasesByDays;

  bool updateSpeakPhase(SpeakPhaseAction speakPhaseAction) {
    MafLogger.d(_tag, 'updateSpeakPhase: $speakPhaseAction');
    if (_speakPhasesByDays.containsKey(currentDay)) {
      final phaseList = _speakPhasesByDays[currentDay]!;
      final index = phaseList.indexOf(speakPhaseAction);
      phaseList[index] = speakPhaseAction;
      return true;
    }
    return false;
  }

  bool updateVotePhase(VotePhaseAction votePhaseAction) {
    MafLogger.d(_tag, 'updateVotePhase: $votePhaseAction');
    if (_votePhasesByDays.containsKey(currentDay)) {
      final phaseList = _votePhasesByDays[currentDay]!;
      final index = phaseList.indexOf(votePhaseAction);
      phaseList[index] = votePhaseAction;
      return true;
    }
    return false;
  }

  bool updateNightPhase(NightPhaseAction nightPhaseAction) {
    MafLogger.d(_tag, 'updateNightPhase: $nightPhaseAction');
    if (_nightPhasesByDays.containsKey(currentDay)) {
      final phaseList = _nightPhasesByDays[currentDay]!;
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
