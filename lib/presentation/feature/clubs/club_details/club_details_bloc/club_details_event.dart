import 'package:mafia_board/domain/model/club_model.dart';

abstract class ClubsDetailsEvent {}

class GetClubDetailsEvent extends ClubsDetailsEvent {
  final ClubModel club;

  GetClubDetailsEvent(this.club);
}

class GetAllClubMembersEvent extends ClubsDetailsEvent {}

class ApproveJoinRequestEvent extends ClubsDetailsEvent {
  final String userId;

  ApproveJoinRequestEvent(this.userId);
}
