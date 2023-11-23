abstract class ClubState {

}

class InitialClubState extends ClubState {}

class ErrorClubState extends ClubState {
  final String error;

  ErrorClubState(this.error);

}