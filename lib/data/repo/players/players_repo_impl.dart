import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/club_member_entity.dart';
import 'package:mafia_board/data/entity/game/player_entity.dart';
import 'package:mafia_board/data/entity/user_entity.dart';
import 'package:mafia_board/domain/model/club_member_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:uuid/uuid.dart';

class PlayersRepoImpl extends PlayersRepo {
  final List<PlayerModel> _players = [];
  final FirebaseFirestore firestore;

  PlayersRepoImpl({
    required this.firestore,
  });

  @override
  List<PlayerModel> createPlayers(int count) {
    _players.clear();
    for (int i = 1; i <= count; i++) {
      _players.add(PlayerModel.empty(i));
    }
    return _players;
  }

  @override
  void setUser(int seatNumber, ClubMemberModel clubMember) {
    final userIndexIfAlreadySet = _players.indexWhere(
        (player) => player.clubMember?.user.id == clubMember.user.id);
    if (userIndexIfAlreadySet != -1) {
      _players[userIndexIfAlreadySet] =
          PlayerModel.empty(_players[userIndexIfAlreadySet].seatNumber);
    }
    final playerIndex =
        _players.indexWhere((player) => player.seatNumber == seatNumber);
    PlayerModel player = PlayerModel(
      tempId: const Uuid().v1(),
      clubMember: clubMember,
      role: Role.none,
      seatNumber: seatNumber,
    );
    _players[playerIndex] = player;
  }

  @override
  List<PlayerModel> getAllPlayers() => _players;

  @override
  List<PlayerModel> getAllAvailablePlayers() => _players
      .where((player) =>
          !player.isKilled && !player.isDisqualified && !player.isKicked)
      .toList();

  @override
  Future<PlayerModel?> getPlayerByNumber(int number) async =>
      _players.firstWhereOrNull((player) => player.seatNumber == number);

  @override
  Future<void> updatePlayer(
    String id, {
    int? fouls,
    Role? role,
    bool? isRemoved,
    bool? isKilled,
    bool? isKicked,
    bool? isMuted,
    bool? isPPK,
  }) async {
    int playerIndex = _players.indexWhere((player) => player.tempId == id);
    if (playerIndex == -1) {
      return;
    }

    PlayerModel player = _players[playerIndex];
    player.fouls = fouls ?? player.fouls;
    player.role = role ?? player.role;
    player.isDisqualified = isRemoved ?? player.isDisqualified;
    player.isKilled = isKilled ?? player.isKilled;
    player.isKicked = isKicked ?? player.isKicked;
    player.isMuted = isMuted ?? player.isMuted;
    player.isPPK = isPPK ?? player.isPPK;
    _players[playerIndex] = player;
  }

  @override
  void resetAll() {
    for (var player in _players) {
      player.reset();
    }
  }

  @override
  Future<PlayerModel?> getPlayerByTempId(String tempId) async {
    return _players.firstWhereOrNull((player) => player.tempId == tempId);
  }

  @override
  Future<List<PlayerModel>> getAllPlayersByRole(List<Role> roles) async =>
      _players
          .where((player) => roles.any((role) => player.role == role))
          .toList();

  @override
  Future<void> updateAllPlayerData(PlayerModel playerToUpdate) async {
    int playerIndex =
        _players.indexWhere((player) => player.tempId == playerToUpdate.tempId);
    if (playerIndex == -1) {
      return;
    }
    _players[playerIndex] = playerToUpdate;
  }

  @override
  Future<List<PlayerEntity>> savePlayers({required String gameId}) async {
    CollectionReference playersRef =
        firestore.collection(FirestoreKeys.playersCollectionKey);

    WriteBatch batch = firestore.batch();
    final createdPlayers = <PlayerEntity>[];

    // todo: use only PlayerEntity in repo
    for (PlayerModel player in _players) {
      final playerEntity = player.toEntity();
      playerEntity.gameId = gameId;
      DocumentReference memberDocRef = playersRef.doc();
      batch.set(memberDocRef, playerEntity.toFirestoreMap());
      playerEntity.id = memberDocRef.id;
      player.id = memberDocRef.id;
      createdPlayers.add(playerEntity);
    }

    await batch.commit();

    return createdPlayers;
  }

  @override
  Future<void> deleteAllPlayersByGameId({required String gameId}) async {
    final batch = firestore.batch();

    final collectionRef = firestore
        .collection(FirestoreKeys.playersCollectionKey)
        .where(FirestoreKeys.gameIdFieldKey, isEqualTo: gameId);
    final snapshots = await collectionRef.get();

    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  @override
  Future<List<PlayerEntity>> fetchAllPlayersByGameId(
      {required String gameId}) async {
    final playerSnapshot = await firestore
        .collection(FirestoreKeys.playersCollectionKey)
        .where(FirestoreKeys.gameIdFieldKey, isEqualTo: gameId)
        .get();

    final clubMemberIds = playerSnapshot.docs
        .map(
          (doc) => doc.data()[FirestoreKeys.clubMemberIdFieldKey],
        )
        .toList();

    final membersSnapshot = await firestore
        .collection(FirestoreKeys.clubMembersCollectionKey)
        .where(FieldPath.documentId, whereIn: clubMemberIds)
        .get();

    final userIds = membersSnapshot.docs
        .map((doc) => doc.data()[FirestoreKeys.clubMemberUserIdFieldKey])
        .toList();

    final usersSnapshot = await firestore
        .collection(FirestoreKeys.usersCollectionKey)
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    final users = usersSnapshot.docs
        .map((doc) => UserEntity.fromFirestoreMap(id: doc.id, data: doc.data()))
        .toList();

    final members = membersSnapshot.docs
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

    final players = playerSnapshot.docs
        .map(
          (doc) => PlayerEntity.fromFirestoreMap(
            id: doc.id,
            clubMember: members.firstWhereOrNull((member) =>
                member.id == doc.data()[FirestoreKeys.clubMemberIdFieldKey]),
            data: doc.data(),
          ),
        )
        .toList();

    return players;
  }

  @override
  Future<List<PlayerEntity>> fetchAllPlayersByMemberId({
    required String memberId,
  }) async {

    final playerSnapshot = await firestore
        .collection(FirestoreKeys.playersCollectionKey)
        .where(FirestoreKeys.clubMemberIdFieldKey, isEqualTo: memberId)
        .get();

    final players = playerSnapshot.docs
        .map(
          (doc) => PlayerEntity.fromFirestoreMap(
            id: doc.id,
            data: doc.data(),
          ),
        )
        .toList();

    return players;
  }
}
