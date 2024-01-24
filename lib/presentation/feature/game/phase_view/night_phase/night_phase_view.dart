import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/constants/constants.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/presentation/feature/game_timer_view.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/night_phase/night_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/night_phase/night_phase_event.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/night_phase/night_phase_state.dart';

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
              Text('${state.nightPhaseAction?.role.name} is waking up'),
              _nightViewMapper(state)
            ],
          );
        });
  }

  Widget _nightViewMapper(NightPhaseState state) {
    if (state.nightPhaseAction?.role == Role.mafia) {
      return _mafiaView(state);
    } else if (state.nightPhaseAction?.role == Role.don) {
      return _donView(state);
    } else if (state.nightPhaseAction?.role == Role.sheriff) {
      return _sheriffView(state);
    } else {
      return Container();
    }
  }

  Widget _mafiaView(NightPhaseState state) {
    return Column(
      children: [
        _goNextPhase(),
        _playersListForMafia(state),
      ],
    );
  }

  Widget _donView(NightPhaseState state) {
    return Column(
      children: [
        if (_isTimerFinished)
          _goNextPhase()
        else if (state.nightPhaseAction != null &&
            state.nightPhaseAction?.status == PhaseStatus.inProgress)
          _finishBtn(state.nightPhaseAction?.timeForNight)
        else
          _startBtn(),
        _playersListForSheriffOrDon(state),
      ],
    );
  }

  Widget _sheriffView(NightPhaseState state) {
    return Column(
      children: [
        if (_isTimerFinished)
          _goNextPhase()
        else if (state.nightPhaseAction != null &&
            state.nightPhaseAction?.status == PhaseStatus.inProgress)
          _finishBtn(state.nightPhaseAction?.timeForNight)
        else
          _startBtn(),
        _playersListForSheriffOrDon(state),
      ],
    );
  }

  Widget _goNextPhase() {
    return Column(
      children: [
        ElevatedButton(
            onPressed: () {
              nightPhaseBloc.add(FinishCurrentNightPhaseEvent());
              _isTimerFinished = false;
            },
            child: Text('Next role')),
      ],
    );
  }

  Widget _startBtn() {
    return IconButton(
      onPressed: () {
        nightPhaseBloc.add(StartCurrentNightPhaseEvent());
      },
      icon: const Icon(Icons.play_arrow),
    );
  }

  Widget _finishBtn(
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
            nightPhaseBloc.add(FinishCurrentNightPhaseEvent());
          },
          icon: const Icon(Icons.stop),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _playersListForSheriffOrDon(NightPhaseState state) {
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
                backgroundColor: _mapBackgroundColor(state, player)),
            icon: state.nightPhaseAction?.checkedPlayer == null ||
                    state.nightPhaseAction?.checkedPlayer?.id != player.id
                ? const Icon(
                    Icons.search,
                    size: 10,
                  )
                : Icon(
                    _mapIconByRole(state.nightPhaseAction?.checkedPlayer?.role),
                    size: 10,
                  ),
            label: Text(
              '${state.allPlayers.indexOf(player) + 1}',
              style: const TextStyle(fontSize: 10),
            ),
            onLongPress: () {
              nightPhaseBloc.add(CancelCheckEvent(
                role: state.nightPhaseAction?.role ?? Role.none,
                playerToCheck: player,
              ));
            },
            onPressed: () {
              nightPhaseBloc.add(CheckEvent(
                role: state.nightPhaseAction?.role ?? Role.none,
                playerToCheck: player,
              ));
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _playersListForMafia(NightPhaseState state) {
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
                backgroundColor: _mapBackgroundColor(state, player)),
            icon: Icon(
              player.isKilled ? Icons.close : Icons.fiber_manual_record,
              size: 10,
            ),
            label: Text(
              '${state.allPlayers.indexOf(player) + 1}',
              style: const TextStyle(fontSize: 10),
            ),
            onLongPress: () {
              nightPhaseBloc.add(CancelKillEvent(
                role: Role.mafia,
                killedPlayer: player,
              ));
            },
            onPressed: () {
              nightPhaseBloc.add(KillEvent(
                role: Role.mafia,
                killedPlayer: player,
              ));
            },
          ),
        );
      }).toList(),
    );
  }

  IconData _mapIconByRole(Role? role) {
    if (role == Role.don || role == Role.mafia) {
      return Icons.thumb_down;
    } else if (role == Role.civilian) {
      return Icons.thumb_up;
    } else if (role == Role.sheriff) {
      return Icons.local_police_outlined;
    }

    return Icons.question_mark;
  }

  Color? _mapBackgroundColor(
      NightPhaseState nightPhaseState, PlayerModel currentPlayer) {
    final currentNightPhaseRole =
        nightPhaseState.nightPhaseAction?.role ?? Role.none;

    if (currentPlayer.isKicked || currentPlayer.isDisqualified) {
      return Colors.grey;
    } else if (currentNightPhaseRole == Role.mafia && currentPlayer.isKilled) {
      return Colors.red;
    } else if (currentNightPhaseRole == Role.mafia && !currentPlayer.isKilled) {
      return Colors.blueAccent;
    } else if ((currentNightPhaseRole == Role.don ||
        currentNightPhaseRole == Role.sheriff) &&
            nightPhaseState.nightPhaseAction?.checkedPlayer?.id ==
                currentPlayer.id) {
      return _mapBackgroundColorByRole(currentPlayer.role);
    }

    return null;
  }

  Color? _mapBackgroundColorByRole(Role role) {
    if (role == Role.don || role == Role.mafia) {
      return Colors.black;
    } else if (role == Role.civilian) {
      return Colors.red.shade300;
    } else if (role == Role.sheriff) {
      return Colors.green.withOpacity(0.3);
    }

    return null;
  }
}
