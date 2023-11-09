import 'package:mafia_board/domain/model/game_history_model.dart';
import 'package:mafia_board/data/repo/history/history_repository.dart';

class HistoryRepoLocal extends HistoryRepo {
  final List<GameHistoryModel> _gameHistory = [];

  @override
  List<GameHistoryModel> getAll() => _gameHistory;

  @override
  void add(GameHistoryModel model) => _gameHistory.add(model);

  @override
  void update(GameHistoryModel model) {
    final index = _gameHistory.indexWhere((item) => item.id == model.id);
    if (index != -1) {
      _gameHistory[index] = model;
    } else {
      add(model);
    }
  }

  @override
  void delete(GameHistoryModel model) => _gameHistory.remove(model);

  @override
  void deleteWhere(bool Function(GameHistoryModel model) condition) =>
      _gameHistory.removeWhere(condition);

  @override
  void deleteAll() => _gameHistory.clear();
}
