import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/speaking_phase_manager.dart';

class SpeakingPhaseBloc extends Bloc<SpeakingPhaseEvent, SpeakingPhaseState> {
  static const String _tag = 'SpeakingPhaseBloc';
  final SpeakingPhaseManager speakingPhaseManager;

  SpeakingPhaseBloc({
    required this.speakingPhaseManager,
  }) : super(SpeakingPhaseState()) {
    on<GetCurrentSpeakPhaseEvent>(_getCurrentSpeakingPhaseEventHandler);
    on<StartSpeechEvent>(_startSpeechEventHandler);
    on<FinishSpeechEvent>(_finishSpeechEventHandler);
  }

  Future<void> _getCurrentSpeakingPhaseEventHandler(
      GetCurrentSpeakPhaseEvent event, emit) async {
    emit(SpeakingPhaseState(
      speakPhaseAction: await speakingPhaseManager.getCurrentPhase(),
    ));
  }

  Future<void> _startSpeechEventHandler(StartSpeechEvent event, emit) async {
    await speakingPhaseManager.startSpeech();
    emit(SpeakingPhaseState(
      speakPhaseAction: await speakingPhaseManager.getCurrentPhase(),
    ));
  }

  Future<void> _finishSpeechEventHandler(FinishSpeechEvent event, emit) async {
    await speakingPhaseManager.finishSpeech();
    emit(SpeakingPhaseState(
      speakPhaseAction: await speakingPhaseManager.getCurrentPhase(),
      isFinished: true,
    ));
  }
}

class SpeakingPhaseState {
  final SpeakPhaseAction? speakPhaseAction;
  final bool isFinished;

  SpeakingPhaseState({
    this.speakPhaseAction,
    this.isFinished = false,
  });
}

abstract class SpeakingPhaseEvent {}

class GetCurrentSpeakPhaseEvent extends SpeakingPhaseEvent {}

class StartSpeechEvent extends SpeakingPhaseEvent {}

class FinishSpeechEvent extends SpeakingPhaseEvent {}
