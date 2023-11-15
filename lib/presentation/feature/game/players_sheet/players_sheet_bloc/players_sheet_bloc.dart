import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/model/user_model.dart';
import 'package:mafia_board/data/constants.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/game_history_manager.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/domain/player_manager.dart';
import 'package:mafia_board/domain/role_manager.dart';
import 'package:mafia_board/domain/usecase/get_current_game_usecase.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/players_sheet_bloc/players_sheet_event.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/players_sheet_bloc/players_sheet_state.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class PlayersSheetBloc extends Bloc<SheetEvent, SheetState> {
  final PlayersRepo boardRepository;
  final GameHistoryManager gameHistoryManager;
  final GameManager gamePhaseManager;
  final PlayerManager playerManager;
  final RoleManager roleManager;
  final GetCurrentGameUseCase getCurrentGameUseCase;

  StreamSubscription? _gamePhaseSubscription;
  final BehaviorSubject<SheetDataState> _playersSubject = BehaviorSubject();

  PlayersSheetBloc({
    required this.boardRepository,
    required this.gameHistoryManager,
    required this.gamePhaseManager,
    required this.playerManager,
    required this.roleManager,
    required this.getCurrentGameUseCase,
  }) : super(InitialSheetState()) {
    on<AddFoulEvent>(_addFoulHandler);
    on<FindUserEvent>(_findUserHandler);
    on<ChangeRoleEvent>(_changeRoleHandler);
    on<KillPlayerHandler>(_killPlayerHandler);
    on<SetTestDataEvent>(_setTestDataHandler);
    _playersSubject
        .add(SheetDataState(players: boardRepository.getAllPlayers()));
    _listenToGamePhase();
  }

  void _listenToGamePhase() {
    _gamePhaseSubscription =
        gamePhaseManager.dayInfoStream.listen((gamePhaseModel) async {
      _playersSubject.add(SheetDataState(
        players: boardRepository.getAllPlayers(),
        currentGame: await getCurrentGameUseCase.execute(),
      ));
    });
  }

  Stream<SheetDataState> get playersStream => _playersSubject.stream;

  void _findUserHandler(FindUserEvent event, emit) async {
    final nick = String.fromCharCodes(
        List.generate(6, (index) => Random().nextInt(33) + 89));
    final newUser = UserModel(
        id: const Uuid().v1(), nickname: nick, email: '$nick@mail.com');
    boardRepository.setUser(event.seatNumber, newUser);

    _playersSubject.add(SheetDataState(
      players: boardRepository.getAllPlayers(),
      currentGame: await getCurrentGameUseCase.execute(),
    ));
  }

  void _addFoulHandler(AddFoulEvent event, emit) async {
    if (event.newFoulsCount > Constants.maxFouls) return;
    if (event.newFoulsCount != 0) {
      await playerManager.addFoul(event.playerId, event.newFoulsCount);
    } else {
      await playerManager.clearFouls(event.playerId);
    }
    _playersSubject.add(SheetDataState(
      players: boardRepository.getAllPlayers(),
      currentGame: await getCurrentGameUseCase.execute(),
    ));
    final player = await boardRepository.getPlayerById(event.playerId);
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
      currentGame: await getCurrentGameUseCase.execute(),
    ));
  }

  void _killPlayerHandler(KillPlayerHandler event, emit) async {
    boardRepository.updatePlayer(
      event.playerId,
      isKilled: true,
    );
    _playersSubject.add(SheetDataState(
      players: boardRepository.getAllPlayers(),
      currentGame: await getCurrentGameUseCase.execute(),
    ));
  }

  Future<void> _setTestDataHandler(event, emit) async {
    List<Role> roles = roleManager.availableRoles..shuffle();
    for (var i = 1; i <= roles.length; i++) {
      Role role = roles[i - 1];
      final nick = String.fromCharCodes(
          List.generate(6, (index) => Random().nextInt(33) + 89));

      final newUser = UserModel(
          id: const Uuid().v1(), nickname: nick, email: '$nick@mail.com');

      boardRepository.setUser(i, newUser);
      await boardRepository.updatePlayer(newUser.id, role: role);
      roleManager.recalculateAvailableRoles(i, role);
    }

    _playersSubject.add(SheetDataState(
      players: boardRepository.getAllPlayers(),
      currentGame: await getCurrentGameUseCase.execute(),
    ));
  }

  void dispose() {
    _gamePhaseSubscription?.cancel();
    _gamePhaseSubscription = null;
  }
}
