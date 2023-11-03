import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/constants.dart';
import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/data/model/phase_type.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_event.dart';
import 'package:mafia_board/presentation/feature/game/table/table_widget.dart';
import 'package:mafia_board/presentation/feature/game_timer_view.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/speaking_phase/speaking_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_list/vote_phase_list_view.dart';

class SpeakingPhaseTableView extends StatefulWidget {
  final void Function() onSpeechFinished;

  const SpeakingPhaseTableView({
    Key? key,
    required this.onSpeechFinished,
  }) : super(key: key);

  @override
  State<SpeakingPhaseTableView> createState() => _SpeakingPhaseTableViewState();
}

class _SpeakingPhaseTableViewState extends State<SpeakingPhaseTableView> {
  late SpeakingPhaseBloc speakingPhaseBloc;
  late GameBloc boardBloc;
  final timerKey = GlobalKey<GameTimerViewState>();
  bool _isTimerFinished = false;

  @override
  void initState() {
    speakingPhaseBloc = GetIt.I();
    boardBloc = GetIt.I();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    speakingPhaseBloc.add(GetCurrentSpeakPhaseEvent());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
        listener: (context, SpeakingPhaseState state) {
          if (state.isFinished) {
            widget.onSpeechFinished();
          }
        },
        bloc: speakingPhaseBloc,
        builder: (context, SpeakingPhaseState state) {
          return Column(
            children: [
              const SizedBox(
                height: Dimensions.sidePadding0_5x,
              ),
              if (state.speaker?.isMuted == true) const Text('MUTED'),
              TableWidget(
                players: state.players,
                center: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Player #${state.speaker?.seatNumber} is speaking',
                    ),
                    const SizedBox(
                      height: Dimensions.sidePadding0_5x,
                    ),
                    Text(
                      '${state.speaker?.nickname}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                judgeSide: _center(state),
                highlightedPlayerList: [
                  if (state.speaker != null &&
                      state.speakPhaseAction != null) ...[
                    HighlightedPlayerData(
                        phaseType: PhaseType.speak,
                        player: state.speaker!,
                        isSpeaking: state.speakPhaseAction?.status ==
                            PhaseStatus.inProgress,
                        isReadyToSpeak: state.speakPhaseAction?.status ==
                            PhaseStatus.notStarted),
                  ]
                ],
                onPlayerClicked: (player) {
                  boardBloc.add(PutOnVoteEvent(playerOnVote: player));
                },
              ),
              const VotePhaseListView(),
            ],
          );
        });
  }

  Widget _center(SpeakingPhaseState state) {
    if (_isTimerFinished) {
      return _goNextPlayer();
    } else if (state.speakPhaseAction != null &&
        state.speakPhaseAction?.status == PhaseStatus.inProgress) {
      return _finishSpeechBtn(state.speakPhaseAction?.timeForSpeakInSec);
    } else {
      return _startSpeechBtn();
    }
  }

  Widget _goNextPlayer() {
    return Column(
      children: [
        const Text('Time for current player is finished'),
        ElevatedButton(
            onPressed: () {
              speakingPhaseBloc.add(FinishSpeechEvent());
              _isTimerFinished = false;
            },
            child: const Text('Next player')),
      ],
    );
  }

  Widget _startSpeechBtn() {
    return IconButton(
      onPressed: () {
        speakingPhaseBloc.add(StartSpeechEvent());
      },
      icon: const Icon(Icons.play_arrow),
    );
  }

  Widget _finishSpeechBtn(
      [Duration? countdownDuration = Constants.defaultTimeForSpeak]) {
    return Row(
      children: [
        const Spacer(),
        timerKey.currentState?.isPaused ?? false
            ? IconButton(
                onPressed: () {
                  timerKey.currentState?.resumeTimer();
                  setState(() {});
                },
                icon: const Icon(Icons.play_arrow),
              )
            : IconButton(
                onPressed: () {
                  timerKey.currentState?.pauseTimer();
                  setState(() {});
                },
                icon: const Icon(Icons.pause),
              ),
        GameTimerView(
          key: timerKey,
          countdownDuration: countdownDuration,
          onCountdownEnd: () {
            _isTimerFinished = true;
            setState(() {});
          },
        ),
        IconButton(
          onPressed: () {
            speakingPhaseBloc.add(FinishSpeechEvent());
          },
          icon: const Icon(Icons.stop),
        ),
        const Spacer(),
      ],
    );
  }
}
