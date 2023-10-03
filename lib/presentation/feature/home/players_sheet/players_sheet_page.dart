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
import 'package:mafia_board/presentation/feature/home/players_sheet/widgets/nickname_widget.dart';

class PlayersSheetPage extends StatefulWidget {
  const PlayersSheetPage({
    super.key,
  });

  @override
  State<PlayersSheetPage> createState() => _PlayersSheetPageState();
}

class _PlayersSheetPageState extends State<PlayersSheetPage> {
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
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _playersSheetBloc,
      builder: (BuildContext context, SheetState state) {
        if (state is ShowSheetState) {
          return Center(
            child: SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () => setTestData(),
                    child: Text('Set Test Data')),
                _sheetHeader(),
                 _playersSheet(state.players),
              ],
            )),
          );
        }
        return const Center(
          child: Text('Something went wrong'),
        );
      }, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _sheetHeader() {
    return Container(
        padding: const EdgeInsets.all(8.0),
        height: Dimensions.playerItemHeight,
        child: Row(
          children: const [
            SizedBox(
              width: 24,
              child: Center(child: Text('#')),
            ),
            VerticalDivider(
              color: Colors.transparent,
            ),
            Expanded(
              flex: 5,
              child: Center(child: Text('nickname')),
            ),
            VerticalDivider(
              color: Colors.transparent,
            ),
            SizedBox(
              width: Dimensions.foulsViewWidth,
              child: Center(child: Text('fouls')),
            ),
            VerticalDivider(
              color: Colors.transparent,
            ),
            SizedBox(
              width: Dimensions.roleViewWidth,
              child: Center(child: Text('role')),
            ),
          ],
        ));
  }

  Widget _playersSheet(List<PlayerModel> players) => Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.white60),
            borderRadius: const BorderRadius.all(Radius.circular(4))),
        child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: players.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (__, index) => _playerItem(
            index,
            players[index],
          ),
        ),
      );

  Widget _playerItem(int index, PlayerModel playerModel) {
    return GestureDetector(
      onTap: () {
        _boardBloc.add(PutOnVoteEvent(playerOnVote: playerModel));
      },
      child: Container(
          height: Dimensions.playerItemHeight,
          color: playerModel.isRemoved
              ? Colors.red.withOpacity(0.5)
              : Colors.transparent,
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Center(
                  child: Text((index + 1).toString()),
                ),
              ),
              const VerticalDivider(
                color: Colors.white,
              ),
              Expanded(
                flex: 5,
                child: NicknameWidget(
                  nickname: playerModel.nickname,
                  onChanged: (nickname) =>
                      _playersSheetBloc.add(ChangeNicknameEvent(
                    playerId: index,
                    newNickname: nickname,
                  )),
                ),
              ),
              const VerticalDivider(
                color: Colors.white,
              ),
              _foulsBuilder(playerModel.id, playerModel.fouls),
              const VerticalDivider(
                color: Colors.white,
              ),
              SizedBox(
                width: Dimensions.roleViewWidth,
                child: _roleDropdown(playerModel.id, playerModel.role),
              ),
            ],
          )),
    );
  }

  Widget _foulsBuilder(int playerId, int fouls) => InkWell(
      onTap: () {},
      child: GestureDetector(
        onTap: () => _playersSheetBloc.add(
          AddFoulEvent(
            playerId: playerId,
            newFoulsCount: fouls + 1,
          ),
        ),
        onLongPress: () {
          _playersSheetBloc.add(
            AddFoulEvent(
              playerId: playerId,
              newFoulsCount: 0,
            ),
          );
        },
        child: SizedBox(
          width: Dimensions.foulsViewWidth,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: fouls,
            itemBuilder: (__, index) => const Icon(
              size: 24,
              Icons.close,
              color: Colors.red,
            ),
          ),
        ),
      ));

  Widget _roleDropdown(int playerId, Role playerRole) {
    return BlocBuilder(
        bloc: _roleBloc,
        builder: (BuildContext context, ShowRolesState state) {
          return DropdownButton<String>(
            value: playerRole.name,
            onChanged: (String? newRole) {
              _playersSheetBloc.add(
                ChangeRoleEvent(playerId: playerId, newRole: newRole),
              );
              _roleBloc.add(
                RecalculateRolesEvent(playerId, newRole ?? Role.NONE.name),
              );
            },
            items: state.roles.entries.map((entry) {
              return DropdownMenuItem<String>(
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
        });
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
