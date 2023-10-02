import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/data/model/game_phase_model.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/domain/game_phase_manager.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_phase_bloc/vote_phase_event.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_phase_bloc/vote_phase_state.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class VotePhaseBloc extends Bloc<VotePhaseEvent, VotePhaseState> {
  static const String _tag = 'VotePhaseBloc';
  final BoardRepository boardRepository;
  final GamePhaseManager gamePhaseManager;

  VotePhaseBloc({
    required this.gamePhaseManager,
    required this.boardRepository,
  }) : super(VotePhaseState()) {
    on<VoteAgainstEvent>(_voteAgainstEventHandler);
    on<GetVotingDataEvent>(_initializeDataEventHandler);
    on<FinishVoteAgainstEvent>(_finishVotingEventHandler);
    on<CancelVoteAgainstEvent>(_cancelVoteAgainstEventHandler);
  }

  void _initializeDataEventHandler(GetVotingDataEvent event, emit) async {
    final phase = await gamePhaseManager.gamePhase;
    emit(VotePhaseState(
      playerOnVote: phase.getCurrentVotePhase()?.playerOnVote,
      allAvailablePlayersToVote: _calculateAvailableToVotePlayers(phase),
    ));
  }

  void _finishVotingEventHandler(FinishVoteAgainstEvent event, emit) async {
    try {
      gamePhaseManager.finishCurrentVotePhase();
      gamePhaseManager.nextGamePhase();
      final phase = await gamePhaseManager.gamePhase;
      emit(VotePhaseState(
        playerOnVote: phase.getCurrentVotePhase()?.playerOnVote,
        allAvailablePlayersToVote: _calculateAvailableToVotePlayers(phase),
      ));
    } on Exception catch (ex) {
      MafLogger.e(_tag, '_finishVotingEventHandler $ex');
    }
  }

  Map<PlayerModel, bool> _calculateAvailableToVotePlayers(
      GamePhaseModel phase) {
    final allTodayVotePhases = phase.getUniqueTodaysVotePhases();
    final allAvailablePlayers = boardRepository.getAllAvailablePlayers();
    final Map<PlayerModel, bool> allAvailableToVotePlayers = {};

    for (var player in allAvailablePlayers) {
      bool playerHasAlreadyVoted = allTodayVotePhases
          .any((votePhase) => votePhase.votedPlayers.contains(player));
      allAvailableToVotePlayers[player] = playerHasAlreadyVoted;
    }

    return allAvailableToVotePlayers;
  }

  void _voteAgainstEventHandler(VoteAgainstEvent event, emit) async {
    try {
      gamePhaseManager.voteAgainst(
        currentPlayer: event.currentPlayer,
        voteAgainstPlayer: event.voteAgainstPlayer,
      );
      final phase = await gamePhaseManager.gamePhase;
      emit(VotePhaseState(
        playerOnVote: phase.getCurrentVotePhase()?.playerOnVote,
        allAvailablePlayersToVote: _calculateAvailableToVotePlayers(phase),
      ));
    } on Exception catch (ex) {
      MafLogger.e(_tag, 'error: _voteAgainstEventHandler $ex');
    }
  }

  void _cancelVoteAgainstEventHandler(
      CancelVoteAgainstEvent event, emit) async {
    try {
      final phase = await gamePhaseManager.gamePhase;
      if(phase.getCurrentVotePhase()?.playerOnVote.id == event.voteAgainstPlayer.id) {
        gamePhaseManager.cancelVoteAgainst(
          currentPlayer: event.currentPlayer,
          voteAgainstPlayer: event.voteAgainstPlayer,
        );
        emit(VotePhaseState(
          playerOnVote: phase
              .getCurrentVotePhase()
              ?.playerOnVote,
          allAvailablePlayersToVote: _calculateAvailableToVotePlayers(phase),
        ));
      } else {
        MafLogger.d(_tag, "You can't cancel your vote for a user whose voting has already finished.");
      }
    } on Exception catch (ex) {
      MafLogger.e(_tag, 'error: _voteAgainstEventHandler $ex');
    }
  }
}
