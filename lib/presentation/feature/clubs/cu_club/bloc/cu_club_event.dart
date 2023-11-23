abstract class ClubEvent {}

class UpdateClubEvent extends ClubEvent {
  final String id;
  final String name;
  final String description;

  UpdateClubEvent({
    required this.id,
    required this.name,
    required this.description,
  });
}

class CreateClubEvent extends ClubEvent {
  final String name;
  final String description;

  CreateClubEvent({
    required this.name,
    required this.description,
  });
}
