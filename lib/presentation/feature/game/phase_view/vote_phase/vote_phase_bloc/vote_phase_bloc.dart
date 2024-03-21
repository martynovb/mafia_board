import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_model.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/manager/game_flow/game_phase_manager.dart';
import 'package:mafia_board/domain/manager/game_flow/speaking_phase_manager.dart';
import 'package:mafia_board/domain/manager/game_flow/vote_phase_manager.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_phase_bloc/vote_phase_event.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_phase_bloc/vote_phase_state.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class VotePhaseBloc extends Bloc<VotePhaseEvent, VotePhaseState> {
  static const String _tag = 'VotePhaseBloc';
  final PlayersRepo boardRepository;
  final GameManager gamePhaseManager;
  final VotePhaseManager votePhaseManager;
  final SpeakingPhaseManager speakingPhaseManager;

  VotePhaseBloc({
    required this.gamePhaseManager,
    required this.votePhaseManager,
    required this.speakingPhaseManager,
    required this.boardRepository,
  }) : super(
          VotePhaseState(
            phaseStatus: PhaseStatus.notStarted,
            players: boardRepository.getAllPlayers(),
            votePhase: VotePhaseModel.inital(),
          ),
        ) {
    on<VoteAgainstEvent>(_voteAgainstEventHandler);
    on<GetVotingDataEvent>(_initializeDataEventHandler);
    on<FinishVoteAgainstEvent>(_finishVotingEventHandler);
    on<CancelVoteAgainstEvent>(_cancelVoteAgainstEventHandler);
  }

  Future<void> _initializeDataEventHandler(
    GetVotingDataEvent event,
    emit,
  ) async {
    final currentVotePhase = await votePhaseManager.getCurrentPhase();
    emit(
      VotePhaseState(
        phaseStatus: currentVotePhase?.status ?? PhaseStatus.notStarted,
        votePhase: currentVotePhase,
        players: boardRepository.getAllPlayers(),
        allAvailablePlayersToVote:
            await votePhaseManager.calculatePlayerVotingStatusMap(),
      ),
    );
  }

  Future<void> _finishVotingEventHandler(
    FinishVoteAgainstEvent event,
    emit,
  ) async {
    try {
      await votePhaseManager.finishCurrentVotePhase();
      final currentVotePhase = await votePhaseManager.getCurrentPhase();
      final currentSpeakPhase = await speakingPhaseManager.getCurrentPhase();
      if (currentSpeakPhase == null && currentVotePhase != null) {
        emit(
          VotePhaseState(
            votePhase: currentVotePhase,
            phaseStatus: currentVotePhase.status,
            players: boardRepository.getAllPlayers(),
            allAvailablePlayersToVote:
                await votePhaseManager.calculatePlayerVotingStatusMap(),
          ),
        );
      } else {
        emit(
          VotePhaseState(
            phaseStatus: PhaseStatus.finished,
            votePhase: currentVotePhase,
            players: boardRepository.getAllPlayers(),
          ),
        );
      }
    } on Exception catch (ex) {
      MafLogger.e(_tag, '_finishVotingEventHandler $ex');
    }
  }

  Future<void> _voteAgainstEventHandler(
    VoteAgainstEvent event,
    emit,
  ) async {
    try {
      await votePhaseManager.voteAgainst(
        currentPlayer: event.currentPlayer,
        voteAgainstPlayer: event.voteAgainstPlayer,
      );
      final currentVotePhase = await votePhaseManager.getCurrentPhase();
      emit(
        VotePhaseState(
          votePhase: currentVotePhase,
          phaseStatus: currentVotePhase?.status ?? PhaseStatus.notStarted,
          players: boardRepository.getAllPlayers(),
          allAvailablePlayersToVote:
              await votePhaseManager.calculatePlayerVotingStatusMap(),
        ),
      );
    } on Exception catch (ex) {
      MafLogger.e(_tag, 'error: _voteAgainstEventHandler $ex');
    }
  }

  Future<void> _cancelVoteAgainstEventHandler(
    CancelVoteAgainstEvent event,
    emit,
  ) async {
    try {
      var currentVotePhase = await votePhaseManager.getCurrentPhase();
      if (currentVotePhase?.playerOnVote.tempId ==
          event.voteAgainstPlayer.tempId) {
        votePhaseManager.cancelVoteAgainst(
          currentPlayer: event.currentPlayer,
          voteAgainstPlayer: event.voteAgainstPlayer,
        );
        currentVotePhase = await votePhaseManager.getCurrentPhase();
        emit(
          VotePhaseState(
            votePhase: currentVotePhase,
            phaseStatus: currentVotePhase?.status ?? PhaseStatus.notStarted,
            players: boardRepository.getAllPlayers(),
            allAvailablePlayersToVote:
                await votePhaseManager.calculatePlayerVotingStatusMap(),
          ),
        );
      } else {
        MafLogger.d(_tag,
            "You can't cancel your vote for a user whose voting has already finished.");
      }
    } on Exception catch (ex) {
      MafLogger.e(_tag, 'error: _voteAgainstEventHandler $ex');
    }
  }
}
