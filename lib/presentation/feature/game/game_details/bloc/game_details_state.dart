import 'package:mafia_board/domain/model/game_details_model.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';

class GameDetailsState extends BaseState {
  final GameDetailsModel gameDetails;

  GameDetailsState({
    this.gameDetails = const GameDetailsModel.empty(),
    required super.status,
    super.errorMessage,
  });

  @override
  GameDetailsState copyWith({
    GameDetailsModel? gameDetails,
    String? errorMessage,
    StateStatus? status,
  }) {
    return GameDetailsState(
      gameDetails: gameDetails ?? this.gameDetails,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }
}
