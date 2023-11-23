import 'package:mafia_board/data/entity/club_entity.dart';
import 'package:mafia_board/domain/model/club_model.dart';

abstract class ClubsRepo {
  Future<ClubEntity> createClub({
    required String name,
    required String description,
  });

  Future<ClubEntity> updateClub({
    required String id,
    required String name,
    required String description,
  });

  Future<List<ClubEntity>> getClubs({String? id, int limit = 10});

  Future<ClubEntity?> getClubDetails({required String id});

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
