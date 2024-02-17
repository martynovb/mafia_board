import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/rules_entity.dart';

class RulesModel {
  final String? id;

  final String clubId;

  Map<String, double> settings;

  RulesModel({
    this.id,
    required this.clubId,
    required this.settings,
  });

  double getSetting(String key) {
    return settings[key] ?? 0.0;
  }

  RulesModel.empty()
      : id = null,
        clubId = '',
        settings = const {};

  RulesModel.fromEntity(RulesEntity entity)
      : id = entity.id,
        clubId = entity.clubId ?? '',
        settings = entity.settings;

  RulesEntity toEntity() => RulesEntity(
        id: id,
        clubId: clubId,
        settings: settings,
      );

  static Map<String, double> fillSettingsIfAbsent(Map<String, double> settings) {
    return settings
      ..putIfAbsent(FirestoreKeys.civilWin, () => 0.0)
      ..putIfAbsent(FirestoreKeys.mafWin, () => 0.0)
      ..putIfAbsent(FirestoreKeys.civilLoss, () => 0.0)
      ..putIfAbsent(FirestoreKeys.mafLoss, () => 0.0)
      ..putIfAbsent(FirestoreKeys.disqualificationLoss, () => 0.0)
      ..putIfAbsent(FirestoreKeys.defGameLoss, () => 0.0)
      ..putIfAbsent(FirestoreKeys.ppkLoss, () => 0.0)
      //best move
      ..putIfAbsent(FirestoreKeys.bestMoveWin0, () => 0.0)
      ..putIfAbsent(FirestoreKeys.bestMoveWin1, () => 0.0)
      ..putIfAbsent(FirestoreKeys.bestMoveWin2, () => 0.0)
      ..putIfAbsent(FirestoreKeys.bestMoveWin3, () => 0.0)
      ..putIfAbsent(FirestoreKeys.bestMoveLoss0, () => 0.0)
      ..putIfAbsent(FirestoreKeys.bestMoveLoss1, () => 0.0)
      ..putIfAbsent(FirestoreKeys.bestMoveLoss2, () => 0.0)
      ..putIfAbsent(FirestoreKeys.bestMoveLoss3, () => 0.0);
  }
}

//
// clubId: json[],
// civilWin: json[],
// mafWin: json[FirestoreKeys.],
// civilLoss: json[FirestoreKeys.],
// mafLoss: json[FirestoreKeys.],
// disqualificationLoss: json[FirestoreKeys.],
// defaultBonus: json[FirestoreKeys.],
// ppkLoss: json[FirestoreKeys.],
// defaultGameLoss: json[FirestoreKeys.],
// twoBestMove: json[FirestoreKeys.],
// threeBestMove: json[FirestoreKeys.],
