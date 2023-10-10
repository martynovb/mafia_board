import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';

class SpeakingPhaseBloc extends Bloc<SpeakingPhaseEvent, SpeakingPhaseState> {
  static const String _tag = 'SpeakingPhaseBloc';
   final GamePhaseManager gamePhaseManager;

  SpeakingPhaseBloc({
    required this.gamePhaseManager,
  }) : super(SpeakingPhaseState()) {
    on<GetCurrentSpeakPhaseEvent>(_getCurrentSpeakingPhaseEventHandler);
    on<StartSpeechEvent>(_startSpeechEventHandler);
    on<FinishSpeechEvent>(_finishSpeechEventHandler);
  }

  void _getCurrentSpeakingPhaseEventHandler(
      GetCurrentSpeakPhaseEvent event, emit) async {
    final phase = await gamePhaseManager.gamePhase;
    emit(SpeakingPhaseState(speakPhaseAction: phase.getCurrentSpeakPhase()));
  }

  void _startSpeechEventHandler(StartSpeechEvent event, emit) async {
    gamePhaseManager.startSpeech();
    final phase = await gamePhaseManager.gamePhase;
    emit(SpeakingPhaseState(speakPhaseAction: phase.getCurrentSpeakPhase()));
  }

  void _finishSpeechEventHandler(FinishSpeechEvent event, emit) async {
    gamePhaseManager.finishSpeech();
    final phase = await gamePhaseManager.gamePhase;
    emit(SpeakingPhaseState(speakPhaseAction: phase.getCurrentSpeakPhase(), isFinished: true));
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
