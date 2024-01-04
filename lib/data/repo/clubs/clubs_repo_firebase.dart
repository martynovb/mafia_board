import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mafia_board/data/api/error_handler.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/club_entity.dart';
import 'package:mafia_board/data/entity/google_http_client.dart';
import 'package:mafia_board/data/repo/auth/users/users_repo.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;


class ClubsRepoFirebase extends ClubsRepo {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;
  final UsersRepo usersRepo;

  ClubsRepoFirebase({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
    required this.usersRepo,
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
      final dynamicList = doc.data()[FirestoreKeys.clubAdminsIdsFieldKey] as List<dynamic>?;
      List<String> adminIds = dynamicList?.map((item) => item.toString()).toList() ?? [];

      var club = ClubEntity(
        id: doc.id,
        title: doc.data()[FirestoreKeys.clubTitleFieldKey],
        googleSheetId: doc.data()[FirestoreKeys.clubGoogleSheetIdFieldKey],
        description: doc.data()[FirestoreKeys.clubDescriptionFieldKey],
        admins: await usersRepo.getUsersByIds(adminIds),
      );
      clubs.add(club);
    }

    return clubs;
  }

  @override
  Future<ClubEntity> createClubWithGoogleTable({
    required String name,
    required String clubDescription,
  }) async {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) {
      throw InvalidCredentialsException('User is not authorized');
    }

    GoogleSignInAccount? account = await googleSignIn.signInSilently();
    var authHeaders = await account?.authHeaders;

    if (authHeaders == null) {
      account = await googleSignIn.signIn();
      authHeaders = await account?.authHeaders;
      if(authHeaders == null){
        throw InvalidCredentialsException("Can't sign in with google");
      }
    }

    // Create an HTTP client using the auth headers
    final httpClient = GoogleHttpClient(authHeaders);

    // Use Google Sheets API to create a new sheet
    final sheetsApi = sheets.SheetsApi(httpClient);
    var newSheet = sheets.Spreadsheet(
        properties: sheets.SpreadsheetProperties(title: name));
    sheets.Spreadsheet createdSheet =
        await sheetsApi.spreadsheets.create(newSheet);


    final doc =
        await firestore.collection(FirestoreKeys.clubsCollectionKey).add(
      {
        FirestoreKeys.clubTitleFieldKey: name,
        FirestoreKeys.clubDescriptionFieldKey: clubDescription,
        FirestoreKeys.clubGoogleSheetIdFieldKey: createdSheet.spreadsheetId,
        FirestoreKeys.clubMembersIdsFieldKey: [userId],
        FirestoreKeys.clubAdminsIdsFieldKey: [userId],
      },
    );

    return ClubEntity(
      id: doc.id,
      title: name,
      description: clubDescription,
      googleSheetId: createdSheet.spreadsheetId,
    );
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
