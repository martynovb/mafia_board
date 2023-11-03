abstract class ClubsDetailsEvent {}

class GetClubDetailsEvent extends ClubsDetailsEvent {
  final String clubId;

  GetClubDetailsEvent(this.clubId);
}

class GetAllClubMembersEvent extends ClubsDetailsEvent {}

class ApproveJoinRequestEvent extends ClubsDetailsEvent {
  final String userId;

  ApproveJoinRequestEvent(this.userId);
}
