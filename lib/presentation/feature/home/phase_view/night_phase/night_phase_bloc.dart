import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_event.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_state.dart';

class NightPhaseBloc extends Bloc<NightPhaseEvent, NightPhaseState> {
  static const String _tag = 'SpeakingPhaseBloc';
  final GamePhaseManager gamePhaseManager;
  final BoardRepository boardRepository;

  NightPhaseBloc({
    required this.gamePhaseManager,
    required this.boardRepository,
  }) : super(NightPhaseState()) {
    on<GetCurrentNightPhaseEvent>(_getCurrentNightPhaseEventHandler);
    on<StartCurrentNightPhaseEvent>(_startCurrentNightPhaseEventHandler);
    on<FinishCurrentNightPhaseEvent>(_finishCurrentNightPhaseEventHandler);
    on<KillEvent>(_killEventHandler);
    on<CheckEvent>(_checkEventHandler);
    on<VisitEvent>(_visitEventHandler);
  }

  void _getCurrentNightPhaseEventHandler(
    GetCurrentNightPhaseEvent event,
    emit,
  ) {
    emit(NightPhaseState(
      nightPhaseAction: gamePhaseManager.getCurrentNightPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  void _startCurrentNightPhaseEventHandler(
    StartCurrentNightPhaseEvent event,
    emit,
  ) {
    gamePhaseManager.startCurrentNightPhase();
    emit(NightPhaseState(
      nightPhaseAction: gamePhaseManager.getCurrentNightPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  void _finishCurrentNightPhaseEventHandler(
    FinishCurrentNightPhaseEvent event,
    emit,
  ) {
    gamePhaseManager.finishCurrentNightPhase();
    emit(NightPhaseState(
      nightPhaseAction: gamePhaseManager.getCurrentNightPhase(),
      isFinished: true,
    ));
  }

  void _killEventHandler(KillEvent event, emit) {
    gamePhaseManager.killPlayer(event.killedPlayer, event.role);
    emit(NightPhaseState(
      nightPhaseAction: gamePhaseManager.getCurrentNightPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  void _checkEventHandler(CheckEvent event, emit) {
    final checkedPlayer =
        gamePhaseManager.checkPlayer(event.playerToCheck, event.role);

    emit(CheckResultState(
      nightPhaseAction: gamePhaseManager.getCurrentNightPhase(),
      playerModel: checkedPlayer,
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  void _visitEventHandler(VisitEvent event, emit) {
    gamePhaseManager.visitPlayer(event.playerToVisit, event.role);
    emit(NightPhaseState(
      nightPhaseAction: gamePhaseManager.getCurrentNightPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }
}
