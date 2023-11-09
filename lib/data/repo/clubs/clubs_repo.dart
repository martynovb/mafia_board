import 'package:mafia_board/domain/model/club_model.dart';

abstract class ClubsRepo {
  Future<List<ClubModel>> getClubs({String? id, int limit = 10});

  Future<ClubModel?> getClubDetails({required String id});

  Future<bool> sendRequestToJoinClub({
    required String clubId,
    required String currentUserId,
  });

  Future<bool> acceptUserToJoinClub({
    required String clubId,
    required String currentUserId,
    required String participantUserId,
  });

  Future<bool> rejectUserToJoinClub({
    required String clubId,
    required String currentUserId,
    required String participantUserId,
  });

  Future<bool> setUserAsAdminOfClub({
    required String clubId,
    required String currentUserId,
    required String participantUserId,
  });
}
