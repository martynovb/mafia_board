import 'package:mafia_board/presentation/feature/game/rules/rule_item_view_model.dart';

abstract class RulesEvent {}

class LoadRulesEvent extends RulesEvent {
  final String? clubId;

  LoadRulesEvent(this.clubId);
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
