import 'package:collection/collection.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/domain/model/game_phase/game_phase_model.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';

class VotePhaseModel extends GamePhaseModel {
  final PlayerModel playerOnVote;
  final PlayerModel? whoPutOnVote;
  final List<PlayerModel> playersToKick;
  Set<PlayerModel> votedPlayers;
  bool isGunfight;
  bool shouldKickAllPlayers;

  VotePhaseModel({
    super.id,
    super.gameId,
    super.status,
    super.dayInfoId,
    required super.tempId,
    required super.currentDay,
    required this.playerOnVote,
    this.whoPutOnVote,
    this.isGunfight = false,
    this.shouldKickAllPlayers = false,
    required this.playersToKick,
    required this.votedPlayers,
  });

  @override
  PhaseType get phaseType => PhaseType.vote;

  static VotePhaseModel fromFirebaseMap({
    required String id,
    required Map<String, dynamic> map,
    required Set<PlayerModel> votedPlayers,
    required List<PlayerModel> playersToKick,
    required PlayerModel playerOnVote,
    required PlayerModel? whoPutOnVote,
  }) {
    return VotePhaseModel(
      id: id,
      tempId: map[FirestoreKeys.tempIdFieldKey],
      currentDay: map[FirestoreKeys.gamePhaseDayFieldKey],
      gameId: map[FirestoreKeys.gameIdFieldKey],
      status: PhaseStatus.finished,
      playerOnVote: playerOnVote,
      playersToKick: playersToKick,
      whoPutOnVote: whoPutOnVote,
      isGunfight: map[FirestoreKeys.votePhaseIsGunfightFieldKey],
      shouldKickAllPlayers: map[FirestoreKeys.votePhaseShouldKickAllFieldKey],
      votedPlayers: votedPlayers,
      dayInfoId: map[FirestoreKeys.dayInfoIdFieldKey],
    )..updatedAt = DateTime.fromMillisecondsSinceEpoch(
        map[FirestoreKeys.updatedAtFieldKey] ?? 0);
  }

  bool vote(PlayerModel playerModel) {
    updatedAt = DateTime.now();
    return votedPlayers.add(playerModel);
  }

  void addVoteList(List<PlayerModel> list) {
    updatedAt = DateTime.now();
    votedPlayers.addAll(list);
  }

  bool removeVote(PlayerModel playerModel) {
    updatedAt = DateTime.now();
    return votedPlayers.remove(playerModel);
  }

  @override
  Map<String, dynamic> toFirestoreMap() {
    return super.toFirestoreMap()
      ..addAll(
        {
          FirestoreKeys.votePhasePlayerOnVoteTempIdFieldKey:
              playerOnVote.tempId,
          FirestoreKeys.votePhaseWhoPutOnVoteTempIdFieldKey:
              whoPutOnVote?.tempId,
          FirestoreKeys.votePhasePlayersToKickTempIdsFieldKey:
              playersToKick.map(
            (player) => player.tempId,
          ),
          FirestoreKeys.votePhaseVotedPlayersTempIdsFieldKey: votedPlayers.map(
            (player) => player.tempId,
          ),
          FirestoreKeys.votePhaseIsGunfightFieldKey: isGunfight,
          FirestoreKeys.votePhaseShouldKickAllFieldKey: shouldKickAllPlayers,
        },
      );
  }

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll(
        {
          'playerOnVote': playerOnVote.toMap(),
          'whoPutOnVote': whoPutOnVote?.toMap(),
          'playersToKick':
              playersToKick.map((player) => player.toMap()).toList(),
          'votedPlayers': votedPlayers.map((player) => player.toMap()).toList(),
          'isGunfight': isGunfight,
          'shouldKickAllPlayers': shouldKickAllPlayers,
        },
      );
  }

  static VotePhaseModel fromMap({
    required Map<String, dynamic> map,
  }) {
    return VotePhaseModel(
      id: map['id'] ?? '',
      tempId: map['tempId'] ?? '',
      currentDay: map['currentDay'] ?? -1,
      gameId: map['tempId'] ?? '',
      dayInfoId: map['dayInfoId'] ?? '',
      status:
          PhaseStatus.values.firstWhereOrNull((v) => v.name == map['status']) ??
              PhaseStatus.none,
      playerOnVote: PlayerModel.fromMap(map['playerOnVote']),
      whoPutOnVote: PlayerModel.fromMap(map['whoPutOnVote']),
      isGunfight: map['isGunfight'] ?? false,
      shouldKickAllPlayers: map['shouldKickAllPlayers'] ?? false,
      votedPlayers: PlayerModel.fromListMap(map['votedPlayers']).toSet(),
      playersToKick: PlayerModel.fromListMap(map['playersToKick']),
    )..updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0);
  }
}
