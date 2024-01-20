import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/user_entity.dart';
import 'package:mafia_board/data/repo/auth/users/users_repo.dart';

class UsersRepoFirebase extends UsersRepo {
  final FirebaseFirestore firestore;

  UsersRepoFirebase({
    required this.firestore,
  });

  @override
  Future<List<UserEntity>> getAllUsers() async {
    var adminDocs =
        await firestore.collection(FirestoreKeys.usersCollectionKey).get();

    return adminDocs.docs.map(
      (doc) {
        final userData = doc.data();
        return UserEntity(
          id: doc.id,
          nickname: userData[FirestoreKeys.nicknameFieldKey],
          email: userData[FirestoreKeys.emailFieldKey],
        );
      },
    ).toList();
  }

  @override
  Future<UserEntity?> getUserById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<UserEntity>?> getUsersByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    var adminDocs = await firestore
        .collection(FirestoreKeys.usersCollectionKey)
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return adminDocs.docs.map((doc) {
      final userData = doc.data();
      return UserEntity(
        id: doc.id,
        nickname: userData[FirestoreKeys.nicknameFieldKey],
        email: userData[FirestoreKeys.emailFieldKey],
      );
    }).toList();
  }
}
