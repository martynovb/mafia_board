import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/data/repo/game_phase/base_phase_repo.dart';

class SpeakPhaseRepo extends BasePhaseRepo<SpeakPhaseModel> {
  SpeakPhaseRepo({required super.firestore});

  @override
  bool isExist({required int day}) {
    return list.any((phase) => phase.currentDay == day && !phase.isLastWord);
  }
}
