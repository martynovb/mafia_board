class FirestoreKeys {
  static const nicknamesCollectionKey = 'nicknames';
  static const usersCollectionKey = 'users';
  static const clubsCollectionKey = 'clubs';
  static const gamesCollectionKey = 'games';

  static const idFieldKey = 'id';

  /// USER
  static const nicknameFieldKey = 'nick_name';
  static const emailFieldKey = 'email';

  /// CLUB
  static const clubTitleFieldKey = 'club_title';
  static const clubDescriptionFieldKey = 'club_description';
  static const clubGoogleSheetIdFieldKey = 'club_google_sheet_id';
  static const clubMembersIdsFieldKey = 'club_members_ids';
  static const clubAdminsIdsFieldKey = 'club_admins_ids';

  /// GAME
  static const gameClubIdFieldKey = 'club_id';
  static const gamePlayersIdsFieldKey = 'score_ids';
  static const gameFinishTypeFieldKey = 'finish_type';

  /// PLAYER
  static const playerClubIdFieldKey = 'club_id';

  /// CLUB_MEMBER
  static const clubMemberUserIdFieldKey = 'club_member_user_id';
}