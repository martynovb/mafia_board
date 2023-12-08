import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mafia_board/data/api/error_handler.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/user_entity.dart';
import 'package:mafia_board/data/repo/auth/auth_repo.dart';

class AutRepoFirebase extends AuthRepo {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AutRepoFirebase({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<bool> isAuthorized() async {
    return firebaseAuth.currentUser?.uid != null;
  }

  @override
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserEntity> me() async {
    final id = firebaseAuth.currentUser?.uid;
    final doc = await firestore
        .collection(FirestoreKeys.usersCollectionKey)
        .doc(id)
        .get();

    return UserEntity(
      id: id,
      email: doc.data()?[FirestoreKeys.emailFieldKey],
      nickname: doc.data()?[FirestoreKeys.nicknameFieldKey],
    );
  }

  @override
  Future<UserEntity> registerUser({
    required String email,
    required String nickname,
    required String password,
  }) async {
    if (!(await isNicknameAvailable(nickname))) {
      throw InvalidCredentialsException('Nickname is taken');
    }

    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await firestore
        .collection(FirestoreKeys.usersCollectionKey)
        .doc(userCredential.user?.uid)
        .set({
      FirestoreKeys.nicknameFieldKey: nickname,
      FirestoreKeys.emailFieldKey: email,
    });

    await firestore
        .collection(FirestoreKeys.nicknamesCollectionKey)
        .doc(nickname)
        .set({});

    return UserEntity(
      id: userCredential.user?.uid,
      nickname: nickname,
      email: email,
    );
  }

  Future<bool> isNicknameAvailable(String nickname) async {
    var snapshot = await FirebaseFirestore.instance
        .collection(FirestoreKeys.usersCollectionKey)
        .where(FirestoreKeys.nicknameFieldKey, isEqualTo: nickname)
        .get();
    return snapshot.size == 0;
  }
}
