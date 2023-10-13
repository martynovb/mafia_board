import 'package:mafia_board/data/model/game_history_model.dart';

abstract class HistoryRepository {
  List<GameHistoryModel> getAll();

  void add(GameHistoryModel model);

  void update(GameHistoryModel model);

  void delete(GameHistoryModel model);

  void deleteWhere(bool Function(GameHistoryModel model) condition);

  void deleteAll();
}
