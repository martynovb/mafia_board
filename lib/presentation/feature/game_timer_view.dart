import 'dart:async';

import 'package:flutter/material.dart';

class GameTimerView extends StatefulWidget {
  final Duration? countdownDuration;
  final VoidCallback? onCountdownEnd;

  const GameTimerView({
  Key? key,
  this.countdownDuration,
  this.onCountdownEnd,
  }) : super(key: key);

  @override
  GameTimerViewState createState() => GameTimerViewState();
}

class GameTimerViewState extends State<GameTimerView> {
  late StreamController<int> _timerStreamController;
  late Timer _timer;
  late int _secondsPassed;
  bool isPaused = false;  // flag to know if timer is paused

  @override
  void initState() {
    super.initState();
    _secondsPassed = widget.countdownDuration?.inSeconds ?? 0;
    _timerStreamController = StreamController<int>();

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPaused) return;  // Skip tick when paused

      if (widget.countdownDuration != null) {
        // Countdown logic
        if (_secondsPassed <= 0) {
          timer.cancel();
          if (widget.onCountdownEnd != null) {
            widget.onCountdownEnd!();
          }
        } else {
          _secondsPassed--;
        }
      } else {
        // Count up logic
        _secondsPassed++;
      }
      _timerStreamController.add(_secondsPassed);
    });
  }

  void pauseTimer() {
    setState(() {
      isPaused = true;
    });
  }

  void resumeTimer() {
    setState(() {
      isPaused = false;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _timerStreamController.stream,
      initialData: _secondsPassed,
      builder: (context, snapshot) {
        final hours = (snapshot.data! ~/ 3600).toString().padLeft(2, '0');
        final minutes =
            ((snapshot.data! % 3600) ~/ 60).toString().padLeft(2, '0');
        final seconds = (snapshot.data! % 60).toString().padLeft(2, '0');
        return Text('$hours:$minutes:$seconds');
      },
    );
  }
}
