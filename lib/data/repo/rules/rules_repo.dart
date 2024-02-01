import 'package:mafia_board/data/entity/rules_entity.dart';

abstract class RulesRepo {
  Future<RulesEntity?> getClubRules({required String clubId});

  Future<void> updateClubRules({required RulesEntity rules});

  Future<void> createClubRules({required RulesEntity rules});
}
