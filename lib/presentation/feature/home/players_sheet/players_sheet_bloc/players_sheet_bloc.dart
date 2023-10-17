import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/data/constants.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/domain/game_history_manager.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/domain/player_manager.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_bloc/players_sheet_event.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_bloc/players_sheet_state.dart';
import 'package:rxdart/rxdart.dart';

class PlayersSheetBloc extends Bloc<SheetEvent, SheetState> {
  final BoardRepo boardRepository;
  final GameHistoryManager gameHistoryManager;
  final GameManager gamePhaseManager;
  final PlayerManager playerManager;

  StreamSubscription? _gamePhaseSubscription;
  final BehaviorSubject<SheetDataState> _playersSubject = BehaviorSubject();

  PlayersSheetBloc({
    required this.boardRepository,
    required this.gameHistoryManager,
    required this.gamePhaseManager,
    required this.playerManager,
  }) : super(InitialSheetState()) {
    on<AddFoulEvent>(_addFoulHandler);
    on<ChangeRoleEvent>(_changeRoleHandler);
    on<ChangeNicknameEvent>(_changeNicknameHandler);
    on<KillPlayerHandler>(_killPlayerHandler);
    _playersSubject
        .add(SheetDataState(players: boardRepository.getAllPlayers()));
    _listenToGamePhase();
  }

  void _listenToGamePhase() {
    _gamePhaseSubscription =
        gamePhaseManager.gameInfoStream.listen((gamePhaseModel) {
      _playersSubject.add(SheetDataState(
        players: boardRepository.getAllPlayers(),
        gameInfo: gamePhaseModel,
      ));
    });
  }

  Stream<SheetDataState> get playersStream => _playersSubject.stream;

  void _addFoulHandler(AddFoulEvent event, emit) async {
    if (event.newFoulsCount > Constants.maxFouls) return;
    if (event.newFoulsCount != 0) {
      await playerManager.addFoul(event.playerId, event.newFoulsCount);
    } else {
      await playerManager.clearFouls(event.playerId);
    }
    _playersSubject.add(SheetDataState(
      players: boardRepository.getAllPlayers(),
      gameInfo: await gamePhaseManager.gameInfo,
    ));
    final player = await boardRepository.getPlayerByIndex(event.playerId);
    if (player != null) {
      gameHistoryManager.logAddFoul(player: player);
    }
  }

  void _changeRoleHandler(ChangeRoleEvent event, emit) async {
    boardRepository.updatePlayer(
      event.playerId,
      role: roleMapper(event.newRole),
    );
    _playersSubject.add(SheetDataState(
      players: boardRepository.getAllPlayers(),
      gameInfo: await gamePhaseManager.gameInfo,
    ));
  }

  void _changeNicknameHandler(ChangeNicknameEvent event, emit) async {
    boardRepository.updatePlayer(
      event.playerId,
      nickname: event.newNickname,
    );
    _playersSubject.add(SheetDataState(
      players: boardRepository.getAllPlayers(),
      gameInfo: await gamePhaseManager.gameInfo,
    ));
  }

  void _killPlayerHandler(KillPlayerHandler event, emit) async {
    boardRepository.updatePlayer(
      event.playerId,
      isKilled: true,
    );
    _playersSubject.add(SheetDataState(
      players: boardRepository.getAllPlayers(),
      gameInfo: await gamePhaseManager.gameInfo,
    ));
  }

  void dispose() {
    _gamePhaseSubscription?.cancel();
    _gamePhaseSubscription = null;
    _playersSubject.close();
  }
}
