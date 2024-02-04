import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_event.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_state.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/widgets/info_field.dart';
import 'package:url_launcher/url_launcher.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({Key? key}) : super(key: key);

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  late ClubsListBloc clubsListBloc;
  static const String _updateRulesOption = 'update_rules';
  static const String _managePermissionsOption = 'manage_permissions';

  @override
  void initState() {
    clubsListBloc = GetIt.instance<ClubsListBloc>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    clubsListBloc.add(GetAllClubsEvent());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.sidePadding0_5x),
      child: BlocBuilder(
        bloc: clubsListBloc,
        builder: (context, ClubsListState state) {
          if (state.status == StateStatus.data) {
            return _clubsList(state.clubs);
          } else if (state.status == StateStatus.data) {
            return Padding(
              padding: const EdgeInsets.all(Dimensions.defaultSidePadding),
              child: Center(
                child: InfoField(
                  message: state.errorMessage,
                  infoFieldType: InfoFieldType.error,
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },

      ),
    );
  }

  Widget _clubsList(List<ClubModel> clubs) {
    if (clubs.isEmpty) {
      return const Center(
        child: Text('No clubs'),
      );
    }
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.clubDetailsPage,
              arguments: {'club': clubs[index]},
            );
          },
          child: _clubItem(index, clubs[index]),
        );
      },
      itemCount: clubs.length,
    );
  }

  Widget _clubItem(int index, ClubModel club) {
    final GlobalKey menuKey = GlobalKey();
    return Row(
      children: [
        const SizedBox(
          width: Dimensions.defaultSidePadding,
        ),
        Text(
          club.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (club.isAdmin) ...[
          IconButton(
            onPressed: () async {
              Navigator.pushNamed(
                context,
                AppRouter.gamePage,
                arguments: {'club': club},
              );
            },
            icon: const Icon(Icons.play_arrow_sharp),
          ),
          const SizedBox(
            width: Dimensions.defaultSidePadding,
          ),
        ],
        if (club.isAdmin) ...[
          const SizedBox(
            width: Dimensions.defaultSidePadding,
          ),
          IconButton(
            key: menuKey,
            onPressed: () async => _showMoreMenu(menuKey, club),
            icon: const Icon(Icons.more_vert),
          ),
          const SizedBox(
            width: Dimensions.defaultSidePadding,
          ),
        ]
      ],
    );
  }

  Future<void> _showMoreMenu(GlobalKey menuKey, ClubModel club) async {
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
          value: _updateRulesOption,
          child: Text('Update club rules'),
        ),
        const PopupMenuItem<String>(
          value: _managePermissionsOption,
          child: Text('Manage permissions'),
        ),
        const PopupMenuItem<String>(
          value: _managePermissionsOption,
          child: Text('Delete club'),
        ),
      ],
    );

    if (selectedValue == _updateRulesOption) {
      Navigator.pushNamed(
        context,
        AppRouter.gameRulesPage,
        arguments: {'club': club},
      );
    } else if (selectedValue == _managePermissionsOption) {}
  }
}
