import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/constants/constants.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_event.dart';
import 'package:mafia_board/presentation/feature/game/table/table_widget.dart';
import 'package:mafia_board/presentation/feature/game_timer_view.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/speaking_phase/speaking_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/widgets/input_text_field.dart';

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
  final _bestMove1Controller = TextEditingController();
  final _bestMove2Controller = TextEditingController();
  final _bestMove3Controller = TextEditingController();
  late SpeakingPhaseBloc speakingPhaseBloc;
  late GameBloc gameBloc;
  final timerKey = GlobalKey<GameTimerViewState>();
  bool _isTimerFinished = false;

  @override
  void initState() {
    speakingPhaseBloc = GetIt.I();
    gameBloc = GetIt.I();
    super.initState();
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
              if (state.speaker?.isMuted == true)
                const Text('playerIsMuted').tr(),
              TableWidget(
                players: state.players,
                center: state.speaker == null
                    ? Container()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state.speakPhaseAction?.status ==
                                  PhaseStatus.inProgress ||
                              state.speakPhaseAction?.status ==
                                  PhaseStatus.notStarted)
                            const Text(
                              'playerIsSpeaking',
                            ).tr(
                              args: [
                                state.speaker?.seatNumber.toString() ?? '',
                              ],
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
                  gameBloc.add(PutOnVoteEvent(playerOnVote: player));
                },
              ),
              if (state.speakPhaseAction?.isBestMove == true) _bestMoveForm(),
            ],
          );
        });
  }

  Widget _center(SpeakingPhaseState state) {
    if (_isTimerFinished) {
      return _goNextPlayer(state.speaker?.seatNumber ?? 0);
    } else if (state.speakPhaseAction != null &&
        state.speakPhaseAction?.status == PhaseStatus.inProgress) {
      return _finishSpeechBtn(
        state.speakPhaseAction?.timeForSpeakInSec,
        state.speakPhaseAction?.isBestMove == true,
      );
    } else {
      return _startSpeechBtn();
    }
  }

  Widget _goNextPlayer(int seatNumber) {
    return Column(
      children: [
        const Text('timeForPlayerIsOver').tr(args: [seatNumber.toString()]),
        ElevatedButton(
          onPressed: () {
            speakingPhaseBloc.add(FinishSpeechEvent());
            _isTimerFinished = false;
          },
          child: const Text('nextPlayer').tr(),
        ),
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
      [Duration? countdownDuration = Constants.defaultTimeForSpeak,
      bool isBestMove = false]) {
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
            speakingPhaseBloc.add(FinishSpeechEvent(
              isBestMove
                  ? [
                      _bestMove1Controller.text.trim(),
                      _bestMove2Controller.text.trim(),
                      _bestMove3Controller.text.trim(),
                    ]
                  : [],
            ));
          },
          icon: const Icon(Icons.stop),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _bestMoveForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('bestMove').tr(),
        const SizedBox(
          height: Dimensions.defaultSidePadding,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: Dimensions.inputTextHeight,
              child: InputTextField(
                controller: _bestMove1Controller,
                textInputType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _maxValueFormatter(1, 10),
                ],
              ),
            ),
            const SizedBox(
              width: Dimensions.defaultSidePadding,
            ),
            SizedBox(
              width: Dimensions.inputTextHeight,
              child: InputTextField(
                controller: _bestMove2Controller,
                textInputType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _maxValueFormatter(1, 10),
                ],
              ),
            ),
            const SizedBox(
              width: Dimensions.defaultSidePadding,
            ),
            SizedBox(
              width: Dimensions.inputTextHeight,
              child: InputTextField(
                controller: _bestMove3Controller,
                textInputType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _maxValueFormatter(1, 10),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  TextInputFormatter _maxValueFormatter(int minValue, int maxValue) {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.isEmpty) {
        return newValue;
      } else if (int.tryParse(newValue.text) != null &&
          int.parse(newValue.text) <= maxValue &&
          int.parse(newValue.text) >= minValue) {
        return newValue;
      } else {
        return oldValue;
      }
    });
  }
}
