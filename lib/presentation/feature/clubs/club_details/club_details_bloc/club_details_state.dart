import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';

abstract class ClubDetailsState {}

class InitialState extends ClubDetailsState {}

class DetailsState extends ClubDetailsState {
  final ClubModel club;
  final List<GameModel> allGames;

  DetailsState({required this.club, required this.allGames});
}

class ErrorClubState extends ClubDetailsState {
  final String error;

  ErrorClubState(this.error);
}
