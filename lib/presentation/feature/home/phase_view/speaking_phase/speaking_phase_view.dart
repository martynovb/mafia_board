import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/presentation/feature/game_timer_view.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/speaking_phase/speaking_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_list/vote_phase_list_view.dart';

class SpeakingPhaseView extends StatefulWidget {
  final void Function() onSpeechFinished;

  const SpeakingPhaseView({
    Key? key,
    required this.onSpeechFinished,
  }) : super(key: key);

  @override
  State<SpeakingPhaseView> createState() => _SpeakingPhaseViewState();
}

class _SpeakingPhaseViewState extends State<SpeakingPhaseView> {
  late SpeakingPhaseBloc speakingPhaseBloc;
  final timerKey = GlobalKey<GameTimerViewState>();
  bool _isTimerFinished = false;

  @override
  void initState() {
    speakingPhaseBloc = GetIt.instance<SpeakingPhaseBloc>();
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
              Text(
                'Speaking player: ${state.speakPhaseAction?.player?.nickname}',
              ),
              if (_isTimerFinished)
                _goNextPlayer()
              else if (state.speakPhaseAction != null &&
                  state.speakPhaseAction?.status == PhaseStatus.inProgress)
                _finishSpeechBtn(state.speakPhaseAction?.timeForSpeakInSec)
              else
                _startSpeechBtn(),
              //Spacer(),
              VotePhaseListView(),
            ],
          );
        });
  }

  Widget _goNextPlayer() {
    return Column(
      children: [
        Text('Time for current player is finished'),
        ElevatedButton(
            onPressed: () {
              speakingPhaseBloc.add(FinishSpeechEvent());
              _isTimerFinished = false;
            },
            child: Text('Next player')),
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
      [Duration? countdownDuration = const Duration(seconds: 60)]) {
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
