import 'package:collection/collection.dart';
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

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'club': club?.toMap(),
        'allGames': allGames.map((game) => game.toMap()).toList(),
      });
  }

  static ClubState fromMap(Map<String, dynamic> map) {
    return ClubState(
      status:
          StateStatus.values.firstWhereOrNull((v) => v.name == map['status']) ??
              StateStatus.none,
      errorMessage: map['errorMessage'] ?? '',
      club: ClubModel.fromMap(map['club'] ?? {}),
      allGames: GameModel.fromListMap(map['allGames'])
    );
  }
}
