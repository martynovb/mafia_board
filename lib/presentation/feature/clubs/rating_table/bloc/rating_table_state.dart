import 'package:collection/collection.dart';
import 'package:mafia_board/domain/model/club_member_rating_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';
import 'package:mafia_board/presentation/feature/clubs/rating_table/sort_type.dart';

class RatingTableState extends BaseState {
  final String clubId;
  final List<GameModel> allGames;
  final List<ClubMemberRatingModel> membersRating;
  final SortType sortType;

  RatingTableState({
    this.clubId = '',
    this.allGames = const [],
    this.membersRating = const [],
    this.sortType = SortType.totalPoints,
    required super.status,
    super.errorMessage,
  });

  @override
  RatingTableState copyWith({
    String? clubId,
    List<GameModel>? allGames,
    List<ClubMemberRatingModel>? membersRating,
    String? errorMessage,
    StateStatus? status,
    SortType? sortType,
  }) {
    return RatingTableState(
      clubId: clubId ?? this.clubId,
      allGames: allGames ?? this.allGames,
      membersRating: membersRating ?? this.membersRating,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
      sortType: sortType ?? this.sortType,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'clubId': clubId,
        'allGames': allGames.map((game) => game.toMap()).toList(),
        'membersRating': membersRating.map((rating) => rating.toMap()).toList(),
        'sortType': sortType.name,
      });
  }

  static RatingTableState fromMap(Map<String, dynamic> map) {
    return RatingTableState(
      status:
          StateStatus.values.firstWhereOrNull((v) => v.name == map['status']) ??
              StateStatus.none,
      errorMessage: map['errorMessage'] ?? '',
      clubId: map['clubId'] ?? '',
      allGames: GameModel.fromListMap(map['allGames']),
      membersRating: ClubMemberRatingModel.fromListMap(map['membersRating']),
      sortType: SortType.values.firstWhereOrNull((v) => v.name == map['sortType']) ??
          SortType.totalPoints,
    );
  }
}
