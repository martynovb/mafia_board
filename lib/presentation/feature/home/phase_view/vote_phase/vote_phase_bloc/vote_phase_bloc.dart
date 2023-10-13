import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_phase_bloc/vote_phase_event.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_phase_bloc/vote_phase_state.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class VotePhaseBloc extends Bloc<VotePhaseEvent, VotePhaseState> {
  static const String _tag = 'VotePhaseBloc';
  final BoardRepo boardRepository;
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
    final currentVotePhase = phase?.getCurrentVotePhase();
    emit(VotePhaseState(
      title: _mapVotePageTitle(currentVotePhase),
      playersToKickText:
          _parsePlayersToKickToString(currentVotePhase?.playersToKick),
      playerOnVote: phase?.getCurrentVotePhase()?.playerOnVote,
      allAvailablePlayersToVote:
          gamePhaseManager.calculatePlayerVotingStatusMap(phase),
    ));
  }

  void _finishVotingEventHandler(FinishVoteAgainstEvent event, emit) async {
    try {
      gamePhaseManager.finishCurrentVotePhase();
      gamePhaseManager.nextGamePhase();
      final phase = await gamePhaseManager.gamePhase;
      final currentVotePhase = phase?.getCurrentVotePhase();
      emit(VotePhaseState(
        title: _mapVotePageTitle(currentVotePhase),
        playersToKickText:
            _parsePlayersToKickToString(currentVotePhase?.playersToKick),
        playerOnVote: phase?.getCurrentVotePhase()?.playerOnVote,
        allAvailablePlayersToVote:
            gamePhaseManager.calculatePlayerVotingStatusMap(phase),
      ));
    } on Exception catch (ex) {
      MafLogger.e(_tag, '_finishVotingEventHandler $ex');
    }
  }

  void _voteAgainstEventHandler(VoteAgainstEvent event, emit) async {
    try {
      gamePhaseManager.voteAgainst(
        currentPlayer: event.currentPlayer,
        voteAgainstPlayer: event.voteAgainstPlayer,
      );
      final phase = await gamePhaseManager.gamePhase;
      final currentVotePhase = phase?.getCurrentVotePhase();
      emit(VotePhaseState(
        title: _mapVotePageTitle(currentVotePhase),
        playersToKickText:
            _parsePlayersToKickToString(currentVotePhase?.playersToKick),
        playerOnVote: phase?.getCurrentVotePhase()?.playerOnVote,
        allAvailablePlayersToVote:
            gamePhaseManager.calculatePlayerVotingStatusMap(phase),
      ));
    } on Exception catch (ex) {
      MafLogger.e(_tag, 'error: _voteAgainstEventHandler $ex');
    }
  }

  void _cancelVoteAgainstEventHandler(
      CancelVoteAgainstEvent event, emit) async {
    try {
      final phase = await gamePhaseManager.gamePhase;
      if (phase?.getCurrentVotePhase()?.playerOnVote.id ==
          event.voteAgainstPlayer.id) {
        gamePhaseManager.cancelVoteAgainst(
          currentPlayer: event.currentPlayer,
          voteAgainstPlayer: event.voteAgainstPlayer,
        );
        final currentVotePhase = phase?.getCurrentVotePhase();
        emit(VotePhaseState(
          title: _mapVotePageTitle(currentVotePhase),
          playersToKickText:
              _parsePlayersToKickToString(currentVotePhase?.playersToKick),
          playerOnVote: phase?.getCurrentVotePhase()?.playerOnVote,
          allAvailablePlayersToVote:
              gamePhaseManager.calculatePlayerVotingStatusMap(phase),
        ));
      } else {
        MafLogger.d(_tag,
            "You can't cancel your vote for a user whose voting has already finished.");
      }
    } on Exception catch (ex) {
      MafLogger.e(_tag, 'error: _voteAgainstEventHandler $ex');
    }
  }

  String _mapVotePageTitle(VotePhaseAction? votePhaseAction) {
    if (votePhaseAction == null) {
      return '';
    } else if (votePhaseAction.shouldKickAllPlayers) {
      return 'Kick all players?';
    }
    return 'Vote against ${votePhaseAction.playerOnVote.nickname}';
  }

  String _parsePlayersToKickToString(List<PlayerModel>? players) {
    if (players == null || players.isEmpty) {
      return '';
    }

    return players.map((player) => player.nickname).join(', ');
  }
}
