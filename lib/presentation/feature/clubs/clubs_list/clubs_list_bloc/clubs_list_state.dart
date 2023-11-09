import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/user_model.dart';

abstract class ClubsListState {}

class InitialClubState extends ClubsListState {}

class AllClubsState extends ClubsListState {
  final List<ClubModel> clubs;

  AllClubsState(this.clubs);
}

class ClubDetailsState extends ClubsListState {
  final ClubModel club;

  ClubDetailsState(this.club);
}

class AllClubMembersState extends ClubsListState {
  final List<UserModel> members;

  AllClubMembersState(this.members);
}
