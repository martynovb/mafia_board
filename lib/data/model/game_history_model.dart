import 'package:mafia_board/data/model/game_history_type.dart';

class GameHistoryModel {
  final String text;
  final GameHistoryType type;

  GameHistoryModel({
    required this.text,
    this.type = GameHistoryType.none,
  });
}
