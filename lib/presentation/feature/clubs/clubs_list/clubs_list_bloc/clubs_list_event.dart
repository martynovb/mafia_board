abstract class ClubsListEvent {}

class GetAllClubsEvent extends ClubsListEvent {}

class GetAllClubMembersEvent extends ClubsListEvent {}

class ApproveJoinRequestEvent extends ClubsListEvent {
  final String userId;

  ApproveJoinRequestEvent(this.userId);
}
