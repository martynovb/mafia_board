import 'package:mafia_board/domain/model/club_model.dart';

abstract class ClubDetailsState {}

class InitialState extends ClubDetailsState {}

class DetailsState extends ClubDetailsState {
  final ClubModel club;

  DetailsState(this.club);
}
