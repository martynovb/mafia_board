import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/model/game_history_model.dart';
import 'package:mafia_board/domain/manager/game_history_manager.dart';

class GameHistoryBloc
    extends Bloc<SubscribeToGameHistoryEvent, GameHistoryState> {
  final GameHistoryManager gameHistoryManager;

  GameHistoryBloc({
    required this.gameHistoryManager,
  }) : super(GameHistoryState()) {
    on<SubscribeToGameHistoryEvent>(_subscribeToGameHistoryEventHandler);
  }

  void _subscribeToGameHistoryEventHandler(
      SubscribeToGameHistoryEvent event, emit) {
    gameHistoryManager.gameHistoryStream.listen((records) {
      //todo: handle emit correctly
      // ignore: invalid_use_of_visible_for_testing_member
      this.emit(GameHistoryState(records: records.reversed.toList()));
    });
  }
}

class GameHistoryState {
  final List<GameHistoryModel> records;

  GameHistoryState({
    this.records = const [],
  });
}

class SubscribeToGameHistoryEvent {}
