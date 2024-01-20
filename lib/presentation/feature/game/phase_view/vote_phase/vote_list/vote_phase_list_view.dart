import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_list/vote_item.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_list/vote_phase_list_bloc.dart';

class VotePhaseListView extends StatefulWidget {
  const VotePhaseListView({Key? key}) : super(key: key);

  @override
  State<VotePhaseListView> createState() => _VotePhaseListViewState();
}

class _VotePhaseListViewState extends State<VotePhaseListView> {
  late VotePhaseListBloc _votePhaseListBloc;

  @override
  void initState() {
    _votePhaseListBloc = GetIt.instance<VotePhaseListBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: StreamBuilder(
            stream: _votePhaseListBloc.voteListStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data?.isNotEmpty == true) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.thumb_up,
                      size: 24,
                    ),
                    const SizedBox(width: Dimensions.sidePadding0_5x),
                    Expanded(child: _voteListTable(snapshot.data ?? []))
                  ],
                );
              } else {
                return Container();
              }
            }));
  }

  Widget _voteListTable(List<VoteItem> voteList) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: voteList
            .map(
              (vote) => _buildSquare(vote.playerOnVote),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSquare(PlayerModel playerOnVote) {
    return InkWell(
      onTap: () {
        _votePhaseListBloc.add(UnVotePhaseEvent(playerOnVote));
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Center(
            child: Text(
              playerOnVote.seatNumber.toString(),
        )),
      ),
    );
  }
}
