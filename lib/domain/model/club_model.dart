import 'package:mafia_board/data/entity/club_entity.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/domain/model/user_model.dart';

class ClubModel {
  final String id;
  final String title;
  final String description;
  final List<UserModel> members;
  final List<UserModel> admins;
  final List<UserModel> waitList;
  bool isAdmin = false;
  List<GameModel> games = [];

  ClubModel({
    required this.id,
    required this.title,
    required this.description,
    required this.members,
    required this.admins,
    required this.waitList,
    this.games = const [],
    this.isAdmin = false,
  });

  ClubModel.fromEntity(ClubEntity entity, [this.isAdmin = false])
      : id = entity.id ?? '',
        title = entity.title ?? '',
        description = entity.description ?? '',
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
