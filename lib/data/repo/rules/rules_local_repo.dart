import 'package:collection/collection.dart';
import 'package:mafia_board/data/entity/club_entity.dart';
import 'package:mafia_board/data/entity/rules_entity.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/data/repo/rules/rules_repo.dart';
import 'package:uuid/uuid.dart';

class RulesLocalRepo extends RulesRepo {
  final ClubsRepo clubsRepo;

  final List<RulesEntity> clubsRules = [];

  RulesLocalRepo(this.clubsRepo) {
    _initData();
  }

  Future<void> _initData() async {
    final clubs = await clubsRepo.getClubs();
    for (ClubEntity club in clubs) {
      clubsRules.add(RulesEntity(
        id: const Uuid().v1(),
        clubId: club.id,
        civilWin: 1,
        mafWin: 1,
        civilLoss: 0,
        mafLoss: 0,
        kickLoss: 0.4,
        defaultBonus: 0.4,
        ppkLoss: 0.7,
        defaultGameLoss: 0,
        twoBestMove: 0.3,
        threeBestMove: 0.5,
      ));
    }
  }

  @override
  Future<RulesEntity?> getClubRules(String clubId) async =>
      clubsRules.firstWhereOrNull((rules) => rules.clubId == clubId);

  @override
  Future<void> updateClubRules({
    required String clubId,
    required double civilWin,
    required double mafWin,
    required double civilLoss,
    required double mafLoss,
    required double kickLoss,
    required double defaultBonus,
    required double ppkLoss,
    required double gameLoss,
    required double twoBestMove,
    required double threeBestMove,
  }) async {
    int indexOf = clubsRules.indexWhere((rules) => rules.clubId == clubId);
    if (indexOf != -1) {
      clubsRules[indexOf] = RulesEntity(
        id: const Uuid().v1(),
        clubId: clubId,
        civilWin: civilWin,
        mafWin: mafWin,
        civilLoss: civilLoss,
        mafLoss: mafLoss,
        kickLoss: kickLoss,
        defaultBonus: defaultBonus,
        ppkLoss: ppkLoss,
        defaultGameLoss: gameLoss,
        twoBestMove: twoBestMove,
        threeBestMove: threeBestMove,
      );
    }
  }
}
