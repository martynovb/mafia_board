import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/presentation/feature/game_timer_view.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_event.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_state.dart';

class NightPhaseView extends StatefulWidget {
  final void Function() onNightPhaseFinished;

  const NightPhaseView({
    Key? key,
    required this.onNightPhaseFinished,
  }) : super(key: key);

  @override
  State<NightPhaseView> createState() => _NightPhaseViewState();
}

class _NightPhaseViewState extends State<NightPhaseView> {
  late NightPhaseBloc nightPhaseBloc;
  final timerKey = GlobalKey<GameTimerViewState>();
  bool _isTimerFinished = false;
  final double _boxNumberSize = 30;

  @override
  void initState() {
    nightPhaseBloc = GetIt.instance<NightPhaseBloc>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    nightPhaseBloc.add(GetCurrentNightPhaseEvent());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
        listener: (context, NightPhaseState state) {
          if (state.isFinished) {
            widget.onNightPhaseFinished();
          }
        },
        bloc: nightPhaseBloc,
        builder: (context, NightPhaseState state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${state.nightPhaseAction?.role.name} is waking up',
              ),
              if (_isTimerFinished)
                _goNextPlayer()
              else if (state.nightPhaseAction != null &&
                  state.nightPhaseAction?.status == PhaseStatus.inProgress)
                _finishSpeechBtn(state.nightPhaseAction?.timeForNight)
              else
                _startSpeechBtn(),
              _playersList(state)
            ],
          );
        });
  }

  Widget _goNextPlayer() {
    return Column(
      children: [
        Text('Time for current role is finished'),
        ElevatedButton(
            onPressed: () {
              nightPhaseBloc.add(FinishCurrentNightPhaseEvent());
              _isTimerFinished = false;
            },
            child: Text('Next role')),
      ],
    );
  }

  Widget _startSpeechBtn() {
    return IconButton(
      onPressed: () {
        nightPhaseBloc.add(StartCurrentNightPhaseEvent());
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
            nightPhaseBloc.add(FinishCurrentNightPhaseEvent());
          },
          icon: const Icon(Icons.stop),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _playersList(NightPhaseState state) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: state.allPlayers.map((player) {
        return SizedBox(
          height: _boxNumberSize,
          width: _boxNumberSize + 10,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(3),
                backgroundColor: player.isKilled
                    ? Colors.red
                    : null
            ),
            icon: _iconMapper(state.nightPhaseAction?.role),
            label: Text('${state.allPlayers.indexOf(player) + 1}', style: TextStyle(fontSize: 10),),
            onPressed: () {
              if (state.nightPhaseAction?.role == Role.MAFIA) {
                nightPhaseBloc.add(KillEvent(
                  role: Role.MAFIA,
                  killedPlayer: player,
                ));
              } else if (state.nightPhaseAction?.role == Role.DON ||
                  state.nightPhaseAction?.role == Role.SHERIFF) {
                nightPhaseBloc.add(CheckEvent(
                  role: state.nightPhaseAction?.role ?? Role.NONE,
                  playerToCheck: player,
                ));
              } else if (state.nightPhaseAction?.role == Role.DOCTOR ||
                  state.nightPhaseAction?.role == Role.PUTANA) {
                nightPhaseBloc.add(VisitEvent(
                  role: state.nightPhaseAction?.role ?? Role.NONE,
                  playerToVisit: player,
                ));
              } else {
                // Impossible
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Icon _iconMapper(Role? role) {
    if (role == Role.MAFIA) {
      return const Icon(
        Icons.fiber_manual_record,
        size: 10,
      );
    } else if (role == Role.DON || role == Role.SHERIFF) {
      return const Icon(
        Icons.search,
        size: 10,
      );
    } else if (role == Role.DOCTOR || role == Role.PUTANA) {
      return const Icon(
        Icons.directions_walk,
        size: 10,
      );
    } else {
      return const Icon(
        Icons.question_mark,
        size: 10,
      );
    }
  }
}
