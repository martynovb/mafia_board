class RulesEntity {
  final String? id;
  final String? clubId;

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
    required this.clubId,
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

  static RulesEntity fromJson(Map<dynamic, dynamic> json) {
    return RulesEntity(
      id: json['id'] as String?,
      clubId: json['clubId'] as String?,
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
