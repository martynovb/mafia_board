abstract class CreateClubState {

}

class InitialClubState extends CreateClubState {}

class ClubCreatedState extends CreateClubState {
  final String clubId;

  ClubCreatedState(this.clubId);
}

class ErrorClubState extends CreateClubState {
  final String error;

  ErrorClubState(this.error);

}