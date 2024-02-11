import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/model/rules_model.dart';
import 'package:mafia_board/domain/usecase/create_rules_usecase.dart';
import 'package:mafia_board/domain/usecase/get_rules_usecase.dart';
import 'package:mafia_board/domain/usecase/update_rules_usecase.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_event.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_state.dart';
import 'package:mafia_board/presentation/feature/game/rules/rule_item_view_model.dart';

class GameRulesBloc extends Bloc<RulesEvent, RulesState> {
  final GetRulesUseCase getRulesUseCase;
  final UpdateRulesUseCase updateRulesUseCase;
  final CreateRulesUseCase createRulesUseCase;

  GameRulesBloc({
    required this.getRulesUseCase,
    required this.updateRulesUseCase,
    required this.createRulesUseCase,
  }) : super(RulesState(status: StateStatus.inProgress)) {
    on<LoadRulesEvent>(_loadRulesEventHandler);
    on<CreateOrUpdateRulesEvent>(_updateRulesEventHandler);
  }

  void _loadRulesEventHandler(LoadRulesEvent event, emit) async {
    emit(state.copyWith(status: StateStatus.inProgress));
    try {
      final rules = await getRulesUseCase.execute(params: event.club.id);
      emit(
        state.copyWith(
          status: StateStatus.data,
          clubId: event.club.id,
          rulesId: rules.id,
          settings: RuleItemViewModel.generateRuleItems(rules.settings),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StateStatus.error,
          errorMessage: 'Something went wrong',
        ),
      );
    }
  }

  void _updateRulesEventHandler(CreateOrUpdateRulesEvent event, emit) async {
    try {
      final rulesId = event.id;
      if (rulesId != null) {
        await updateRulesUseCase.execute(
          params: RulesModel(
            clubId: event.club.id,
            settings: Map.fromEntries(
              event.settings.map(
                (v) => v.toMapEntry(),
              ),
            ),
          ),
        );
      } else {
        await createRulesUseCase.execute(
          params: RulesModel(
            clubId: event.club.id,
            settings: Map.fromEntries(
              event.settings.map(
                (v) => v.toMapEntry(),
              ),
            ),
          ),
        );
      }
      emit(state.copyWith(status: StateStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: StateStatus.error,
          errorMessage: 'Something went wrong',
        ),
      );
    }
  }
}
