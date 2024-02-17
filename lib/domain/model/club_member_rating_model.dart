import 'package:mafia_board/domain/model/club_member_model.dart';

class ClubMemberRatingModel {
  final ClubMemberModel member;
  final int totalGames;
  final int totalWins;
  final int totalLosses;
  final double winRate;
  final double civilianWinRate;
  final double mafWinRate;
  final double sheriffWinRate;
  final double donWinRate;
  final double donMafWinRate;
  final double civilSherWinRate;
  final double totalPoints;

  ClubMemberRatingModel({
    required this.member,
    required this.totalGames,
    required this.totalWins,
    required this.totalLosses,
    required this.winRate,
    required this.civilianWinRate,
    required this.mafWinRate,
    required this.sheriffWinRate,
    required this.donMafWinRate,
    required this.civilSherWinRate,
    required this.donWinRate,
    required this.totalPoints,
  });

  Map<String, dynamic> toMap() {
    return {
      'member': member.toMap(),
      'totalGames': totalGames,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
      'winRate': winRate,
      'civilianWinRate': civilianWinRate,
      'mafWinRate': mafWinRate,
      'sheriffWinRate': sheriffWinRate,
      'donWinRate': donWinRate,
      'donMafWinRate': donMafWinRate,
      'civilSherWinRate': civilSherWinRate,
      'totalPoints': totalPoints,
    };
  }

  factory ClubMemberRatingModel.fromMap(Map<String, dynamic> map) {
    return ClubMemberRatingModel(
      member: ClubMemberModel.fromMap(map['member']),
      totalGames: map['totalGames'],
      totalWins: map['totalWins'],
      totalLosses: map['totalLosses'],
      winRate: map['winRate'],
      civilianWinRate: map['civilianWinRate'],
      mafWinRate: map['mafWinRate'],
      sheriffWinRate: map['sheriffWinRate'],
      donWinRate: map['donWinRate'],
      donMafWinRate: map['donMafWinRate'],
      civilSherWinRate: map['civilSherWinRate'],
      totalPoints: map['totalPoints'],
    );
  }

  static List<ClubMemberRatingModel> fromListMap(dynamic data) {
    if (data == null || data.isEmpty) {
      return [];
    }
    return (data as List<dynamic>)
        .map((map) => ClubMemberRatingModel.fromMap(map))
        .toList();
  }
}
