import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/model/game_info_model.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/vote_phase_manager.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_list/vote_item.dart';
import 'package:rxdart/rxdart.dart';

class VotePhaseListBloc extends Bloc<VotePhaseListEvent, VotePhaseListState> {
  final GameManager gameManager;
  final VotePhaseManager votePhaseManager;
  final BehaviorSubject<List<VoteItem>> _voteListSubject = BehaviorSubject();
  StreamSubscription? _gamePhaseSubscription;

  VotePhaseListBloc({
    required this.gameManager,
    required this.votePhaseManager,
  }) : super(VotePhaseListState()) {
    _listenToGamePhase();
  }

  Stream<List<VoteItem>> get voteListStream => _voteListSubject.stream;


  void _listenToGamePhase() {
    _gamePhaseSubscription =
        gameManager.gameInfoStream.listen((gamePhaseModel) {
      _voteListSubject.add(
        _getTodaysVoteList(gamePhaseModel),
      );
    });
  }

  List<VoteItem> _getTodaysVoteList(GameInfoModel gameInfo) {
    return votePhaseManager
        .getAllPhases(gameInfo.day)
        .map((votePhase) =>
            VoteItem(playerNumber: votePhase.playerOnVote.playerNumber))
        .toList();
  }

  void dispose() {
    _voteListSubject.close();
    _gamePhaseSubscription?.cancel();
    _gamePhaseSubscription = null;
  }
}

class VotePhaseListEvent {}

class VotePhaseListState {
  final List<VoteItem> voteList;

  VotePhaseListState({this.voteList = const []});
}
