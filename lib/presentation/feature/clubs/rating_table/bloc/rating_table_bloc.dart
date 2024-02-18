import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mafia_board/domain/model/club_member_rating_model.dart';
import 'package:mafia_board/domain/usecase/get_club_rating_usecase.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';
import 'package:mafia_board/presentation/feature/clubs/rating_table/bloc/rating_table_event.dart';
import 'package:mafia_board/presentation/feature/clubs/rating_table/bloc/rating_table_state.dart';
import 'package:mafia_board/presentation/feature/clubs/rating_table/sort_type.dart';

class RatingTableBloc extends HydratedBloc<RatingTableEvent, RatingTableState> {
  final GetClubRatingUseCase getClubRatingUseCase;

  RatingTableBloc({
    required this.getClubRatingUseCase,
  }) : super(RatingTableState(status: StateStatus.initial)) {
    on<GetRatingTableEvent>(_getRatingTable);
    on<ChangeSortTypeEvent>(_changeSortType);
  }

  Future<void> _changeSortType(ChangeSortTypeEvent event, emit) async {
    emit(
      state.copyWith(
        sortType: event.sortType,
        membersRating: _sortMembersRating(state.membersRating, event.sortType),
      ),
    );
  }

  Future<void> _getRatingTable(GetRatingTableEvent event, emit) async {
    if (event.clubId.isEmpty) {
      return;
    }

    emit(state.copyWith(status: StateStatus.inProgress));
    try {
      final membersRating = await getClubRatingUseCase.execute(
        params: GetClubRatingParams(
          clubId: event.clubId,
          games: event.allGames,
        ),
      );
      emit(
        state.copyWith(
          status: StateStatus.data,
          membersRating: _sortMembersRating(
            membersRating,
            SortType.totalPoints,
          ),
          allGames: event.allGames,
          clubId: event.clubId,
          sortType: SortType.totalPoints,
        ),
      );
    } catch (ex) {
      emit(
        state.copyWith(
          status: StateStatus.error,
          errorMessage: 'Something went wrong',
        ),
      );
    }
  }

  List<ClubMemberRatingModel> _sortMembersRating(
    List<ClubMemberRatingModel> rating,
    SortType sortType,
  ) {
    rating.sort((a, b) {
      switch (sortType) {
        case SortType.totalPoints:
          return b.totalPoints.compareTo(a.totalPoints);
        case SortType.totalGames:
          return b.totalGames.compareTo(a.totalGames);
        case SortType.totalWins:
          return b.totalWins.compareTo(a.totalWins);
        case SortType.totalLosses:
          return b.totalLosses.compareTo(a.totalLosses);
        case SortType.winRate:
          return b.winRate.compareTo(a.winRate);
        case SortType.civilianWinRate:
          return b.civilianWinRate.compareTo(a.civilianWinRate);
        case SortType.mafWinRate:
          return b.mafWinRate.compareTo(a.mafWinRate);
        case SortType.sheriffWinRate:
          return b.sheriffWinRate.compareTo(a.sheriffWinRate);
        case SortType.donWinRate:
          return b.donWinRate.compareTo(a.donWinRate);
        case SortType.donMafWinRate:
          return b.donMafWinRate.compareTo(a.donMafWinRate);
        case SortType.civilSherWinRate:
          return b.civilSherWinRate.compareTo(a.civilSherWinRate);
        case SortType.none:
          return 0;
      }
    });
    return rating;
  }

  @override
  RatingTableState? fromJson(Map<String, dynamic> json) {
    return RatingTableState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(RatingTableState state) {
    return state.toMap();
  }
}
