import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/domain/model/winner_type.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_event.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_state.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:intl/intl.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/widgets/info_field.dart';

class ClubDetailsPage extends StatefulWidget {
  const ClubDetailsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ClubDetailsPage> createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage> {
  late ClubsDetailsBloc clubDetailsBloc;
  static const String _deleteGameOption = 'delete_game';

  @override
  void initState() {
    clubDetailsBloc = GetIt.instance<ClubsDetailsBloc>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final club = args?['club'];
    clubDetailsBloc.add(GetClubDetailsEvent(club));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: clubDetailsBloc,
      builder: (context, ClubState state) {
        return Scaffold(
            appBar: AppBar(
              title: Text(state.club?.title ?? 'Club details'),
              centerTitle: true,
            ),
            body: LayoutBuilder(
              builder: (context, _) {
                if (state.status == StateStatus.data) {
                  return _gamesList(state.allGames);
                } else if (state.status == StateStatus.error) {
                  return Center(
                    child: InfoField(
                      message: state.errorMessage,
                      infoFieldType: InfoFieldType.error,
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ));
      },
    );
  }

  Widget _gamesList(List<GameModel> games) {
    if (games.isEmpty) {
      return const Center(
        child: Text('No games'),
      );
    }
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) => Container(
        color: index % 2 == 0 ? Colors.transparent : Colors.transparent,
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.gameDetailsPage,
              arguments: {'gameId': games[index].id},
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.sidePadding0_5x),
            child: _gameItem(
              games[index],
            ),
          ),
        ),
      ),
      itemCount: games.length,
    );
  }

  Widget _gameItem(GameModel game) {
    final GlobalKey menuKey = GlobalKey();
    return Row(
      children: [
        const SizedBox(
          width: Dimensions.defaultSidePadding,
        ),
        Container(
          color: Colors.white.withOpacity(0.1),
          child: Text(DateFormat('dd-MM-yyyy').format(game.startedAt)),
        ),
        const SizedBox(
          width: Dimensions.defaultSidePadding,
        ),
        const Divider(
          color: Colors.white,
        ),
        const SizedBox(
          width: Dimensions.defaultSidePadding,
        ),
        Text(formatDuration(game.duration)),
        const SizedBox(
          width: Dimensions.defaultSidePadding,
        ),
        const Divider(
          color: Colors.white,
        ),
        _gameWinnerViewMapper(game.winnerType, game.mafsLeft),
        const Spacer(),
        IconButton(
          key: menuKey,
          onPressed: () async => _showMoreMenu(menuKey, game),
          icon: const Icon(Icons.more_vert),
        ),
        const SizedBox(
          width: Dimensions.defaultSidePadding,
        ),
      ],
    );
  }

  Widget _gameWinnerViewMapper(WinnerType winnerType, int mafsLeft) {
    if (winnerType == WinnerType.civilian) {
      return Container(
        color: Colors.redAccent.withOpacity(0.1),
        child: Text(winnerType.name),
      );
    } else if (winnerType == WinnerType.mafia) {
      return Row(
        children: [
          Container(
            color: Colors.black,
            child: Text(winnerType.name),
          ),
          const SizedBox(width: Dimensions.defaultSidePadding),
          Text('($mafsLeft in $mafsLeft)')
        ],
      );
    } else {
      return Container(
        color: Colors.white.withOpacity(0.1),
        child: const Text('draw'),
      );
    }
  }

  String formatDuration(Duration duration) {
    String hours = duration.inHours.toString().padLeft(2, '0');
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  Future<void> _showMoreMenu(GlobalKey menuKey, GameModel game) async {
    final RenderBox button =
        menuKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final String? selectedValue = await showMenu<String>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem<String>(
          value: _deleteGameOption,
          child: Text('Delete'),
        ),
      ],
    );

    if (selectedValue == _deleteGameOption) {
      clubDetailsBloc.add(DeleteGameEvent(game.id));
    }
  }
}
