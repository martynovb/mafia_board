import 'package:mafia_board/data/entity/club_entity.dart';
import 'package:mafia_board/domain/model/club_member_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/domain/model/user_model.dart';

class ClubModel {
  final String id;
  final String title;
  final String description;
  final String googleSheetLink;
  final String googleSheetId;
  final List<ClubMemberModel> members;
  final List<ClubMemberModel> admins;
  bool isAdmin = false;
  List<GameModel> games = [];
  double civilWinRate;
  double mafWinRate;
  DateTime createdAt;

  ClubModel.empty()
      : id = '',
        title = '',
        description = '',
        googleSheetLink = '',
        googleSheetId = '',
        civilWinRate = 0.0,
        mafWinRate = 0.0,
        createdAt = DateTime.fromMillisecondsSinceEpoch(0),
        members = [],
        admins = [];

  ClubModel.fromEntity(ClubEntity entity, [this.isAdmin = false])
      : id = entity.id ?? '',
        title = entity.title ?? '',
        description = entity.description ?? '',
        googleSheetId = entity.googleSheetId ?? '',
        googleSheetLink = entity.googleSheetId != null
            ? 'https://docs.google.com/spreadsheets/d/${entity.googleSheetId}'
            : '',
        members = entity.members
                ?.map((member) => ClubMemberModel.fromEntity(member))
                .toList() ??
            [],
        admins =
            entity.admins?.map((member) => ClubMemberModel.fromEntity(member)).toList() ??
                [],
        civilWinRate = entity.civilWinRate ?? 0.0,
        mafWinRate = entity.mafWinRate ?? 0.0,
        createdAt = entity.createdAt != null
            ? DateTime.fromMillisecondsSinceEpoch(entity.createdAt!)
            : DateTime.fromMillisecondsSinceEpoch(0);
}
