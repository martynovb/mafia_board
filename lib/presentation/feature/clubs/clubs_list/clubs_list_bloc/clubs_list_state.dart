import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';

class ClubsListState extends BaseState {
  final List<ClubModel> clubs;

  ClubsListState({
    this.clubs = const [],
    required super.status,
    super.errorMessage,
  });

  @override
  BaseState copyWith({
    List<ClubModel>? clubs,
    String? errorMessage,
    StateStatus? status,
  }) {
    return ClubsListState(
      clubs: clubs ?? this.clubs,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
