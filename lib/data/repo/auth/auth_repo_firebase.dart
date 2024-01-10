import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mafia_board/data/api/error_handler.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/user_entity.dart';
import 'package:mafia_board/data/repo/auth/auth_repo.dart';

class AuthRepoFirebase extends AuthRepo {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRepoFirebase({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
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
      throw ValidationException('Nickname is taken');
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

  @override
  Future<UserEntity> authUserWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw InvalidCredentialsException('Google error');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await firebaseAuth.signInWithCredential(credential);

    final user = userCredential.user;

    if (user == null) {
      throw InvalidCredentialsException('Failed to authenticate with Firebase');
    }

    // Check if the user already exists in Firestore
    final userDoc = await firestore
        .collection(FirestoreKeys.usersCollectionKey)
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      await firestore
          .collection(FirestoreKeys.usersCollectionKey)
          .doc(userCredential.user?.uid)
          .set({
        FirestoreKeys.nicknameFieldKey: userCredential.user?.email,
        FirestoreKeys.emailFieldKey: userCredential.user?.email,
      });
    }

    return UserEntity(
      id: userCredential.user?.uid,
      nickname: null,
      email: userCredential.user?.email,
    );
  }

  @override
  Future<UserEntity> changeNickname({required String nickname}) async {
    if (!(await isNicknameAvailable(nickname))) {
      throw ValidationException('Nickname is taken');
    }

    final id = firebaseAuth.currentUser?.uid;

    if (id == null) {
      throw InvalidCredentialsException('Unauthorized');
    }

    await firestore.collection(FirestoreKeys.usersCollectionKey).doc(id).update(
      {
        FirestoreKeys.nicknameFieldKey: nickname,
      },
    );

    return me();
  }
}
