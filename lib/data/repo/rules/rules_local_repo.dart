import 'package:collection/collection.dart';
import 'package:mafia_board/data/entity/club_entity.dart';
import 'package:mafia_board/data/entity/rules_entity.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/data/repo/rules/rules_repo.dart';
import 'package:mafia_board/domain/model/club_model.dart';
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
      final rules = RulesEntity(
        id: const Uuid().v1(),
        civilWin: 1,
        mafWin: 1,
        civilLoss: 0,
        mafLoss: 0,
        disqualificationLoss: 0.4,
        defaultBonus: 0.4,
        ppkLoss: 0.7,
        defaultGameLoss: 0,
        twoBestMove: 0.3,
        threeBestMove: 0.5,
        clubId: '',
      );
      clubsRules.add(rules);
      club.rulesId = rules.id;
      //await clubsRepo.setClub(clubEntity: club);
    }
  }

  @override
  Future<RulesEntity?> getClubRules({required String clubId}) async {
    final club = await clubsRepo.getClubDetails(id: clubId);
    return clubsRules.firstWhereOrNull((rules) => rules.id == club?.rulesId);
  }

  @override
  Future<void> updateClubRules({required RulesEntity rules}) async {
    int indexOf = clubsRules.indexWhere((savedRules) => savedRules.id == rules.id);
    if (indexOf != -1) {
      clubsRules[indexOf] = rules;
    }
  }

  @override
  Future<void> createClubRules({required RulesEntity rules}) async {
    clubsRules.add(rules);
    final club = await clubsRepo.getClubDetails(id: rules.clubId!);
    if (club != null) {
      club.rulesId = rules.id;
      await clubsRepo.setClub(clubEntity: club);
    }
  }
}
