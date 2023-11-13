import 'package:mafia_board/domain/model/rules_model.dart';

abstract class RulesState {}

class InitialRulesState extends RulesState {}

class LoadedRulesState extends RulesState {
  final RulesModel rules;

  LoadedRulesState(this.rules);
}

class UpdateRulesSuccessState extends RulesState {
}

class ErrorRulesState extends RulesState {
  final String error;

  ErrorRulesState(this.error);
}
