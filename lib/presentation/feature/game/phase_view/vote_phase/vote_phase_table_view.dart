import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_phase_bloc/vote_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_phase_bloc/vote_phase_event.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_phase_bloc/vote_phase_state.dart';
import 'package:mafia_board/presentation/feature/game/table/table_widget.dart';

class VotePhaseTableView extends StatefulWidget {
  final void Function() onVoteFinished;

  const VotePhaseTableView({
    Key? key,
    required this.onVoteFinished,
  }) : super(key: key);

  @override
  State<VotePhaseTableView> createState() => _VotePhaseTableViewState();
}

class _VotePhaseTableViewState extends State<VotePhaseTableView> {
  late VotePhaseBloc votePhaseBloc;

  @override
  void initState() {
    votePhaseBloc = GetIt.instance<VotePhaseBloc>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    votePhaseBloc.add(GetVotingDataEvent());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
        listener: (BuildContext context, VotePhaseState state) {
          if (state.status == PhaseStatus.finished) {
            widget.onVoteFinished();
          }
        },
        bloc: votePhaseBloc,
        builder: (BuildContext context, VotePhaseState state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TableWidget(
                highlightedPlayerList: state.allAvailablePlayersToVote.entries
                    .map(
                      (entry) => HighlightedPlayerData(
                        phaseType: PhaseType.vote,
                        player: entry.key,
                        isVoted: entry.value,
                        onVote: state.playerOnVote?.tempId == entry.key.tempId,
                      ),
                    )
                    .toList(),
                center: _center(state),
                onPlayerLongPress: (player) {
                  votePhaseBloc.add(CancelVoteAgainstEvent(
                    currentPlayer: player,
                    voteAgainstPlayer: state.playerOnVote!,
                  ));
                },
                onPlayerClicked: (player) {
                  votePhaseBloc.add(VoteAgainstEvent(
                    currentPlayer: player,
                    voteAgainstPlayer: state.playerOnVote!,
                  ));
                },
                players: state.players,
                judgeSide: Container(),
              ),
            ],
          );
        });
  }

  Widget _center(VotePhaseState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(state.title),
        if (state.playersToKickText.isNotEmpty) Text(state.playersToKickText),
        ElevatedButton(
          onPressed: () {
            votePhaseBloc.add(
              FinishVoteAgainstEvent(
                playerOnVoting: state.playerOnVote,
              ),
            );
          },
          child: const Text('Next'),
        ),
      ],
    );
  }
}
