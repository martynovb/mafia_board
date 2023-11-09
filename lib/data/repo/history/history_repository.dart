import 'package:mafia_board/domain/model/game_history_model.dart';

abstract class HistoryRepo {
  List<GameHistoryModel> getAll();

  void add(GameHistoryModel model);

  void update(GameHistoryModel model);

  void delete(GameHistoryModel model);

  void deleteWhere(bool Function(GameHistoryModel model) condition);

  void deleteAll();
}
