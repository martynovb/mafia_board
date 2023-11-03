import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';
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
import 'package:mafia_board/presentation/feature/widgets/info_field.dart';

class PlayersSheetPage extends StatefulWidget {
  final Function()? nextPage;

  const PlayersSheetPage({
    super.key,
    this.nextPage,
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
  late GameBloc _boardBloc;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _playersSheetBloc = GetIt.instance<PlayersSheetBloc>();
    _roleBloc = GetIt.instance<RoleBloc>();
    _boardBloc = GetIt.instance<GameBloc>();
    super.initState();
  }

  @override
  void dispose() {
    _playersSheetBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BlocConsumer(
                              listener: (context, GameState state) {
                              },
                              bloc: _boardBloc,
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
                                        state is InitialBoardState ||
                                        (state is GamePhaseState &&
                                            state.gameInfo?.isGameStarted ==
                                                false))
                                      _startGameButton()
                                    else
                                      Container()
                                  ],
                                );
                              }),
                          ElevatedButton(
                              onPressed: () =>
                                  _playersSheetBloc.add(SetTestDataEvent()),
                              child: const Text('Set Test Data')),
                          _sheetHeader(),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: Dimensions.sidePadding0_5x,
                                right: Dimensions.sidePadding0_5x),
                            child: StreamBuilder(
                              stream: _playersSheetBloc.playersStream,
                              builder: (context,
                                  AsyncSnapshot<SheetDataState> snapshot) {
                                if (snapshot.hasData) {
                                  isGameStarted =
                                      snapshot.data?.gameInfo?.isGameStarted ??
                                          false;
                                  return _playersSheet(snapshot.data!);
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ),
                        ],
                      ));
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
            child: playerModel.id.isEmpty
                ? IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _playersSheetBloc.add(
                          FindUserEvent(seatNumber: playerModel.seatNumber));
                    },
                  )
                : GestureDetector(
                    child: Text(playerModel.nickname),
                    onTap: () {
                      _playersSheetBloc.add(
                          FindUserEvent(seatNumber: playerModel.seatNumber));
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
                    playerModel.id,
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
              playerModel.id,
              playerModel.seatNumber,
              playerModel.role,
            )),
          ),
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
                              seatNumber, newRole ?? Role.NONE.name),
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
        _boardBloc.add(StartGameEvent());
        widget.nextPage!();
      },
      child: const Text(
        'Start Game',
        style: TextStyle(fontSize: 32),
      ));
}
