import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_phase_bloc/vote_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_phase_bloc/vote_phase_event.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_phase_bloc/vote_phase_state.dart';

class VotePhaseView extends StatefulWidget {
  final void Function() onVoteFinished;

  const VotePhaseView({
    Key? key,
    required this.onVoteFinished,
  }) : super(key: key);

  @override
  State<VotePhaseView> createState() => _VotePhaseViewState();
}

class _VotePhaseViewState extends State<VotePhaseView> {
  final double _boxNumberSize = 50;
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
              Text(state.title),
              if (state.playersToKickText.isNotEmpty)
                Text(state.playersToKickText),
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
              const SizedBox(
                height: 16,
              ),
              _playerForVoteList(state),
            ],
          );
        });
  }

  Widget _playerForVoteList(VotePhaseState state) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: state.allAvailablePlayersToVote.entries.map((entry) {
        final player = entry.key;
        bool playerHasAlreadyVoted = entry.value;

        return SizedBox(
          height: _boxNumberSize,
          width: _boxNumberSize,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(3),
                backgroundColor: playerHasAlreadyVoted
                    ? Colors.grey
                    : null // Use the default value
                ),
            icon: const Icon(
              Icons.thumb_up,
              size: 16,
            ),
            label: Text('${player.seatNumber}'),
            onLongPress: () {
              if (state.playerOnVote != null) {
                votePhaseBloc.add(CancelVoteAgainstEvent(
                  currentPlayer: player,
                  voteAgainstPlayer: state.playerOnVote!,
                ));
              }
            },
            onPressed: () {
              if (state.playerOnVote != null && !playerHasAlreadyVoted) {
                votePhaseBloc.add(VoteAgainstEvent(
                  currentPlayer: player,
                  voteAgainstPlayer: state.playerOnVote!,
                ));
              }
            },
          ),
        );
      }).toList(),
    );
  }
}
