import 'package:class_to_string/class_to_string.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/domain/model/game_phase/game_phase_model.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';

class VotePhaseModel extends GamePhaseModel {
  final PlayerModel playerOnVote;
  final PlayerModel? whoPutOnVote;
  final List<PlayerModel> playersToKick;
  Set<PlayerModel> votedPlayers = {};
  bool isGunfight;
  bool shouldKickAllPlayers;

  VotePhaseModel({
    String? id,
    required int currentDay,
    required this.playerOnVote,
    this.whoPutOnVote,
    this.isGunfight = false,
    this.shouldKickAllPlayers = false,
    this.playersToKick = const [],
  }) : super(
          id: id,
          currentDay: currentDay,
        );

  @override
  PhaseType get phaseType => PhaseType.vote;

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
