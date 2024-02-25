import 'package:mafia_board/data/entity/game/phase/game_phase_entity.dart';
import 'package:mafia_board/data/entity/game/player_entity.dart';
import 'package:mafia_board/domain/utils/date_format_util.dart';

class VotePhaseEntity extends GamePhaseEntity {
  final PlayerEntity? playerOnVote;
  final PlayerEntity? whoPutOnVote;
  final List<PlayerEntity>? playersToKick;
  final List<PlayerEntity>? votedPlayers;
  final bool? isGunfight;
  final bool? kickAll;

  VotePhaseEntity({
    required String? id,
    required int? currentDay,
    required String? status,
    required DateTime? createdAt,
    required String? type,
    required this.playerOnVote,
    required this.whoPutOnVote,
    required this.playersToKick,
    required this.votedPlayers,
    required this.isGunfight,
    required this.kickAll,
  }) : super(
          id: id,
          currentDay: currentDay,
          status: status,
          createdAt: createdAt,
          type: type,
        );

  static VotePhaseEntity fromJson(Map<dynamic, dynamic> json) {
    return VotePhaseEntity(
      id: json['id'] as String?,
      currentDay: json['current_day'] as int?,
      createdAt: DateFormatUtil.convertStringToDate(json['created_at']),
      status: json['status'] as String?,
      type: json['type'] as String?,
      playerOnVote: PlayerEntity.fromJson(json['player_on_vote']),
      whoPutOnVote: PlayerEntity.fromJson(json['who_put_on_vote']),
      playersToKick: PlayerEntity.parsePlayerEntities(json['players_to_kick']),
      votedPlayers: PlayerEntity.parsePlayerEntities(json['voted_players']),
      isGunfight: json['is_gunfight'] as bool?,
      kickAll: json['kick_all'] as bool?,
    );
  }
}
