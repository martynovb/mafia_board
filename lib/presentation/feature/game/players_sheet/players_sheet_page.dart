import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/club_member_model.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/game_status.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_event.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_state.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/players_sheet_bloc/players_sheet_bloc.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/players_sheet_bloc/players_sheet_event.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/players_sheet_bloc/players_sheet_state.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/role_bloc/role_bloc.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/role_bloc/role_event.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/role_bloc/role_state.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/widgets/blur_widget.dart';
import 'package:mafia_board/presentation/feature/game/users/bloc/user_list_bloc.dart';
import 'package:mafia_board/presentation/feature/game/users/bloc/user_list_event.dart';
import 'package:mafia_board/presentation/feature/game/users/bloc/user_list_state.dart';
import 'package:mafia_board/presentation/feature/widgets/dialogs.dart';
import 'package:mafia_board/presentation/feature/widgets/info_field.dart';

class PlayersSheetPage extends StatefulWidget {
  final ClubModel club;
  final Function()? nextPage;
  final Function(PlayerModel playerModel) onPPKGameFinished;

  const PlayersSheetPage({
    super.key,
    this.nextPage,
    required this.club,
    required this.onPPKGameFinished,
  });

  @override
  State<PlayersSheetPage> createState() => _PlayersSheetPageState();
}

class _PlayersSheetPageState extends State<PlayersSheetPage>
    with AutomaticKeepAliveClientMixin {
  final int _voteColumnFlex = 0;
  final int _nicknameColumnFlex = 5;
  final int _foulsColumnFlex = 4;
  final int _roleColumnFlex = 5;
  bool isGameStarted = false;

  late PlayersSheetBloc _playersSheetBloc;
  late RoleBloc _roleBloc;
  late GameBloc _gameBloc;
  late UserListBloc _userListBloc;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _playersSheetBloc = GetIt.instance<PlayersSheetBloc>();
    _roleBloc = GetIt.instance<RoleBloc>();
    _gameBloc = GetIt.instance<GameBloc>();
    _userListBloc = GetIt.instance();
    super.initState();
  }

  @override
  void dispose() {
    _playersSheetBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder(
      bloc: _playersSheetBloc,
      builder: (BuildContext context, SheetState state) {
        if (state is InitialSheetState) {
          return Center(
            child: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: Dimensions.maxPlayersListWidth),
                      child: BlocConsumer(
                          listener: (context, GameState state) {
                            if (state is GamePhaseState) {
                              isGameStarted = state.currentGame?.gameStatus ==
                                  GameStatus.inProgress;
                            }
                          },
                          bloc: _gameBloc,
                          builder: (context, GameState state) {
                            return Column(
                              children: [
                                if (state is ErrorBoardState) ...[
                                  const SizedBox(
                                    height: Dimensions.defaultSidePadding,
                                  ),
                                  _errorView(state.errorMessage)
                                ],
                                if (state is ErrorBoardState ||
                                    state is InitialGameState ||
                                    (state is GamePhaseState &&
                                        state.currentGame?.gameStatus !=
                                            GameStatus.inProgress))
                                  _startGameButton()
                                else
                                  Container(),
                                _sheetHeader(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: Dimensions.sidePadding0_5x,
                                      right: Dimensions.sidePadding0_5x),
                                  child: StreamBuilder(
                                    stream: _playersSheetBloc.playersStream,
                                    builder: (context,
                                        AsyncSnapshot<SheetDataState>
                                            snapshot) {
                                      if (snapshot.hasData) {
                                        return _playersSheet(snapshot.data!);
                                      } else {
                                        return Container();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          }));
                },
              ),
            ),
          );
        }
        return const Center(
          child: Text('Something went wrong'),
        );
      },
    );
  }

  Widget _sheetHeader() {
    return Container(
        padding: const EdgeInsets.all(Dimensions.sidePadding0_5x),
        height: Dimensions.playerSheetHeaderHeight,
        child: Row(
          children: [
            Expanded(
              flex: _voteColumnFlex,
              child: const Padding(
                  padding: EdgeInsets.only(
                    left: Dimensions.sidePadding0_5x,
                  ),
                  child: Icon(
                    Icons.numbers,
                    size: Dimensions.defaultIconSize,
                  )),
            ),
            const VerticalDivider(
              color: Colors.transparent,
            ),
            Expanded(
              flex: _nicknameColumnFlex,
              child: const Center(child: Text('nickname')),
            ),
            const VerticalDivider(
              color: Colors.transparent,
            ),
            Expanded(
              flex: _foulsColumnFlex,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check,
                    size: Dimensions.defaultIconSize,
                  ),
                  SizedBox(
                    width: Dimensions.sidePadding0_5x,
                  ),
                  Text('fouls'),
                  SizedBox(
                    width: Dimensions.defaultSidePadding,
                  ),
                ],
              ),
            ),
            const VerticalDivider(
              color: Colors.transparent,
            ),
            Expanded(
              flex: _roleColumnFlex,
              child: const Center(child: Text('role')),
            ),
          ],
        ));
  }

  Widget _playersSheet(SheetDataState sheetDataState) => Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.white30),
            borderRadius: const BorderRadius.all(Radius.circular(0))),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sheetDataState.players.length,
          separatorBuilder: (context, index) => const Divider(
            height: Dimensions.sidePadding0_5x,
          ),
          itemBuilder: (__, index) => _playerItem(
            index,
            sheetDataState.players[index],
          ),
        ),
      );

  Widget _playerItem(int seatNumber, PlayerModel playerModel) {
    return Container(
      height: Dimensions.playerItemHeight,
      color: !playerModel.isInGame()
          ? Colors.red.withOpacity(0.5)
          : Colors.transparent,
      child: Row(
        children: [
          Expanded(
            flex: _voteColumnFlex,
            child: SizedBox(
              width: Dimensions.defaultIconSize,
              height: Dimensions.defaultIconSize,
              child: Center(
                child: Text((playerModel.seatNumber).toString()),
              ),
            ),
          ),
          const VerticalDivider(
            color: Colors.white,
          ),
          Expanded(
            flex: _nicknameColumnFlex,
            child: playerModel.tempId.isEmpty
                ? IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      final clubMember = await _showUsersBottomSheet(context);
                      if (clubMember != null) {
                        _playersSheetBloc.add(
                          SetClubMemberEvent(
                            seatNumber: playerModel.seatNumber,
                            clubMember: clubMember,
                          ),
                        );
                      }
                    },
                  )
                : GestureDetector(
                    child: Text(playerModel.nickname),
                    onTap: () async {
                      final user = await _showUsersBottomSheet(context);
                      if (user != null) {
                        _playersSheetBloc.add(
                          SetClubMemberEvent(
                            seatNumber: playerModel.seatNumber,
                            clubMember: user,
                          ),
                        );
                      }
                    },
                  ),
          ),
          const VerticalDivider(
            color: Colors.white,
          ),
          Expanded(
            flex: _foulsColumnFlex,
            child: Center(
              child: SizedBox(
                  width: Dimensions.foulsViewWidth,
                  child: _foulsBuilder(
                    playerModel.tempId,
                    playerModel.fouls,
                    isGameStarted,
                  )),
            ),
          ),
          const VerticalDivider(
            color: Colors.white,
          ),
          Expanded(
            flex: _roleColumnFlex,
            child: Center(
                child: _roleDropdown(
              playerModel.tempId,
              playerModel.seatNumber,
              playerModel.role,
            )),
          ),
          if (isGameStarted) ...[
            const VerticalDivider(
              color: Colors.white,
            ),
            Center(child: contextMenu(playerModel))
          ],
        ],
      ),
    );
  }

  Widget _foulsBuilder(String playerId, int fouls, bool isGameStarted) =>
      InkWell(
          onTap: isGameStarted ? () {} : null,
          child: GestureDetector(
            onTap: isGameStarted
                ? () => _playersSheetBloc.add(
                      AddFoulEvent(
                        playerId: playerId,
                        newFoulsCount: fouls + 1,
                      ),
                    )
                : null,
            onLongPress: () {
              _playersSheetBloc.add(
                AddFoulEvent(
                  playerId: playerId,
                  newFoulsCount: 0,
                ),
              );
            },
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: fouls,
              itemBuilder: (__, index) => const Icon(
                size: Dimensions.foulItemWidth,
                Icons.check,
                color: Colors.red,
              ),
            ),
          ));

  Widget _roleDropdown(String playerId, int seatNumber, Role playerRole) {
    return BlurWidget(
        isBlured: isGameStarted,
        placeholder: const Center(
          child: Text('***'),
        ),
        child: BlocBuilder(
            bloc: _roleBloc,
            builder: (BuildContext context, ShowRolesState state) {
              return DropdownButton<String>(
                underline: const SizedBox(),
                value: playerRole.name,
                onChanged: isGameStarted
                    ? null
                    : (String? newRole) {
                        _playersSheetBloc.add(
                          ChangeRoleEvent(playerId: playerId, newRole: newRole),
                        );
                        _roleBloc.add(
                          RecalculateRolesEvent(
                              seatNumber, newRole ?? Role.none.name),
                        );
                      },
                items: state.roles.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    alignment: AlignmentDirectional.center,
                    value: entry.key.name,
                    enabled: entry.value,
                    child: Text(
                      entry.key.name,
                      style: TextStyle(
                        color: entry.value ? Colors.white : Colors.green,
                      ),
                    ),
                  );
                }).toList(),
              );
            }));
  }

  Widget _errorView(String errorMessage) {
    return InfoField(
      message: errorMessage,
      infoFieldType: InfoFieldType.error,
    );
  }

  Widget _startGameButton() => GestureDetector(
      onTap: () {
        _gameBloc.add(StartGameEvent(widget.club.id));
        widget.nextPage!();
      },
      child: const Text(
        'Start Game',
        style: TextStyle(fontSize: 32),
      ));

  Widget contextMenu(PlayerModel player) => PopupMenuButton<String>(
        onSelected: (String value) {
          if (value == 'PPK') {
            _showFinishConfirmationPPKDialog(player, context);
          }
        },
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem<String>(
            value: 'PPK',
            child: Text('PPK'),
          ),
        ],
        icon: const Icon(Icons.more_vert),
      );

  Future<void> _showFinishConfirmationPPKDialog(
      PlayerModel player, BuildContext context) async {
    await showDefaultDialog(
      context: context,
      title: 'PPK for (#${player.seatNumber}: ${player.nickname})?',
      actions: <Widget>[
        TextButton(
          child: const Text("Finish game"),
          onPressed: () {
            _gameBloc.add(FinishGameEvent(FinishGameType.ppk, widget.club, player.tempId));
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<ClubMemberModel?> _showUsersBottomSheet(BuildContext context) {
    final Completer<ClubMemberModel?> selectedUserCompleter = Completer();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return BlocBuilder(
            bloc: _userListBloc,
            builder: (context, UserListState state) {
              return Padding(
                  padding: const EdgeInsets.only(
                    top: Dimensions.defaultSidePadding,
                  ),
                  child: ListView.builder(
                    itemCount: state.clubMember.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(state.clubMember[index].user.nickname),
                        subtitle: Text(state.clubMember[index].user.email),
                        onTap: () {
                          Navigator.pop(context);
                          selectedUserCompleter.complete(state.clubMember[index]);
                        },
                      );
                    },
                  ));
            });
      },
    );
    _userListBloc.add(FetchUserListEvent(widget.club.id));
    return selectedUserCompleter.future;
  }
}
