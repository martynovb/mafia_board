import 'package:mafia_board/domain/model/game_details_model.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';

class GameDetailsState extends BaseState {
  final String? gameId;
  final GameDetailsModel gameDetails;

  GameDetailsState({
    this.gameId,
    this.gameDetails = const GameDetailsModel.empty(),
    required super.status,
    super.errorMessage,
  });

  @override
  GameDetailsState copyWith({
    String? gameId,
    GameDetailsModel? gameDetails,
    String? errorMessage,
    StateStatus? status,
  }) {
    return GameDetailsState(
      gameId: gameId ?? this.gameId,
      gameDetails: gameDetails ?? this.gameDetails,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() => {
    'gameId' : gameId,
    'gameDetails' : gameId,
  };
}
