import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/speaking_phase_manager.dart';

class SpeakingPhaseBloc extends Bloc<SpeakingPhaseEvent, SpeakingPhaseState> {
  static const String _tag = 'SpeakingPhaseBloc';
  final SpeakingPhaseManager speakingPhaseManager;
  final BoardRepo boardRepo;

  SpeakingPhaseBloc({
    required this.speakingPhaseManager,
    required this.boardRepo,
  }) : super(SpeakingPhaseState()) {
    on<GetCurrentSpeakPhaseEvent>(_getCurrentSpeakingPhaseEventHandler);
    on<StartSpeechEvent>(_startSpeechEventHandler);
    on<FinishSpeechEvent>(_finishSpeechEventHandler);
  }

  Future<void> _getCurrentSpeakingPhaseEventHandler(
      GetCurrentSpeakPhaseEvent event, emit) async {
    final currentSpeakPhase = await speakingPhaseManager.getCurrentPhase();
    final currentSpeakerId = currentSpeakPhase?.playerId;
    emit(SpeakingPhaseState(
      speakPhaseAction: currentSpeakPhase,
      speaker: currentSpeakerId != null ? await boardRepo.getPlayerById(currentSpeakerId) : null,

    ));
  }

  Future<void> _startSpeechEventHandler(StartSpeechEvent event, emit) async {
    await speakingPhaseManager.startSpeech();
    final currentSpeakPhase = await speakingPhaseManager.getCurrentPhase();
    final currentSpeakerId = currentSpeakPhase?.playerId;
    emit(SpeakingPhaseState(
      speakPhaseAction: currentSpeakPhase,
      speaker: currentSpeakerId != null ? await boardRepo.getPlayerById(currentSpeakerId) : null,

    ));
  }

  Future<void> _finishSpeechEventHandler(FinishSpeechEvent event, emit) async {
    await speakingPhaseManager.finishSpeech();
    final currentSpeakPhase = await speakingPhaseManager.getCurrentPhase();
    final currentSpeakerId = currentSpeakPhase?.playerId;
    emit(SpeakingPhaseState(
      speakPhaseAction: currentSpeakPhase,
      speaker: currentSpeakerId != null ? await boardRepo.getPlayerById(currentSpeakerId) : null,
      isFinished: true,
    ));
  }
}

class SpeakingPhaseState {
  final SpeakPhaseAction? speakPhaseAction;
  final PlayerModel? speaker;
  final bool isFinished;

  SpeakingPhaseState({
    this.speakPhaseAction,
    this.speaker,
    this.isFinished = false,
  });
}

abstract class SpeakingPhaseEvent {}

class GetCurrentSpeakPhaseEvent extends SpeakingPhaseEvent {}

class StartSpeechEvent extends SpeakingPhaseEvent {}

class FinishSpeechEvent extends SpeakingPhaseEvent {}
