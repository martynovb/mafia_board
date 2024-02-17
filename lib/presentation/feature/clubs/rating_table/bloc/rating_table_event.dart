import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/presentation/feature/clubs/rating_table/sort_type.dart';

abstract class RatingTableEvent {}

class GetRatingTableEvent extends RatingTableEvent {
  final String clubId;
  final List<GameModel> allGames;

  GetRatingTableEvent({
    required this.clubId,
    required this.allGames,
  });
}

class ChangeSortTypeEvent extends RatingTableEvent {
  final SortType sortType;

  ChangeSortTypeEvent({
    required this.sortType,
  });
}


