import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/night_phase_manager.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_event.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_state.dart';

class NightPhaseBloc extends Bloc<NightPhaseEvent, NightPhaseState> {
  static const String _tag = 'SpeakingPhaseBloc';
  final GameManager gamePhaseManager;
  final NightPhaseManager nightPhaseManager;
  final BoardRepo boardRepository;

  NightPhaseBloc({
    required this.gamePhaseManager,
    required this.nightPhaseManager,
    required this.boardRepository,
  }) : super(NightPhaseState()) {
    on<GetCurrentNightPhaseEvent>(_getCurrentNightPhaseEventHandler);
    on<StartCurrentNightPhaseEvent>(_startCurrentNightPhaseEventHandler);
    on<FinishCurrentNightPhaseEvent>(_finishCurrentNightPhaseEventHandler);
    on<KillEvent>(_killEventHandler);
    on<CancelKillEvent>(_cancelKillEventHandler);
    on<CheckEvent>(_checkEventHandler);
    on<CancelCheckEvent>(_cancelCheckEventHandler);
    on<VisitEvent>(_visitEventHandler);
  }

  void _getCurrentNightPhaseEventHandler(
    GetCurrentNightPhaseEvent event,
    emit,
  ) {
    emit(NightPhaseState(
      nightPhaseAction: nightPhaseManager.getCurrentPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  void _startCurrentNightPhaseEventHandler(
    StartCurrentNightPhaseEvent event,
    emit,
  ) {
    nightPhaseManager.startCurrentNightPhase();
    emit(NightPhaseState(
      nightPhaseAction: nightPhaseManager.getCurrentPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  void _finishCurrentNightPhaseEventHandler(
    FinishCurrentNightPhaseEvent event,
    emit,
  ) {
    nightPhaseManager.finishCurrentNightPhase();
    emit(NightPhaseState(
      nightPhaseAction: nightPhaseManager.getCurrentPhase(),
      isFinished: true,
    ));
  }

  void _killEventHandler(KillEvent event, emit) {
    nightPhaseManager.killPlayer(event.killedPlayer);
    emit(NightPhaseState(
      nightPhaseAction: nightPhaseManager.getCurrentPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  void _cancelKillEventHandler(CancelKillEvent event, emit) {
    nightPhaseManager.cancelKillPlayer(event.killedPlayer);
    emit(NightPhaseState(
      nightPhaseAction: nightPhaseManager.getCurrentPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  void _checkEventHandler(CheckEvent event, emit) {
    nightPhaseManager.checkPlayer(event.playerToCheck);

    emit(NightPhaseState(
      nightPhaseAction: nightPhaseManager.getCurrentPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  void _cancelCheckEventHandler(CancelCheckEvent event, emit) {
    nightPhaseManager.cancelCheckPlayer(event.playerToCheck);

    emit(NightPhaseState(
      nightPhaseAction: nightPhaseManager.getCurrentPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  void _visitEventHandler(VisitEvent event, emit) {
    nightPhaseManager.visitPlayer(event.playerToVisit, event.role);
    emit(NightPhaseState(
      nightPhaseAction: nightPhaseManager.getCurrentPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }
}
