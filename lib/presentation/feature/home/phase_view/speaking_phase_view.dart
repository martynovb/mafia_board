import 'package:flutter/material.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';

class SpeakingPhaseView extends StatefulWidget {
  final void Function() onNextPressed;
  final SpeakPhaseAction? currentPhase;

  const SpeakingPhaseView({
    Key? key,
    required this.onNextPressed,
    required this.currentPhase,
  }) : super(key: key);

  @override
  State<SpeakingPhaseView> createState() => _SpeakingPhaseViewState();
}

class _SpeakingPhaseViewState extends State<SpeakingPhaseView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Speaking player: ${widget.currentPhase?.player?.nickname}',
        ),
        IconButton(
            onPressed: widget.onNextPressed, icon: const Icon(Icons.play_arrow))
      ],
    );
  }
}
