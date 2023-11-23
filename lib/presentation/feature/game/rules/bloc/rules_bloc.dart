import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/usecase/create_rules_usecase.dart';
import 'package:mafia_board/domain/usecase/get_rules_usecase.dart';
import 'package:mafia_board/domain/usecase/update_rules_usecase.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_event.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_state.dart';

class GameRulesBloc extends Bloc<RulesEvent, RulesState> {
  final GetRulesUseCase getRulesUseCase;
  final UpdateRulesUseCase updateRulesUseCase;
  final CreateRulesUseCase createRulesUseCase;

  GameRulesBloc({
    required this.getRulesUseCase,
    required this.updateRulesUseCase,
    required this.createRulesUseCase,
  }) : super(InitialRulesState()) {
    on<LoadRulesEvent>(_loadRulesEventHandler);
    on<CreateOrUpdateRulesEvent>(_updateRulesEventHandler);
  }

  void _loadRulesEventHandler(LoadRulesEvent event, emit) async {
    try {
      final rules = await getRulesUseCase.execute(params: event.clubId);
      emit(LoadedRulesState(rules));
    } catch (e) {
      emit(ErrorRulesState('Something went wrong'));
    }
  }

  void _updateRulesEventHandler(CreateOrUpdateRulesEvent event, emit) async {
    try {
      final rulesId = event.id;
      if (rulesId != null) {
        await updateRulesUseCase.execute(
          params: UpdateRulesParams(
            id: rulesId,
            civilWin: event.civilWin,
            mafWin: event.mafWin,
            civilLoss: event.civilLoss,
            mafLoss: event.mafLoss,
            kickLoss: event.kickLoss,
            defaultBonus: event.defaultBonus,
            ppkLoss: event.ppkLoss,
            gameLoss: event.gameLoss,
            twoBestMove: event.twoBestMove,
            threeBestMove: event.threeBestMove,
          ),
        );
      } else {
        await createRulesUseCase.execute(
          params: CreateRulesParams(
            clubId: event.clubId,
            civilWin: event.civilWin,
            mafWin: event.mafWin,
            civilLoss: event.civilLoss,
            mafLoss: event.mafLoss,
            kickLoss: event.kickLoss,
            defaultBonus: event.defaultBonus,
            ppkLoss: event.ppkLoss,
            gameLoss: event.gameLoss,
            twoBestMove: event.twoBestMove,
            threeBestMove: event.threeBestMove,
          ),
        );
      }
      emit(UpdateRulesSuccessState());
    } catch (e) {
      emit(ErrorRulesState('Something went wrong'));
    }
  }
}
