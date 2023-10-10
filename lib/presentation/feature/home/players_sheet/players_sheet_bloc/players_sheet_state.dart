import 'package:mafia_board/data/model/game_phase_model.dart';
import 'package:mafia_board/data/model/player_model.dart';

abstract class SheetState {}

class InitialSheetState extends SheetState {}

class SheetDataState extends SheetState {
  final List<PlayerModel> players;
  final GamePhaseModel? gamePhaseModel;

  SheetDataState({required this.players, this.gamePhaseModel});
}
