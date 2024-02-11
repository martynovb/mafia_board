import 'package:mafia_board/data/constants/firestore_keys.dart';

class RulesEntity {
  final String? id;

  final String? clubId;

  final Map<String, double> settings;

  RulesEntity({
    this.id,
    required this.clubId,
    required this.settings,
  });

  Map<String, dynamic> toFirestoreMap() => {
        FirestoreKeys.clubIdFieldKey: clubId,
      }..addAll(settings);

  static RulesEntity fromFirestoreMap({
    required String id,
    required Map<String, dynamic> json,
  }) {
    final firestoreMap = json
      ..removeWhere((key, value) => key == FirestoreKeys.clubIdFieldKey);
    return RulesEntity(
      id: id,
      clubId: json[FirestoreKeys.clubIdFieldKey],
      settings: firestoreMap.map(
        (key, value) => MapEntry(
          key,
          double.tryParse(value) ?? 0.0,
        ),
      ),
    );
  }
}
