import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:mafia_board/data/model/game_info_model.dart';
import 'package:mafia_board/data/model/phase_type.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/vote_phase_manager.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_list/vote_item.dart';
import 'package:rxdart/rxdart.dart';

class VotePhaseListBloc extends Bloc<VotePhaseListEvent, VotePhaseListState> {
  final GameManager gameManager;
  final VotePhaseManager votePhaseManager;
  final List<VoteItem> voteList = [];
  final BehaviorSubject<List<VoteItem>> _voteListSubject = BehaviorSubject();
  StreamSubscription? _gameInfoSubscription;
  StreamSubscription? _gamePhaseSubscription;

  VotePhaseListBloc({
    required this.gameManager,
    required this.votePhaseManager,
  }) : super(VotePhaseListState()) {
    _listenToPlayersOnVote();
    _listenToNewGameInfo();
  }

  Future<void> _listenToNewGameInfo() async {
    await _gameInfoSubscription?.cancel();
    _gameInfoSubscription = null;
    _gameInfoSubscription = gameManager.gameInfoStream.listen((gameInfo) {
      if (gameInfo.currentPhase != PhaseType.vote) {
        voteList.clear();
        _voteListSubject.add(voteList);
      }
    });
  }

  Future<void> _listenToPlayersOnVote() async {
    await _gamePhaseSubscription?.cancel();
    _gamePhaseSubscription = null;
    _gamePhaseSubscription =
        votePhaseManager.currentVotePhaseStream.listen((newVotePhase) {
      voteList
          .add(VoteItem(playerNumber: newVotePhase.playerOnVote.seatNumber));
      _voteListSubject.add(voteList);
    });
  }

  Stream<List<VoteItem>> get voteListStream => _voteListSubject.stream;

  Future<void> _unsubscribe() async {
    await _gamePhaseSubscription?.cancel();
    _gamePhaseSubscription = null;
    await _gameInfoSubscription?.cancel();
    _gameInfoSubscription = null;
  }
}

class VotePhaseListEvent {}

class VotePhaseListState {
  final List<VoteItem> voteList;

  VotePhaseListState({this.voteList = const []});
}
