import 'package:easy_localization/easy_localization.dart';
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
          if (state.phaseStatus == PhaseStatus.finished) {
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
                        onVote: state.votePhase?.playerOnVote.tempId ==
                            entry.key.tempId,
                      ),
                    )
                    .toList(),
                center: _center(state),
                onPlayerLongPress: (player) {
                  final playerOnVote = state.votePhase?.playerOnVote;
                  if (playerOnVote != null) {
                    votePhaseBloc.add(
                      CancelVoteAgainstEvent(
                        currentPlayer: player,
                        voteAgainstPlayer: playerOnVote,
                      ),
                    );
                  }
                },
                onPlayerClicked: (player) {
                  final playerOnVote = state.votePhase?.playerOnVote;
                  if (playerOnVote != null) {
                    votePhaseBloc.add(
                      VoteAgainstEvent(
                        currentPlayer: player,
                        voteAgainstPlayer: playerOnVote,
                      ),
                    );
                  }
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
        state.votePhase?.shouldKickAllPlayers == true
            ? const Text('voteForKick').tr(
                args: [
                  state.votePhase?.playersToKick
                          .map((e) => e.nickname)
                          .join(', ') ??
                      '',
                ],
              )
            : const Text('voteAgainst').tr(
                args: [
                  state.votePhase?.playerOnVote.seatNumber.toString() ?? '',
                ],
              ),
        ElevatedButton(
          onPressed: () {
            votePhaseBloc.add(
              FinishVoteAgainstEvent(
                playerOnVoting: state.votePhase?.playerOnVote,
              ),
            );
          },
          child: const Text('next').tr(),
        ),
      ],
    );
  }
}
