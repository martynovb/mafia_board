import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';

class ClubState extends BaseState {
  final ClubModel? club;
  final List<GameModel> allGames;

  ClubState({
    this.allGames = const [],
    this.club,
    super.errorMessage,
    required super.status,
  });

  @override
  ClubState copyWith({
    ClubModel? club,
    List<GameModel>? allGames,
    String? errorMessage,
    StateStatus? status,
  }) {
    return ClubState(
      club: club ?? this.club,
      allGames: allGames ?? this.allGames,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }
}
