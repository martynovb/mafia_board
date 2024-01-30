import 'package:mafia_board/domain/model/game_phase/night_phase_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';

class NightPhaseState {
  final NightPhaseModel? nightPhaseAction;
  final List<PlayerModel> allPlayers;
  final bool isFinished;

  NightPhaseState({
    this.nightPhaseAction,
    this.allPlayers = const [],
    this.isFinished = false,
  });
}

class CheckResultState extends NightPhaseState {
  final PlayerModel? playerModel;

  CheckResultState({
    required NightPhaseModel? nightPhaseAction,
    required this.playerModel,
    List<PlayerModel>? allPlayers,
    bool? isFinished,
  }) : super(
          nightPhaseAction: nightPhaseAction,
          isFinished: isFinished ?? false,
          allPlayers: allPlayers ?? [],
        );
}
