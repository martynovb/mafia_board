class FirestoreKeys {
  static const nicknamesCollectionKey = 'nicknames';
  static const usersCollectionKey = 'users';
  static const clubsCollectionKey = 'clubs';
  static const gamesCollectionKey = 'games';
  static const clubMembersCollectionKey = 'club_members';
  static const playersCollectionKey = 'players';

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
  static const gameFinishTypeFieldKey = 'finish_type';
  static const gameWinRoleFieldKey = 'win_role';
  static const gameMafsLeftFieldKey = 'mafs_left';
  static const startedInMillsFieldKey = 'started_in_mills';
  static const finishedInMillsFieldKey = 'finished_in_mills';

  /// PLAYER
  static const playerGameIdFieldKey = 'game_id';
  static const playerTempIdFieldKey = 'temp_id';
  static const clubMemberIdFieldKey = 'club_member_id';
  static const foulsFieldKey = 'fouls';
  static const roleFieldKey = 'role';
  static const isRemovedFieldKey = 'is_removed';
  static const isPpkFieldKey = 'is_ppk';
  static const seatNumberFieldKey = 'seat_number';
  static const bestMoveFieldKey = 'best_move';
  static const compensationFieldKey = 'compensation';
  static const gamePointsFieldKey = 'game_points';
  static const bonusPointsFieldKey = 'game_bonus_points';

  /// CLUB_MEMBER
  static const clubMemberUserIdFieldKey = 'user_id';
}