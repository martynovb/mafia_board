import 'package:mafia_board/domain/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/repo/game_phase/base_phase_repo_local.dart';

class SpeakPhaseRepoLocal extends BasePhaseRepoLocal<SpeakPhaseAction> {
  @override
  bool isExist({required int day}) {
    return list.any((phase) => phase.currentDay == day && !phase.isLastWord);
  }
}
