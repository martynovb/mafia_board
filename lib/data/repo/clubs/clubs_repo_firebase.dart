import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mafia_board/data/api/error_handler.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/club_entity.dart';
import 'package:mafia_board/data/entity/club_member_entity.dart';
import 'package:mafia_board/data/entity/user_entity.dart';
import 'package:mafia_board/data/repo/auth/users/users_repo.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';

class ClubsRepoFirebase extends ClubsRepo {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final UsersRepo usersRepo;

  ClubsRepoFirebase({
    required this.firebaseAuth,
    required this.firestore,
    required this.usersRepo,
  });

  @override
  Future<List<ClubEntity>> getAllClubs() async {
    final userId = firebaseAuth.currentUser?.uid;

    var clubsQuerySnapshot =
        await firestore.collection(FirestoreKeys.clubsCollectionKey).get();

    final clubIds = clubsQuerySnapshot.docs.map((doc) => doc.id).toList();

    if (clubIds.isEmpty) {
      return [];
    }

    // get is admit records where this users is clubMember and is_admin == true
    var isAdminSnapshot = await FirebaseFirestore.instance
        .collection(FirestoreKeys.clubMembersCollectionKey)
        .where(FirestoreKeys.clubIdFieldKey, whereIn: clubIds)
        .where(FirestoreKeys.clubMemberUserIdFieldKey, isEqualTo: userId)
        .where(FirestoreKeys.clubMembersIsAdminFieldKey, isEqualTo: true)
        .get();

    final isAdminMap = isAdminSnapshot.docs.fold<Map<String, bool>>(
      {},
      (acc, doc) => acc
        ..putIfAbsent(
          doc[FirestoreKeys.clubIdFieldKey],
          () => doc.exists,
        ),
    );

    return clubsQuerySnapshot.docs
        .map((clubDoc) => ClubEntity.fromFirestoreMap(
              id: clubDoc.id,
              data: clubDoc.data(),
              isAdmin: isAdminMap[clubDoc.id] ?? false,
            ))
        .toList();
  }

  @override
  Future<ClubEntity> createClub({
    required String name,
    required String clubDescription,
  }) async {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) {
      throw InvalidCredentialsException('User is not authorized');
    }

    final doc =
        await firestore.collection(FirestoreKeys.clubsCollectionKey).add(
      {
        FirestoreKeys.clubTitleFieldKey: name,
        FirestoreKeys.clubDescriptionFieldKey: clubDescription,
      },
    );

    await addNewMembers(clubId: doc.id, newMembers: [
      ClubMemberEntity(
        user: UserEntity(id: userId),
        isAdmin: true,
        clubId: doc.id,
      )
    ]);

    return ClubEntity(
      id: doc.id,
      title: name,
      description: clubDescription,
    );
  }

  // it is needed to display club details with all members
  // add new members when a game for this club is finished
  // or add new member when club creating
  @override
  Future<List<ClubMemberEntity>> addNewMembers({
    required String clubId,
    required List<ClubMemberEntity> newMembers,
  }) async {
    CollectionReference clubMembersRef =
        firestore.collection(FirestoreKeys.clubMembersCollectionKey);

    WriteBatch batch = firestore.batch();
    final createdMembers = [];

    for (ClubMemberEntity member in newMembers) {
      DocumentReference memberDocRef = clubMembersRef.doc();
      batch.set(memberDocRef, member.toFirestoreMap());
      member.id = memberDocRef.id;
      createdMembers.add(member);
    }

    await batch.commit();

    return newMembers;
  }

  // get all users and map to clubMember
  // left clubMember id is null if there is no clubMember with this user
  // create new clubMembers where id is null after a game will be finished
  @override
  Future<List<ClubMemberEntity>> getExistedAndNotExistedClubMembers({
    required String clubId,
  }) async {
    final allUsers = await usersRepo.getAllUsers();

    var membersDoc = await firestore
        .collection(FirestoreKeys.clubMembersCollectionKey)
        .where(FirestoreKeys.clubIdFieldKey, isEqualTo: clubId)
        .get();

    final existedAndNonExistedMembers = <ClubMemberEntity>[];

    for (var user in allUsers) {
      final memberDocForThisUser = membersDoc.docs.firstWhereOrNull(
        (doc) => doc.data()[FirestoreKeys.clubMemberUserIdFieldKey] == user.id,
      );
      existedAndNonExistedMembers.add(
        ClubMemberEntity(
          id: memberDocForThisUser?.id,
          clubId: clubId,
          user: user,
        ),
      );
    }
    return existedAndNonExistedMembers;
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

  @override
  Future<bool> acceptUserToJoinClub(
      {required String clubId,
      required String currentUserId,
      required String participantUserId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<ClubMemberEntity>> getExistedClubMembers(
      {required String clubId}) async {
    var membersDoc = await firestore
        .collection(FirestoreKeys.clubMembersCollectionKey)
        .where(FirestoreKeys.clubIdFieldKey, isEqualTo: clubId)
        .get();

    final userIds = membersDoc.docs
        .map((doc) => doc.data()[FirestoreKeys.clubMemberUserIdFieldKey])
        .toList();

    final usersSnapshot = await firestore
        .collection(FirestoreKeys.usersCollectionKey)
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    final users = usersSnapshot.docs
        .map((doc) => UserEntity.fromFirestoreMap(id: doc.id, data: doc.data()))
        .toList();

    return membersDoc.docs
        .map(
          (doc) => ClubMemberEntity.fromFirestoreMap(
            id: doc.id,
            data: doc.data(),
            user: users.firstWhereOrNull(
              (user) =>
                  user.id == doc.data()[FirestoreKeys.clubMemberUserIdFieldKey],
            ),
          ),
        )
        .toList();
  }
}
