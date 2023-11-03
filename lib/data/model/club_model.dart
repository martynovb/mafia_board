import 'package:mafia_board/data/model/game_model.dart';
import 'package:mafia_board/data/model/user_model.dart';

class ClubModel {
  final String id;
  final String title;
  final String description;
  final List<UserModel> members;
  final List<UserModel> admins;
  final List<UserModel> waitList;
  final List<GameModel> games;
  final bool amIAdmin;

  ClubModel({
    required this.id,
    required this.title,
    required this.description,
    required this.members,
    required this.admins,
    required this.waitList,
    required this.games,
    this.amIAdmin = false,
  });
}
