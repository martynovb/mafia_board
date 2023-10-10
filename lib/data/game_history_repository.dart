import 'package:mafia_board/data/model/game_history_model.dart';

class GameHistoryRepository {
  final List<GameHistoryModel> _gameHistory = [];

  List<GameHistoryModel> getAll() => _gameHistory;

  void add(GameHistoryModel model) => _gameHistory.add(model);

  void update(GameHistoryModel model) {
    final index = _gameHistory.indexWhere((item) => item.id == model.id);
    if (index != -1) {
      _gameHistory[index] = model;
    } else {
      add(model);
    }
  }

  void delete(GameHistoryModel model) => _gameHistory.remove(model);

  void deleteWhere(bool Function(GameHistoryModel model) condition) => _gameHistory.removeWhere(condition);

  void deleteAll() => _gameHistory.clear();
}
