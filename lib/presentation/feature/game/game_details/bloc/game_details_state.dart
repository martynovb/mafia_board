import 'package:collection/collection.dart';
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

  @override
  Map<String, dynamic> toMap() => super.toMap()
    ..addAll({
      'gameId': gameId,
      'gameDetails': gameDetails.toMap(),
    });

  static GameDetailsState fromMap(
    Map<String, dynamic> map,
  ) =>
      GameDetailsState(
        gameId: map['gameId'] ?? '',
        gameDetails: GameDetailsModel.fromMap(map['gameDetails'] ?? {}),
        errorMessage: map['errorMessage'] ?? '',
        status: StateStatus.values
                .firstWhereOrNull((v) => v.name == map['status']) ??
            StateStatus.none,
      );
}
