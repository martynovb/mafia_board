import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';
import 'package:mafia_board/presentation/feature/game/rules/rule_item_view_model.dart';

class RulesState extends BaseState {
  final String? rulesId;
  final String? clubId;
  final List<RuleItemViewModel>? settings;

  RulesState({
    required super.status,
    super.errorMessage,
    this.rulesId,
    this.clubId,
    this.settings,
  });

  @override
  BaseState copyWith({
    String? rulesId,
    String? clubId,
    List<RuleItemViewModel>? settings,
    String? errorMessage,
    StateStatus? status,
  }) {
    return RulesState(
      rulesId: rulesId ?? this.rulesId,
      clubId: clubId ?? this.clubId,
      settings: settings ?? this.settings,
      errorMessage: errorMessage ?? super.errorMessage,
      status: status ?? super.status,
    );
  }
}
