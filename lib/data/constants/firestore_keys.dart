class FirestoreKeys {
  static const nicknamesCollectionKey = 'nicknames';
  static const usersCollectionKey = 'users';
  static const clubsCollectionKey = 'clubs';
  static const gamesCollectionKey = 'games';
  static const clubMembersCollectionKey = 'club_members';
  static const playersCollectionKey = 'players';
  static const dayInfoCollectionKey = 'day_info';
  static const gamePhaseCollectionKey = 'game_phase';
  static const rulesCollectionKey = 'rules';

  static const idFieldKey = 'id';
  static const tempIdFieldKey = 'temp_id';
  static const gameIdFieldKey = 'game_id';
  static const clubIdFieldKey = 'club_id';
  static const dayInfoIdFieldKey = 'day_info_id';
  static const createdAtFieldKey = 'createdAt';
  static const updatedAtFieldKey = 'updatedAt';


  /// USER
  static const nicknameFieldKey = 'nick_name';
  static const emailFieldKey = 'email';

  /// CLUB
  static const clubTitleFieldKey = 'club_title';
  static const clubDescriptionFieldKey = 'club_description';

  /// GAME
  static const gameFinishTypeFieldKey = 'finish_type';
  static const gameWinRoleFieldKey = 'win_role';
  static const gameMafsLeftFieldKey = 'mafs_left';
  static const startedInMillsFieldKey = 'started_in_mills';
  static const finishedInMillsFieldKey = 'finished_in_mills';

  /// PLAYER
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
  static const clubMembersIsAdminFieldKey = 'is_admin';

  /// DAY INFO
  static const dayInfoDayFieldKey = 'day';
  static const removedPlayersTempIdsFieldKey = 'removed_players_temp_ids';
  static const mutedPlayersTempIdsFieldKey = 'muted_players_temp_ids';
  static const playersWithFoulTempIdsFieldKey = 'players_with_foul_temp_ids';

  /// GAME PHASE
  static const gamePhaseDayFieldKey = 'day';
  static const gamePhaseTypeFieldKey = 'phase_type';

  static const nightPhaseRoleFieldKey = 'role';
  static const nightPhasePlayersForWakeUpTempIdsFieldKey = 'players_for_wake_up_temp_ids';
  static const nightPhaseKilledPlayerTempIdFieldKey = 'killed_player_temp_id';
  static const nightPhaseCheckedPlayerTempIdFieldKey = 'checked_player_temp_id';

  static const speakPhasePlayerTempIdFieldKey = 'player_temp_id';
  static const speakPhaseIsLastWordFieldKey = 'is_last_word';
  static const speakPhaseIsGunfightFieldKey = 'is_gunfight';
  static const speakPhaseIsBestMoveFieldKey = 'is_best_move';
  static const speakPhaseBestMoveTempIdsFieldKey = 'best_move_temp_ids';

  static const votePhasePlayerOnVoteTempIdFieldKey = 'player_on_vote_temp_id';
  static const votePhaseWhoPutOnVoteTempIdFieldKey = 'who_put_on_vote_temp_id';
  static const votePhasePlayersToKickTempIdsFieldKey = 'players_to_kick_temp_ids';
  static const votePhaseVotedPlayersTempIdsFieldKey = 'voted_players_temp_ids';
  static const votePhaseIsGunfightFieldKey = 'is_gunfight';
  static const votePhaseShouldKickAllFieldKey = 'should_kick_all';

  /// RULES

  static const civilWin = 'civilWin';
  static const civilLoss = 'civilLoss';
  static const mafWin = 'mafWin';
  static const mafLoss = 'mafLoss';
  static const disqualificationLoss = 'disqualificationLoss';
  static const defaultBonus = 'defaultBonus';
  static const ppkLoss = 'ppkLoss';
  static const defGameLoss = 'defGameLoss';

  static const bestMoveKey = 'bestMove';
  static const bestMoveWin0 = 'bestMoveWin0';
  static const bestMoveWin1 = 'bestMoveWin1';
  static const bestMoveWin2 = 'bestMoveWin2';
  static const bestMoveWin3 = 'bestMoveWin3';
  static const bestMoveLoss0 = 'bestMoveLoss0';
  static const bestMoveLoss1 = 'bestMoveLoss1';
  static const bestMoveLoss2 = 'bestMoveLoss2';
  static const bestMoveLoss3 = 'bestMoveLoss3';

}