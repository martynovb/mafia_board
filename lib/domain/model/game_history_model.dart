import 'package:mafia_board/domain/model/game_history_type.dart';
import 'package:mafia_board/domain/model/game_phase/game_phase_action.dart';

class GameHistoryModel {
  final int id;
  final String text;
  final String subText;
  final GameHistoryType type;
  final GamePhaseAction? gamePhaseAction;
  final DateTime createdAt;

  GameHistoryModel({
    this.id = -1,
    required this.text,
    this.subText = '',
    required this.type,
    this.gamePhaseAction,
    required this.createdAt,
  });
}
