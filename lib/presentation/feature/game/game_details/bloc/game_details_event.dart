abstract class GameDetailsEvent {}

class GetGameDetailsEvent extends GameDetailsEvent {
  final String? gameId;

  GetGameDetailsEvent(this.gameId);
}
