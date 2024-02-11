import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/presentation/feature/game/rules/rule_item_view_model.dart';

abstract class RulesEvent {}

class LoadRulesEvent extends RulesEvent {
  final ClubModel club;

  LoadRulesEvent(this.club);
}

class CreateOrUpdateRulesEvent extends RulesEvent {
  final String? id;
  final String? clubId;

  final List<RuleItemViewModel>? settings;

  CreateOrUpdateRulesEvent({
    this.id,
    required this.clubId,
    required this.settings,
  });
}
