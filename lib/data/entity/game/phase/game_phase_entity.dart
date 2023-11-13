
abstract class GamePhaseEntity {
  final String? id;
  final int? currentDay;
  final DateTime? createdAt;
  final String? status; //notStarted, inProgress, finished
  final String? type; //vote, speak, night

  GamePhaseEntity({
    required this.id,
    required this.currentDay,
    required this.createdAt,
    required this.status,
    required this.type,
  });
}
