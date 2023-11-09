import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_event.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_state.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/router.dart';

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
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
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
                })));
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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.clubDetailsPage,
          arguments: {'clubId': club.id},
        );
      },
      child: Column(
        children: [
          Text(club.title),
          Text(club.description),
        ],
      ),
    );
  }
}
