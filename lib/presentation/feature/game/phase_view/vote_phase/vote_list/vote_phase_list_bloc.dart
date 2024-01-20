import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/manager/game_flow/game_phase_manager.dart';
import 'package:mafia_board/domain/manager/game_flow/vote_phase_manager.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_list/vote_item.dart';
import 'package:rxdart/rxdart.dart';

class VotePhaseListBloc extends Bloc<VotePhaseListEvent, VotePhaseListState> {
  final GameManager gameManager;
  final VotePhaseManager votePhaseManager;
  final List<VoteItem> voteList = [];
  final BehaviorSubject<List<VoteItem>> _voteListSubject = BehaviorSubject();
  StreamSubscription? _dayInfoSubscription;
  StreamSubscription? _gamePhaseSubscription;

  VotePhaseListBloc({
    required this.gameManager,
    required this.votePhaseManager,
  }) : super(VotePhaseListState()) {
    _listenToPlayersOnVote();
    _listenToNewDayInfo();
    on<UnVotePhaseEvent>(_unvoteEventHandler);
  }

  Future<void> _unvoteEventHandler(UnVotePhaseEvent event, emit) async {
    await votePhaseManager.revokePutOnVote(event.playerOnVote);
  }

  Future<void> _listenToNewDayInfo() async {
    await _dayInfoSubscription?.cancel();
    _dayInfoSubscription = null;
    _dayInfoSubscription = gameManager.gameStream.listen((game) {
      if (game?.currentDayInfo.currentPhase != PhaseType.vote) {
        voteList.clear();
        _voteListSubject.add(voteList);
      }
    });
  }

  Future<void> _listenToPlayersOnVote() async {
    await _gamePhaseSubscription?.cancel();
    _gamePhaseSubscription = null;
    _gamePhaseSubscription =
        votePhaseManager.currentVotePhaseStream.listen((newVotePhase) async {
      voteList.clear();
      final allTodaysPhases = await votePhaseManager.getAllTodaysPhases();
      if (allTodaysPhases.isNotEmpty) {
        voteList.addAll(
          allTodaysPhases.map(
            (votePhase) => VoteItem(playerOnVote: votePhase.playerOnVote),
          ),
        );
      }
      _voteListSubject.add(voteList);
    });
  }

  Stream<List<VoteItem>> get voteListStream => _voteListSubject.stream;

  Future<void> _unsubscribe() async {
    await _gamePhaseSubscription?.cancel();
    _gamePhaseSubscription = null;
    await _dayInfoSubscription?.cancel();
    _dayInfoSubscription = null;
  }
}

class VotePhaseListEvent {}

class UnVotePhaseEvent extends VotePhaseListEvent {
  final PlayerModel playerOnVote;

  UnVotePhaseEvent(this.playerOnVote);
}

class VotePhaseListState {
  final List<VoteItem> voteList;

  VotePhaseListState({this.voteList = const []});
}
