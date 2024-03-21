import 'package:mafia_board/domain/model/club_model.dart';

abstract class CreateClubState {

}

class InitialClubState extends CreateClubState {}

class ClubCreatedState extends CreateClubState {
  final ClubModel club;

  ClubCreatedState(this.club);
}

class ErrorClubState extends CreateClubState {
  final String error;

  ErrorClubState(this.error);

}