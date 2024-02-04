import 'package:mafia_board/domain/model/club_model.dart';

abstract class ClubsDetailsEvent {}

class GetClubDetailsEvent extends ClubsDetailsEvent {
  final ClubModel? club;

  GetClubDetailsEvent(this.club);
}

class GetAllClubMembersEvent extends ClubsDetailsEvent {}

class DeleteGameEvent extends ClubsDetailsEvent {
  final String gameId;

  DeleteGameEvent(this.gameId);
}

class ApproveJoinRequestEvent extends ClubsDetailsEvent {
  final String userId;

  ApproveJoinRequestEvent(this.userId);
}
