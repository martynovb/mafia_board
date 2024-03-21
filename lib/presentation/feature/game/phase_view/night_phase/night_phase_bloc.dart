import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/manager/game_flow/game_phase_manager.dart';
import 'package:mafia_board/domain/manager/game_flow/night_phase_manager.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/night_phase/night_phase_event.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/night_phase/night_phase_state.dart';

class NightPhaseBloc extends Bloc<NightPhaseEvent, NightPhaseState> {
  final GameManager gamePhaseManager;
  final NightPhaseManager nightPhaseManager;
  final PlayersRepo boardRepository;

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

  Future<void> _getCurrentNightPhaseEventHandler(
    GetCurrentNightPhaseEvent event,
    emit,
  ) async {
    emit(NightPhaseState(
      nightPhaseAction: await nightPhaseManager.getCurrentPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  Future<void> _startCurrentNightPhaseEventHandler(
    StartCurrentNightPhaseEvent event,
    emit,
  ) async {
    await nightPhaseManager.startCurrentNightPhase();
    emit(NightPhaseState(
      nightPhaseAction: await nightPhaseManager.getCurrentPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  Future<void> _finishCurrentNightPhaseEventHandler(
    FinishCurrentNightPhaseEvent event,
    emit,
  ) async {
    await nightPhaseManager.finishCurrentNightPhase();
    emit(NightPhaseState(
      allPlayers: boardRepository.getAllPlayers(),
      nightPhaseAction: await nightPhaseManager.getCurrentPhase(),
      isFinished: true,
    ));
  }

  Future<void> _killEventHandler(KillEvent event, emit) async {
    await nightPhaseManager.killPlayer(event.killedPlayer);
    emit(NightPhaseState(
      nightPhaseAction: await nightPhaseManager.getCurrentPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  Future<void> _cancelKillEventHandler(CancelKillEvent event, emit) async {
    await nightPhaseManager.cancelKillPlayer(event.killedPlayer);
    emit(NightPhaseState(
      nightPhaseAction: await nightPhaseManager.getCurrentPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  Future<void> _checkEventHandler(CheckEvent event, emit) async {
    await nightPhaseManager.checkPlayer(event.playerToCheck);

    emit(NightPhaseState(
      nightPhaseAction: await nightPhaseManager.getCurrentPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  Future<void> _cancelCheckEventHandler(CancelCheckEvent event, emit) async {
    await nightPhaseManager.cancelCheckPlayer(event.playerToCheck);

    emit(NightPhaseState(
      nightPhaseAction: await nightPhaseManager.getCurrentPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }

  Future<void> _visitEventHandler(VisitEvent event, emit) async {
    nightPhaseManager.visitPlayer(event.playerToVisit, event.role);
    emit(NightPhaseState(
      nightPhaseAction: await nightPhaseManager.getCurrentPhase(),
      allPlayers: boardRepository.getAllPlayers(),
    ));
  }
}
