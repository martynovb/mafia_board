import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/player_score_model.dart';
import 'package:mafia_board/domain/model/winner_type.dart';
import 'package:uuid/uuid.dart';

class GameResultsModel {
  final String id = const Uuid().v1();
  final ClubModel club;
  final WinnerType winnerType;
  final List<PlayerScoreModel> scoreList;

  GameResultsModel({
    required this.club,
    required this.winnerType,
    required this.scoreList,
  });
}
