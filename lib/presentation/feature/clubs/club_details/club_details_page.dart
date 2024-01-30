import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_event.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_state.dart';
import 'package:mafia_board/presentation/feature/router.dart';

class ClubDetailsPage extends StatefulWidget {
  const ClubDetailsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ClubDetailsPage> createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage> {
  late ClubsDetailsBloc clubDetailsBloc;
  ClubModel? club;

  @override
  void initState() {
    clubDetailsBloc = GetIt.instance<ClubsDetailsBloc>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    club = args?['club'];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (club == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('No club info'),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Text(club!.title),
                    Text(club!.description),
                  ],
                ),
                Spacer(),
                Column(
                  children: [
                    Text('Civil WIN rate:'),
                    Text(club!.description),
                  ],
                ),
              ],
            )
          ],
        ),
      );
    }
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
        if (club.isAdmin) ...[
          GestureDetector(
            onTap: () {},
            child: Text('Pending requests (...)'),
          ),
          const Divider(),
        ],
        GestureDetector(
          onTap: () {},
          child: Text('Games (${club.games.length})'),
        ),
        const Divider(),
        if (club.isAdmin)
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.gamePage,
                arguments: {'clubId': club.id},
              );
            },
            child: const Text('Start new game'),
          ),
      ],
    );
  }
}
