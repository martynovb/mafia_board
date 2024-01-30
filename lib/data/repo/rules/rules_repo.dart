import 'package:mafia_board/data/entity/rules_entity.dart';
import 'package:mafia_board/domain/model/club_model.dart';

abstract class RulesRepo {
  Future<RulesEntity?> getClubRules({required String clubId});

  Future<void> updateClubRules({required RulesEntity rules});

  Future<void> createClubRules({required RulesEntity rules});
}
