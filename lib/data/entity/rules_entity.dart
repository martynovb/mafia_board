import 'package:mafia_board/data/constants/firestore_keys.dart';

class RulesEntity {
  final String? id;

  final String? clubId;

  final double? civilWin;
  final double? mafWin;
  final double? civilLoss;
  final double? mafLoss;
  final double? disqualificationLoss;
  final double? defaultBonus;
  final double? ppkLoss;
  final double? defaultGameLoss;
  final double? twoBestMove;
  final double? threeBestMove;

  RulesEntity({
    this.id,
    required this.clubId,
    required this.civilWin,
    required this.mafWin,
    required this.civilLoss,
    required this.mafLoss,
    required this.disqualificationLoss,
    required this.defaultBonus,
    required this.ppkLoss,
    required this.defaultGameLoss,
    required this.twoBestMove,
    required this.threeBestMove,
  });

  Map<String, dynamic> toFirestoreMap() => {
        FirestoreKeys.clubIdFieldKey: clubId,
        FirestoreKeys.rulesClubCivilWinFieldKey: civilWin,
        FirestoreKeys.rulesClubMafWinFieldKey: mafWin,
        FirestoreKeys.rulesClubCivilLossFieldKey: civilLoss,
        FirestoreKeys.rulesClubMafLossFieldKey: mafLoss,
        FirestoreKeys.rulesClubDisqualificationLossFieldKey:
            disqualificationLoss,
        FirestoreKeys.rulesClubDefaultBonusFieldKey: defaultBonus,
        FirestoreKeys.rulesClubPpkLossFieldKey: ppkLoss,
        FirestoreKeys.rulesClubDefaultGameLossFieldKey: defaultGameLoss,
        FirestoreKeys.rulesClubTwoBestMoveFieldKey: twoBestMove,
        FirestoreKeys.rulesClubThreeBestMoveFieldKey: threeBestMove,
      };

  static RulesEntity fromFirestoreMap({
    required String id,
    required Map<dynamic, dynamic> json,
  }) =>
      RulesEntity(
        id: id,
        clubId: json[FirestoreKeys.clubIdFieldKey],
        civilWin: json[FirestoreKeys.rulesClubCivilWinFieldKey],
        mafWin: json[FirestoreKeys.rulesClubMafWinFieldKey],
        civilLoss: json[FirestoreKeys.rulesClubCivilLossFieldKey],
        mafLoss: json[FirestoreKeys.rulesClubMafLossFieldKey],
        disqualificationLoss: json[FirestoreKeys.rulesClubDisqualificationLossFieldKey],
        defaultBonus: json[FirestoreKeys.rulesClubDefaultGameLossFieldKey],
        ppkLoss: json[FirestoreKeys.rulesClubPpkLossFieldKey],
        defaultGameLoss: json[FirestoreKeys.rulesClubCivilWinFieldKey],
        twoBestMove: json[FirestoreKeys.rulesClubTwoBestMoveFieldKey],
        threeBestMove: json[FirestoreKeys.rulesClubThreeBestMoveFieldKey],
      );

  static RulesEntity? fromSheetValues(List<List<dynamic>> values) {
    if (values.isEmpty) {
      return null;
    }
    Map<String, dynamic> json = {};
    for (var row in values) {
      if (row.length >= 2) {
        json[row[0]] = double.tryParse(row[1].toString());
      }
    }
    return RulesEntity.fromJson(json);
  }

  static RulesEntity fromJson(Map<dynamic, dynamic> json) {
    return RulesEntity(
      id: json['id'] as String?,
      clubId: json['clubId'] as String?,
      civilWin: json['civilWin'] as double?,
      mafWin: json['mafWin'] as double?,
      civilLoss: json['civilLoss'] as double?,
      mafLoss: json['mafLoss'] as double?,
      disqualificationLoss: json['kickLoss'] as double?,
      defaultBonus: json['default_bonus'] as double?,
      ppkLoss: json['ppkLoss'] as double?,
      defaultGameLoss: json['default_game_loss'] as double?,
      twoBestMove: json['two_best_move'] as double?,
      threeBestMove: json['three_best_move'] as double?,
    );
  }
}
