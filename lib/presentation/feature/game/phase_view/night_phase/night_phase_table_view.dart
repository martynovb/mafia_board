import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/constants/constants.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/presentation/feature/game/table/table_widget.dart';
import 'package:mafia_board/presentation/feature/game_timer_view.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/night_phase/night_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/night_phase/night_phase_event.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/night_phase/night_phase_state.dart';

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
              if (state.nightPhaseAction?.role == Role.sheriff ||
                  state.nightPhaseAction?.role == Role.don) {
                nightPhaseBloc.add(CheckEvent(
                  role: state.nightPhaseAction?.role ?? Role.none,
                  playerToCheck: player,
                ));
              } else if (state.nightPhaseAction?.role == Role.mafia) {
                nightPhaseBloc.add(KillEvent(
                  role: Role.mafia,
                  killedPlayer: player,
                ));
              }
            },
            onPlayerLongPress: (player) {
              if (state.nightPhaseAction?.role == Role.sheriff ||
                  state.nightPhaseAction?.role == Role.don) {
                nightPhaseBloc.add(CancelCheckEvent(
                  role: state.nightPhaseAction?.role ?? Role.none,
                  playerToCheck: player,
                ));
              } else if (state.nightPhaseAction?.role == Role.mafia) {
                nightPhaseBloc.add(CancelKillEvent(
                  role: Role.mafia,
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
    if (state.nightPhaseAction?.role == Role.mafia) {
      return state.allPlayers
          .where((player) => player.isKilled)
          .map((player) => HighlightedPlayerData(
              phaseType: PhaseType.night, player: player, selectedToKill: true))
          .toList();
    } else if (state.nightPhaseAction?.role == Role.don ||
        state.nightPhaseAction?.role == Role.sheriff &&
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
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
      child: const Text('Next'),
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
}
