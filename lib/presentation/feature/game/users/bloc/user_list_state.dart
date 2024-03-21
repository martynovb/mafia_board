import 'package:mafia_board/domain/model/club_member_model.dart';

class UserListState {
  final List<ClubMemberModel> clubMember;

  UserListState({this.clubMember = const []});
}

