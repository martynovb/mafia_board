import 'package:mafia_board/data/entity/club_entity.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/domain/model/user_model.dart';

class ClubModel {
  final String id;
  final String title;
  final String description;
  final String googleSheetLink;
  final String googleSheetId;
  final List<UserModel> members;
  final List<UserModel> admins;
  final List<UserModel> waitList;
  bool isAdmin = false;
  List<GameModel> games = [];

  ClubModel.fromEntity(ClubEntity entity, [this.isAdmin = false])
      : id = entity.id ?? '',
        title = entity.title ?? '',
        description = entity.description ?? '',
        googleSheetId = entity.googleSheetId ?? '',
        googleSheetLink = entity.googleSheetId != null
            ? 'https://docs.google.com/spreadsheets/d/${entity.googleSheetId}'
            : '',
        members = entity.members
                ?.map((user) => UserModel.fromEntity(user))
                .toList() ??
            [],
        admins =
            entity.admins?.map((user) => UserModel.fromEntity(user)).toList() ??
                [],
        waitList = entity.waitList
                ?.map((user) => UserModel.fromEntity(user))
                .toList() ??
            [];
}
