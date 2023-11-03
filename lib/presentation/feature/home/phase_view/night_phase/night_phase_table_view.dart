import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/data/model/phase_type.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/presentation/feature/game_timer_view.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_event.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_state.dart';
import 'package:mafia_board/presentation/feature/table/table_widget.dart';

class NightPhaseTableView extends StatefulWidget {
  final void Function() onNightPhaseFinished;

  const NightPhaseTableView({
    Key? key,
    required this.onNightPhaseFinished,
  }) : super(key: key);

  @override
  State<NightPhaseTableView> createState() => _NightPhaseTableViewState();
}

class _NightPhaseTableViewState extends State<NightPhaseTableView> {
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
          return TableWidget(
            players: state.allPlayers,
            center: Text('${state.nightPhaseAction?.role.name} is waking up'),
            judgeSide: _nightJudgeViewMapper(state),
            highlightedPlayerList: _highlightedPlayerDataMapper(state),
            onPlayerClicked: (player) {
              if (state.nightPhaseAction?.role == Role.SHERIFF ||
                  state.nightPhaseAction?.role == Role.DON) {
                nightPhaseBloc.add(CheckEvent(
                  role: state.nightPhaseAction?.role ?? Role.NONE,
                  playerToCheck: player,
                ));
              } else if (state.nightPhaseAction?.role == Role.MAFIA) {
                nightPhaseBloc.add(KillEvent(
                  role: Role.MAFIA,
                  killedPlayer: player,
                ));
              }
            },
            onPlayerLongPress: (player) {
              if (state.nightPhaseAction?.role == Role.SHERIFF ||
                  state.nightPhaseAction?.role == Role.DON) {
                nightPhaseBloc.add(CancelCheckEvent(
                  role: state.nightPhaseAction?.role ?? Role.NONE,
                  playerToCheck: player,
                ));
              } else if (state.nightPhaseAction?.role == Role.MAFIA) {
                nightPhaseBloc.add(CancelKillEvent(
                  role: Role.MAFIA,
                  killedPlayer: player,
                ));
              }
            },
          );
        });
  }

  List<HighlightedPlayerData> _highlightedPlayerDataMapper(
    NightPhaseState state,
  ) {
    if (state.nightPhaseAction?.role == Role.MAFIA) {
      return state.allPlayers
          .where((player) => player.isKilled)
          .map((player) => HighlightedPlayerData(
              phaseType: PhaseType.night, player: player, selectedToKill: true))
          .toList();
    } else if (state.nightPhaseAction?.role == Role.DON ||
        state.nightPhaseAction?.role == Role.SHERIFF &&
            state.nightPhaseAction?.checkedPlayer != null) {
      final checkedPlayer = state.nightPhaseAction?.checkedPlayer;
      if (checkedPlayer != null) {
        return [
          HighlightedPlayerData(
            phaseType: PhaseType.night,
            player: checkedPlayer,
            showRole: true,
          )
        ];
      }
    }

    return [];
  }

  Widget _nightJudgeViewMapper(NightPhaseState state) {
    if (state.nightPhaseAction?.role == Role.MAFIA) {
      return _mafiaView(state);
    } else if (state.nightPhaseAction?.role == Role.DON) {
      return _donView(state);
    } else if (state.nightPhaseAction?.role == Role.SHERIFF) {
      return _sheriffView(state);
    } else {
      return Container();
    }
  }

  Widget _mafiaView(NightPhaseState state) {
    return _goNextPhase();
  }

  Widget _donView(NightPhaseState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (_isTimerFinished)
          _goNextPhase()
        else if (state.nightPhaseAction != null &&
            state.nightPhaseAction?.status == PhaseStatus.inProgress)
          _finishBtn(state.nightPhaseAction?.timeForNight)
        else
          _startBtn(),
      ],
    );
  }

  Widget _sheriffView(NightPhaseState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (_isTimerFinished)
          _goNextPhase()
        else if (state.nightPhaseAction != null &&
            state.nightPhaseAction?.status == PhaseStatus.inProgress)
          _finishBtn(state.nightPhaseAction?.timeForNight)
        else
          _startBtn(),
      ],
    );
  }

  Widget _goNextPhase() {
    return ElevatedButton(
      onPressed: () {
        nightPhaseBloc.add(FinishCurrentNightPhaseEvent());
        _isTimerFinished = false;
      },
      child: Text('Next'),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.black)
      ),
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
                role: state.nightPhaseAction?.role ?? Role.NONE,
                playerToCheck: player,
              ));
            },
            onPressed: () {
              nightPhaseBloc.add(CheckEvent(
                role: state.nightPhaseAction?.role ?? Role.NONE,
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
                role: Role.MAFIA,
                killedPlayer: player,
              ));
            },
            onPressed: () {
              nightPhaseBloc.add(KillEvent(
                role: Role.MAFIA,
                killedPlayer: player,
              ));
            },
          ),
        );
      }).toList(),
    );
  }

  IconData _mapIconByRole(Role? role) {
    if (role == Role.DON || role == Role.MAFIA) {
      return Icons.thumb_down;
    } else if (role == Role.CIVILIAN) {
      return Icons.thumb_up;
    } else if (role == Role.SHERIFF) {
      return Icons.local_police_outlined;
    }

    return Icons.question_mark;
  }

  Color? _mapBackgroundColor(
      NightPhaseState nightPhaseState, PlayerModel currentPlayer) {
    final currentNightPhaseRole =
        nightPhaseState.nightPhaseAction?.role ?? Role.NONE;

    if (currentPlayer.isKicked || currentPlayer.isRemoved) {
      return Colors.grey;
    } else if (currentNightPhaseRole == Role.MAFIA && currentPlayer.isKilled) {
      return Colors.red;
    } else if (currentNightPhaseRole == Role.MAFIA && !currentPlayer.isKilled) {
      return Colors.blueAccent;
    } else if ((currentNightPhaseRole == Role.DON ||
            currentNightPhaseRole == Role.SHERIFF) &&
        nightPhaseState.nightPhaseAction?.checkedPlayer?.id ==
            currentPlayer.id) {
      return _mapBackgroundColorByRole(currentPlayer.role);
    }

    return null;
  }

  Color? _mapBackgroundColorByRole(Role role) {
    if (role == Role.DON || role == Role.MAFIA) {
      return Colors.black;
    } else if (role == Role.CIVILIAN) {
      return Colors.red.shade300;
    } else if (role == Role.SHERIFF) {
      return Colors.green.withOpacity(0.3);
    }

    return null;
  }
}
