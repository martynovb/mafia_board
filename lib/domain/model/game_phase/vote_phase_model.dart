import 'package:class_to_string/class_to_string.dart';
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
    required super.tempId,
    required super.currentDay,
    required this.playerOnVote,
    this.whoPutOnVote,
    this.isGunfight = false,
    this.shouldKickAllPlayers = false,
    this.playersToKick = const [],
    this.votedPlayers = const {},
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
        shouldKickAllPlayers: map[FirestoreKeys.votePhaseShouldKickAllFieldKey])
      ..updatedAt = DateTime.fromMillisecondsSinceEpoch(
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
  String toString() {
    return (ClassToString('VotePhaseAction')
          ..add('id', tempId)
          ..add('currentDay', currentDay)
          ..add('createdAt', updatedAt)
          ..add('status', status)
          ..add('playerOnVote', playerOnVote)
          ..add('whoPutOnVote', whoPutOnVote)
          ..add('playersToKick', playersToKick)
          ..add('votedPlayers', votedPlayers)
          ..add('isGunfight', isGunfight)
          ..add('shouldKickAllPlayers', shouldKickAllPlayers))
        .toString();
  }
}
