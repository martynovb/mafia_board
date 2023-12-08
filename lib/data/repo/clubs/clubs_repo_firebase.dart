import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mafia_board/data/api/error_handler.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/club_entity.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';

class ClubsRepoFirebase extends ClubsRepo {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  ClubsRepoFirebase({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<List<ClubEntity>> getClubs({String? id, int limit = 10}) async {
    final userId = firebaseAuth.currentUser?.uid;
    var clubs = <ClubEntity>[];

    var querySnapshot = await firestore
        .collection(FirestoreKeys.clubsCollectionKey)
        .where(FirestoreKeys.clubMembersIdsFieldKey, arrayContains: userId)
        .get();

    for (var doc in querySnapshot.docs) {
      var club = ClubEntity(
        id: doc.id,
        title: doc.data()[FirestoreKeys.clubTitleFieldKey],
        googleSheetLink: doc.data()[FirestoreKeys.clubGoogleSheetIdFieldKey],
      );
      clubs.add(club);
    }

    return clubs;
  }

  @override
  Future<ClubEntity> createClubsGoogleTable({
    required String name,
    required String googleSheetLink,
  }) async {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) {
      throw InvalidCredentialsException('User is not authorized');
    }

    if (!(await _isGoogleSheetValid(googleSheetLink))) {
      throw ParseException('Invalid google sheet link');
    }


    final doc =
        await firestore.collection(FirestoreKeys.clubsCollectionKey).add({
      FirestoreKeys.clubTitleFieldKey: name,
      FirestoreKeys.clubGoogleSheetIdFieldKey: googleSheetLink,
      FirestoreKeys.clubMembersIdsFieldKey: [userId],
    });

    return ClubEntity(
      id: doc.id,
      title: name,
      googleSheetLink: googleSheetLink,
    );
  }

  Future<bool> _isGoogleSheetValid(String googleSheetLink) async {
    return true;
  }

  @override
  Future<bool> acceptUserToJoinClub({
    required String clubId,
    required String currentUserId,
    required String participantUserId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ClubEntity> createClub({
    required String name,
    required String description,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ClubEntity?> getClubDetails({required String id}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> rejectUserToJoinClub(
      {required String clubId,
      required String currentUserId,
      required String participantUserId}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> sendRequestToJoinClub(
      {required String clubId, required String currentUserId}) {
    throw UnimplementedError();
  }

  @override
  Future<ClubEntity> setClub({required ClubEntity clubEntity}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> setUserAsAdminOfClub(
      {required String clubId,
      required String currentUserId,
      required String participantUserId}) {
    throw UnimplementedError();
  }

  @override
  Future<ClubEntity> updateClub(
      {required String id, required String name, required String description}) {
    throw UnimplementedError();
  }
}
