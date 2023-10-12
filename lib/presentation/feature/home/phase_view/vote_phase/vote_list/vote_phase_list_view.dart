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
    return SizedBox(
        height: 24,
        child: Row(
          children: [
            const Icon(Icons.thumb_up),
            Text(': '),
            Expanded(
                child: StreamBuilder(
                    stream: _votePhaseListBloc.voteListStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data?.isNotEmpty == true) {
                        return _voteList(snapshot.data ?? []);
                      } else {
                        return Container();
                      }
                    }))
          ],
        ));
  }

  Widget _voteList(List<VoteItem> voteList) {
    return Center(
        child: ListView.separated(
            separatorBuilder: (context, index) => const Text(', '),
            scrollDirection: Axis.horizontal,
            itemCount: voteList.length,
            itemBuilder: (context, index) {
              return Text('${voteList[index].playerNumber}');
            }));
  }
}
