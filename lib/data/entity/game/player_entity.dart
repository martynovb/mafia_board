import 'package:class_to_string/class_to_string.dart';
import 'package:mafia_board/data/entity/user_entity.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/domain/model/user_model.dart';

class PlayerEntity {
  final UserEntity? user;
  final int? fouls;
  final String? role;
  final double? score;
  final bool? isRemoved;
  final bool? isKilled;
  final bool? isMuted;
  final bool? isKicked;
  final bool? isPPK;
  final int? seatNumber;

  final double? bestMove;
  final double? compensation;
  final double? gamePoints;
  final double? bonus;
  final bool? isFirstKilled;

  PlayerEntity({
    required this.user,
    required this.role,
    required this.seatNumber,
    required this.fouls,
    required this.score,
    required this.isRemoved,
    required this.isKilled,
    required this.isMuted,
    required this.isKicked,
    required this.isPPK,
    required this.bestMove,
    required this.compensation,
    required this.gamePoints,
    required this.bonus,
    required this.isFirstKilled,
  });

  static PlayerEntity fromJson(Map<dynamic, dynamic> json) {
    return PlayerEntity(
      user: UserEntity.fromJson(json['user']),
      role: json['role'] as String?,
      fouls: json['fouls'] as int?,
      score: json['score'] as double?,
      isRemoved: json['isRemoved'] as bool?,
      isKilled: json['isKilled'] as bool?,
      isMuted: json['isMuted'] as bool?,
      isKicked: json['isKicked'] as bool?,
      isPPK: json['isPPK'] as bool?,
      seatNumber: json['seatNumber'] as int?,
      bestMove: json['bestMove'] as double?,
      compensation: json['compensation'] as double?,
      gamePoints: json['gamePoints'] as double?,
      bonus: json['bonus'] as double?,
      isFirstKilled: json['isFirstKilled'] as bool?,
    );
  }

  static List<PlayerEntity> parsePlayerEntities(dynamic data) {
    if (data is! List) {
      return [];
    }
    return data
        .map<PlayerEntity>(
            (e) => PlayerEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
