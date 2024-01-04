import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_event.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_state.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:url_launcher/url_launcher.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({Key? key}) : super(key: key);

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  late ClubsListBloc clubsListBloc;

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
              if (state is AllClubsState) {
                return _clubsList(state.clubs);
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }));
  }

  Widget _clubsList(List<ClubModel> clubs) => ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return _clubItem(index, clubs[index]);
        },
        itemCount: clubs.length,
      );

  Widget _clubItem(int index, ClubModel club) {
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
        IconButton(
          onPressed: () async {
            await launchUrl(Uri.parse(club.googleSheetLink));
          },
          icon: const Icon(Icons.open_in_new),
        ),
        const SizedBox(
          width: Dimensions.defaultSidePadding,
        ),
        IconButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: club.googleSheetLink));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied')),
            );
          },
          icon: const Icon(Icons.copy),
        ),
        const SizedBox(
          width: Dimensions.defaultSidePadding,
        ),
      ],
    );
  }
}
