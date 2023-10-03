import 'package:mafia_board/data/model/game_history_type.dart';
import 'package:mafia_board/data/model/game_phase/game_phase_action.dart';

class GameHistoryModel {
  final int id;
  final String text;
  final GameHistoryType type;
  final GamePhaseAction? gamePhaseAction;
  final DateTime createdAt;

  GameHistoryModel({
    this.id = -1,
    required this.text,
    required this.type,
    this.gamePhaseAction,
    required this.createdAt,
  });
}
