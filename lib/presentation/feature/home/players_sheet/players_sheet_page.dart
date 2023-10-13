import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_bloc.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_event.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_bloc/players_sheet_bloc.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_bloc/players_sheet_event.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_bloc/players_sheet_state.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/role_bloc/role_bloc.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/role_bloc/role_event.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/role_bloc/role_state.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/widgets/blur_widget.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/widgets/hover_detector_widget.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/widgets/nickname_widget.dart';

class PlayersSheetPage extends StatefulWidget {
  const PlayersSheetPage({
    super.key,
  });

  @override
  State<PlayersSheetPage> createState() => _PlayersSheetPageState();
}

class _PlayersSheetPageState extends State<PlayersSheetPage> {
  final int _voteColumnFlex = 0;
  final int _nicknameColumnFlex = 5;
  final int _foulsColumnFlex = 4;
  final int _roleColumnFlex = 5;

  late PlayersSheetBloc _playersSheetBloc;
  late RoleBloc _roleBloc;
  late BoardBloc _boardBloc;

  @override
  void initState() {
    _playersSheetBloc = GetIt.instance<PlayersSheetBloc>();
    _roleBloc = GetIt.instance<RoleBloc>();
    _boardBloc = GetIt.instance<BoardBloc>();
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
                  child:  Column(
                        children: [
                          ElevatedButton(
                              onPressed: () => setTestData(),
                              child: Text('Set Test Data')),
                          _sheetHeader(),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: Dimensions.smallSidePadding,
                                right: Dimensions.smallSidePadding),
                            child: StreamBuilder(
                                stream: _playersSheetBloc.playersStream,
                                builder: (context,
                                    AsyncSnapshot<SheetDataState> snapshot) {
                                  if (snapshot.hasData) {
                                    return _playersSheet(snapshot.data!);
                                  } else {
                                    return Container();
                                  }
                                }),
                          )
                        ],
                      )));
        }
        return const Center(
          child: Text('Something went wrong'),
        );
      },
    );
  }

  Widget _sheetHeader() {
    return Container(
        padding: const EdgeInsets.all(Dimensions.smallSidePadding),
        height: Dimensions.playerSheetHeaderHeight,
        child: Row(
          children: [
            Expanded(
              flex: _voteColumnFlex,
              child: const Padding(
                  padding: EdgeInsets.only(
                    left: Dimensions.smallSidePadding,
                  ),
                  child: Icon(
                    Icons.thumb_up,
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
              child: const Center(child: Text('fouls')),
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
            height: Dimensions.smallSidePadding,
          ),
          itemBuilder: (__, index) => _playerItem(
              index,
              sheetDataState.players[index],
              sheetDataState.gameInfo?.isGameFinished ?? true),
        ),
      );

  Widget _playerItem(int index, PlayerModel playerModel, bool isGameStarted) {
    return Container(
      height: Dimensions.playerItemHeight,
      color: !playerModel.isAvailable()
          ? Colors.red.withOpacity(0.5)
          : Colors.transparent,
      child: Row(
        children: [
          Expanded(
            flex: _voteColumnFlex,
            child: SizedBox(
              width: Dimensions.defaultIconSize,
              height: Dimensions.defaultIconSize,
              child: InkWell(
                onTap: isGameStarted
                    ? () {
                        _boardBloc
                            .add(PutOnVoteEvent(playerOnVote: playerModel));
                      }
                    : null,
                child: Center(
                  child: HoverDetectorWidget(
                    enabled: isGameStarted,
                    child: Text((index + 1).toString()),
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(
            color: Colors.white,
          ),
          Expanded(
            flex: _nicknameColumnFlex,
            child: NicknameWidget(
              enabled: !isGameStarted,
              nickname: playerModel.nickname,
              onChanged: (nickname) => _playersSheetBloc.add(
                ChangeNicknameEvent(
                  playerId: index,
                  newNickname: nickname,
                ),
              ),
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
              playerModel.role,
              isGameStarted,
            )),
          ),
        ],
      ),
    );
  }

  Widget _foulsBuilder(int playerId, int fouls, bool isGameStarted) => InkWell(
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
            Icons.close,
            color: Colors.red,
          ),
        ),
      ));

  Widget _roleDropdown(int playerId, Role playerRole, bool isGameStarted) {
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
                              playerId, newRole ?? Role.NONE.name),
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

  void setTestData() {
    for (var i = 1; i <= 10; i++) {
      _playersSheetBloc.add(ChangeNicknameEvent(
        playerId: i - 1,
        newNickname: 'Player#$i',
      ));
    }
    _playersSheetBloc.add(
      ChangeRoleEvent(playerId: 0, newRole: Role.DON.name),
    );
    _roleBloc.add(
      RecalculateRolesEvent(0, Role.DON.name),
    );

    _playersSheetBloc.add(
      ChangeRoleEvent(playerId: 1, newRole: Role.MAFIA.name),
    );
    _roleBloc.add(
      RecalculateRolesEvent(1, Role.MAFIA.name),
    );

    _playersSheetBloc.add(
      ChangeRoleEvent(playerId: 2, newRole: Role.MAFIA.name),
    );
    _roleBloc.add(
      RecalculateRolesEvent(2, Role.MAFIA.name),
    );

    _playersSheetBloc.add(
      ChangeRoleEvent(playerId: 3, newRole: Role.SHERIFF.name),
    );
    _roleBloc.add(
      RecalculateRolesEvent(3, Role.SHERIFF.name),
    );

    _playersSheetBloc.add(
      ChangeRoleEvent(playerId: 4, newRole: Role.CIVILIAN.name),
    );
    _roleBloc.add(
      RecalculateRolesEvent(4, Role.CIVILIAN.name),
    );

    _playersSheetBloc.add(
      ChangeRoleEvent(playerId: 5, newRole: Role.CIVILIAN.name),
    );
    _roleBloc.add(
      RecalculateRolesEvent(5, Role.CIVILIAN.name),
    );

    _playersSheetBloc.add(
      ChangeRoleEvent(playerId: 6, newRole: Role.CIVILIAN.name),
    );
    _roleBloc.add(
      RecalculateRolesEvent(6, Role.CIVILIAN.name),
    );

    _playersSheetBloc.add(
      ChangeRoleEvent(playerId: 7, newRole: Role.CIVILIAN.name),
    );
    _roleBloc.add(
      RecalculateRolesEvent(7, Role.CIVILIAN.name),
    );

    _playersSheetBloc.add(
      ChangeRoleEvent(playerId: 8, newRole: Role.CIVILIAN.name),
    );
    _roleBloc.add(
      RecalculateRolesEvent(8, Role.CIVILIAN.name),
    );

    _playersSheetBloc.add(
      ChangeRoleEvent(playerId: 9, newRole: Role.CIVILIAN.name),
    );
    _roleBloc.add(
      RecalculateRolesEvent(9, Role.CIVILIAN.name),
    );

    _playersSheetBloc.add(
      ChangeRoleEvent(playerId: 10, newRole: Role.CIVILIAN.name),
    );
    _roleBloc.add(
      RecalculateRolesEvent(10, Role.CIVILIAN.name),
    );

    setState(() {});
  }
}
