import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/speaking_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/vote_phase_manager.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_phase_bloc/vote_phase_event.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_phase_bloc/vote_phase_state.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class VotePhaseBloc extends Bloc<VotePhaseEvent, VotePhaseState> {
  static const String _tag = 'VotePhaseBloc';
  final BoardRepo boardRepository;
  final GameManager gamePhaseManager;
  final VotePhaseManager votePhaseManager;
  final SpeakingPhaseManager speakingPhaseManager;

  VotePhaseBloc({
    required this.gamePhaseManager,
    required this.votePhaseManager,
    required this.speakingPhaseManager,
    required this.boardRepository,
  }) : super(VotePhaseState()) {
    on<VoteAgainstEvent>(_voteAgainstEventHandler);
    on<GetVotingDataEvent>(_initializeDataEventHandler);
    on<FinishVoteAgainstEvent>(_finishVotingEventHandler);
    on<CancelVoteAgainstEvent>(_cancelVoteAgainstEventHandler);
  }

  Future<void> _initializeDataEventHandler(
      GetVotingDataEvent event, emit) async {
    final currentVotePhase = await votePhaseManager.getCurrentPhase();
    emit(VotePhaseState(
      status: currentVotePhase?.status ?? PhaseStatus.notStarted,
      title: _mapVotePageTitle(currentVotePhase),
      playersToKickText:
          _parsePlayersToKickToString(currentVotePhase?.playersToKick),
      playerOnVote: currentVotePhase?.playerOnVote,
      allAvailablePlayersToVote:
          await votePhaseManager.calculatePlayerVotingStatusMap(),
    ));
  }

  Future<void> _finishVotingEventHandler(
      FinishVoteAgainstEvent event, emit) async {
    try {
      await votePhaseManager.finishCurrentVotePhase();
      final currentVotePhase = await votePhaseManager.getCurrentPhase();
      final currentSpeakPhase = await speakingPhaseManager.getCurrentPhase();
      if (currentSpeakPhase == null && currentVotePhase != null) {
        emit(VotePhaseState(
          status: currentVotePhase.status,
          title: _mapVotePageTitle(currentVotePhase),
          playersToKickText:
              _parsePlayersToKickToString(currentVotePhase.playersToKick),
          playerOnVote: currentVotePhase.playerOnVote,
          allAvailablePlayersToVote:
              await votePhaseManager.calculatePlayerVotingStatusMap(),
        ));
      } else {
        emit(VotePhaseState(status: PhaseStatus.finished));
      }
    } on Exception catch (ex) {
      MafLogger.e(_tag, '_finishVotingEventHandler $ex');
    }
  }

  Future<void> _voteAgainstEventHandler(VoteAgainstEvent event, emit) async {
    try {
      votePhaseManager.voteAgainst(
        currentPlayer: event.currentPlayer,
        voteAgainstPlayer: event.voteAgainstPlayer,
      );
      final currentVotePhase = await votePhaseManager.getCurrentPhase();
      emit(VotePhaseState(
        status: currentVotePhase?.status ?? PhaseStatus.notStarted,
        title: _mapVotePageTitle(currentVotePhase),
        playersToKickText:
            _parsePlayersToKickToString(currentVotePhase?.playersToKick),
        playerOnVote: currentVotePhase?.playerOnVote,
        allAvailablePlayersToVote:
            await votePhaseManager.calculatePlayerVotingStatusMap(),
      ));
    } on Exception catch (ex) {
      MafLogger.e(_tag, 'error: _voteAgainstEventHandler $ex');
    }
  }

  Future<void> _cancelVoteAgainstEventHandler(
      CancelVoteAgainstEvent event, emit) async {
    try {
      var currentVotePhase = await votePhaseManager.getCurrentPhase();
      if (currentVotePhase?.playerOnVote.id == event.voteAgainstPlayer.id) {
        votePhaseManager.cancelVoteAgainst(
          currentPlayer: event.currentPlayer,
          voteAgainstPlayer: event.voteAgainstPlayer,
        );
        currentVotePhase = await votePhaseManager.getCurrentPhase();
        emit(VotePhaseState(
          status: currentVotePhase?.status ?? PhaseStatus.notStarted,
          title: _mapVotePageTitle(currentVotePhase),
          playersToKickText:
              _parsePlayersToKickToString(currentVotePhase?.playersToKick),
          playerOnVote: currentVotePhase?.playerOnVote,
          allAvailablePlayersToVote:
              await votePhaseManager.calculatePlayerVotingStatusMap(),
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