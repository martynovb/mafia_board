import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/game_results_model.dart';

abstract class GameResultsState {
  final ClubModel? club;

  GameResultsState({this.club});
}

class InitialGameResultsState extends GameResultsState {
  InitialGameResultsState({super.club});
}

class ShowGameResultsState extends GameResultsState {
  final GameResultsModel gameResultsModel;

  ShowGameResultsState({super.club, required this.gameResultsModel});
}

class GameResultsUploaded extends GameResultsState {
  GameResultsUploaded({super.club});
}

class GameResultsErrorState extends GameResultsState {
  final String? errorMessage;

  GameResultsErrorState({this.errorMessage, super.club});
}
