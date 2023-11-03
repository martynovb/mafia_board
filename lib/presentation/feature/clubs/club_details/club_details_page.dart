import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/club_model.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_event.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_state.dart';
import 'package:mafia_board/presentation/feature/router.dart';

class ClubDetailsPage extends StatefulWidget {

  const ClubDetailsPage({Key? key,}) : super(key: key);

  @override
  State<ClubDetailsPage> createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage> {
  late ClubsDetailsBloc clubDetailsBloc;
  late String clubId;

  @override
  void initState() {
    clubDetailsBloc = GetIt.instance<ClubsDetailsBloc>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    clubId = args?['clubId'] ?? '';
    clubDetailsBloc.add(GetClubDetailsEvent(clubId));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder(
        bloc: clubDetailsBloc,
        builder: (BuildContext context, ClubDetailsState state) {
          if (state is DetailsState) {
            return _clubDetails(state.club);
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _clubDetails(ClubModel club) {
    return ListView(
      children: [
        Text(club.title),
        const Divider(),
        Text(club.description),
        const Divider(),
        GestureDetector(
          onTap: () {},
          child: Text('Members (${club.members.length})'),
        ),
        const Divider(),
        if (club.amIAdmin) ...[
          GestureDetector(
            onTap: () {},
            child: Text('Pending requests (${club.waitList.length})'),
          ),
          const Divider(),
        ],
        GestureDetector(
          onTap: () {},
          child: Text('Games (${club.games.length})'),
        ),
        const Divider(),
        if (club.amIAdmin)
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.gamePage,
              );
            },
            child: Text('Start new game'),
          ),
      ],
    );
  }
}
