import 'package:collection/collection.dart';
import 'package:mafia_board/data/entity/club_entity.dart';
import 'package:mafia_board/data/entity/user_entity.dart';
import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:mafia_board/data/repo/auth/users/users_repo.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:uuid/uuid.dart';

class ClubsRepoLocal extends ClubsRepo {
  final AuthRepo authRepo;
  final UsersRepo usersRepo;

  ClubsRepoLocal({
    required this.authRepo,
    required this.usersRepo,
  }) {
    _initClubsData();
  }

  Future _initClubsData() async {
    final club = _clubs.first;
    club.admins?.add(await authRepo.me());

    club.waitList?.add(UserEntity(
      id: const Uuid().v1(),
      nickname: 'Flash',
      email: 'flash@gmail.com',
    ));
    club.waitList?.add(UserEntity(
      id: const Uuid().v1(),
      nickname: 'Samorityanka',
      email: 'samorityanka@gmail.com',
    ));

    club.members?.addAll(await usersRepo.getAllUsers());
  }

  @override
  Future<bool> acceptUserToJoinClub({
    required String clubId,
    required String currentUserId,
    required String participantUserId,
  }) async {
    final club = _clubs.firstWhereOrNull((club) => club.id == clubId);
    if (club == null) {
      return false;
    }

    bool isCurrentUserAdmin =
        club.admins?.firstWhereOrNull((user) => user.id == currentUserId) !=
            null;

    if (!isCurrentUserAdmin) {
      return false;
    }

    final user =
        club.waitList?.firstWhereOrNull((user) => user.id == participantUserId);

    if (user == null) {
      return false;
    }

    club.members?.add(user);
    return true;
  }

  @override
  Future<ClubEntity?> getClubDetails({required String id}) async {
    return _clubs.firstWhereOrNull((club) => club.id == id);
  }

  @override
  Future<List<ClubEntity>> getClubs({String? id, int limit = 10}) async {
    var startIndexOf = 0;
    if (id != null) {
      startIndexOf = _clubs.indexWhere((club) => club.id == id);
      if (startIndexOf == -1) {
        startIndexOf = 0;
      }
    }

    var endIndex = startIndexOf + limit;
    if (endIndex > _clubs.length) {
      endIndex = _clubs.length;
    }

    return _clubs.sublist(startIndexOf, endIndex);
  }

  @override
  Future<bool> rejectUserToJoinClub({
    required String clubId,
    required String currentUserId,
    required String participantUserId,
  }) async {
    final club = _clubs.firstWhereOrNull((club) => club.id == clubId);
    if (club == null) {
      return false;
    }

    bool isCurrentUserAdmin =
        club.admins?.firstWhereOrNull((user) => user.id == currentUserId) !=
            null;

    if (!isCurrentUserAdmin) {
      return false;
    }

    final user =
        club.waitList?.firstWhereOrNull((user) => user.id == participantUserId);

    if (user == null) {
      return false;
    }

    return club.members?.remove(user) ?? false;
  }

  @override
  Future<bool> sendRequestToJoinClub({
    required String clubId,
    required String currentUserId,
  }) async {
    final club = _clubs.firstWhereOrNull((club) => club.id == clubId);
    if (club == null) {
      return false;
    }

    final currentUser = await authRepo.me();

    club.waitList?.add(currentUser);
    return true;
  }

  @override
  Future<bool> setUserAsAdminOfClub({
    required String clubId,
    required String currentUserId,
    required String participantUserId,
  }) async {
    final club = _clubs.firstWhereOrNull((club) => club.id == clubId);
    if (club == null) {
      return false;
    }

    bool isCurrentUserAdmin =
        club.admins?.firstWhereOrNull((user) => user.id == currentUserId) !=
            null;

    if (!isCurrentUserAdmin) {
      return false;
    }

    final user =
        club.waitList?.firstWhereOrNull((user) => user.id == participantUserId);

    if (user == null) {
      return false;
    }

    return club.members?.remove(user) ?? false;
  }

  final List<ClubEntity> _clubs = [
    ClubEntity(
      id: const Uuid().v1(),
      title: 'Zmiiv mafia',
      description: 'Zmiiv mafia mafia',
      members: [],
      admins: [],
      waitList: [],
    ),
    ClubEntity(
      id: const Uuid().v1(),
      title: 'Kharkiv mafia',
      description: 'Kharkiv mafia mafia',
      members: [],
      admins: [],
      waitList: [],
    ),
    ClubEntity(
      id: const Uuid().v1(),
      title: 'Kiev mafia',
      description: 'Kiev mafia mafia',
      members: [],
      admins: [],
      waitList: [],
    ),
  ];

  @override
  Future<ClubEntity> createClub({
    required String name,
    required String description,
  }) async {
    final ClubEntity clubEntity = ClubEntity(
      id: const Uuid().v1(),
      title: name,
      description: description,
      members: [await authRepo.me()],
      admins: [await authRepo.me()],
      waitList: [],
    );
    _clubs.add(clubEntity);
    return clubEntity;
  }

  @override
  Future<ClubEntity> updateClub({
    required String id,
    required String name,
    required String description,
  }) async {
    final ClubEntity? clubEntity =
        _clubs.firstWhereOrNull((club) => club.id == id);
    if (clubEntity == null) {
      throw Exception('no club id');
    }
    clubEntity.title = name;
    clubEntity.description = description;
    return clubEntity;
  }

  @override
  Future<ClubEntity> setClub({required ClubEntity clubEntity}) async {
    final index = _clubs.indexWhere((club) => club.id == clubEntity.id);
    if(index != -1) {
      _clubs[index] = clubEntity;
    } else {
      _clubs.add(clubEntity);
    }
    return clubEntity;
  }

  @override
  Future<ClubEntity> createClubsGoogleTable({required String name, required String googleSheetLink}) {
    throw UnimplementedError();
  }
}
