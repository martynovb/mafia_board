import 'package:mafia_board/data/model/player_model.dart';

abstract class SheetState {}

class ShowSheetState extends SheetState {
  final List<PlayerModel> players;

  ShowSheetState(this.players);
}
