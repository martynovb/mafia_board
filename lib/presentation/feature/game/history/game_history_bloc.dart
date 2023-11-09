import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/model/game_history_model.dart';
import 'package:mafia_board/domain/game_history_manager.dart';

class GameHistoryBloc
    extends Bloc<SubscribeToGameHistoryEvent, GameHistoryState> {
  static const String _tag = 'GameHistoryBloc';
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
