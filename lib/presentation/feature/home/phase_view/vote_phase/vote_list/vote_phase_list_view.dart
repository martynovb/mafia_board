import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_list/vote_item.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_list/vote_phase_list_bloc.dart';

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
  void dispose() {
    _votePhaseListBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.thumb_up),
        Text(': '),
        StreamBuilder(
            stream: _votePhaseListBloc.voteListStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data?.isNotEmpty == true) {
                return Container();
              } else {
                return Container();
              }
            })
      ],
    );
  }

  Widget _voteList(List<VoteItem> voteList) {
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: voteList.length,
        itemBuilder: (context, index) {
          return Text('${voteList[index].playerNumber}');
        });
  }
}
