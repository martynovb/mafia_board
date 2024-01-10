class RulesEntity {
  final String? id;

  final double? civilWin;
  final double? mafWin;
  final double? civilLoss;
  final double? mafLoss;
  final double? kickLoss;
  final double? defaultBonus;
  final double? ppkLoss;
  final double? defaultGameLoss;
  final double? twoBestMove;
  final double? threeBestMove;

  RulesEntity({
    required this.id,
    required this.civilWin,
    required this.mafWin,
    required this.civilLoss,
    required this.mafLoss,
    required this.kickLoss,
    required this.defaultBonus,
    required this.ppkLoss,
    required this.defaultGameLoss,
    required this.twoBestMove,
    required this.threeBestMove,
  });

  static RulesEntity? fromSheetValues(List<List<dynamic>> values) {
    if(values.isEmpty){
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
      civilWin: json['civilWin'] as double?,
      mafWin: json['mafWin'] as double?,
      civilLoss: json['civilLoss'] as double?,
      mafLoss: json['mafLoss'] as double?,
      kickLoss: json['kickLoss'] as double?,
      defaultBonus: json['default_bonus'] as double?,
      ppkLoss: json['ppkLoss'] as double?,
      defaultGameLoss: json['default_game_loss'] as double?,
      twoBestMove: json['two_best_move'] as double?,
      threeBestMove: json['three_best_move'] as double?,
    );
  }
}
