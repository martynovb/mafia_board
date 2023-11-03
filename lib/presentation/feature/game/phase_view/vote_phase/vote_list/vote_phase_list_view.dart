import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
        height: 24,
        child: StreamBuilder(
            stream: _votePhaseListBloc.voteListStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data?.isNotEmpty == true) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.thumb_up, size: 24,),
                    const Text(': '),
                    Expanded(child: _voteList(snapshot.data ?? []))
                  ],
                );
              } else {
                return Container();
              }
            }));
  }

  Widget _voteList(List<VoteItem> voteList) {
    return  ListView.separated(
      shrinkWrap: true,
            separatorBuilder: (context, index) => const Center(child:Text(', ')),
            scrollDirection: Axis.horizontal,
            itemCount: voteList.length,
            itemBuilder: (context, index) {
              return  Center(child: Text('${voteList[index].playerNumber}'));
            });
  }
}
