import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';

abstract class GameState {
  final ClubModel? club;

  GameState({required this.club});

  Map<String, dynamic> toMap() => {
        'club': club?.toMap(),
      };
}

class InitialGameState extends GameState {
  InitialGameState({super.club});
}

class GoToGameResults extends GameState {
  GoToGameResults({required super.club});
}

class CloseGameState extends GameState {
  CloseGameState({required super.club});
}

class ErrorBoardState extends GameState {
  final String errorMessage;

  ErrorBoardState({required super.club, required this.errorMessage});
}

class GamePhaseState extends GameState {
  String currentGamePhaseName = '';
  GameModel? currentGame;

  GamePhaseState({
    required super.club,
    this.currentGame,
    required this.currentGamePhaseName,
  });
}
