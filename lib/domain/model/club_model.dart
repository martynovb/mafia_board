import 'package:mafia_board/data/entity/club_entity.dart';
import 'package:mafia_board/domain/model/club_member_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';

class ClubModel {
  final String id;
  final String title;
  final String description;
  List<ClubMemberModel> members;
  List<ClubMemberModel> admins;
  bool isAdmin;
  List<GameModel> games = [];
  double civilWinRate;
  double mafWinRate;
  DateTime createdAt;

  ClubModel.empty()
      : id = '',
        title = '',
        description = '',
        civilWinRate = 0.0,
        mafWinRate = 0.0,
        createdAt = DateTime.fromMillisecondsSinceEpoch(0),
        isAdmin = false,
        members = [],
        admins = [];

  ClubModel.fromEntity(ClubEntity entity)
      : id = entity.id ?? '',
        title = entity.title ?? '',
        description = entity.description ?? '',
        civilWinRate = entity.civilWinRate ?? 0.0,
        mafWinRate = entity.mafWinRate ?? 0.0,
        createdAt = entity.createdAt != null
            ? DateTime.fromMillisecondsSinceEpoch(entity.createdAt!)
            : DateTime.fromMillisecondsSinceEpoch(0),
        isAdmin = entity.isAdmin ?? false,
        members = [],
        admins = [];
}
