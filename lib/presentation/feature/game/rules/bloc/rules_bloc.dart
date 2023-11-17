import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/usecase/get_rules_usecase.dart';
import 'package:mafia_board/domain/usecase/update_rules_usecase.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_event.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_state.dart';

class GameRulesBloc extends Bloc<RulesEvent, RulesState> {
  final GetRulesUseCase getRulesUseCase;
  final UpdateRulesUseCase updateRulesUseCase;

  GameRulesBloc({
    required this.getRulesUseCase,
    required this.updateRulesUseCase,
  }) : super(InitialRulesState()) {
    on<LoadRulesEvent>(_loadRulesEventHandler);
    on<UpdateRulesEvent>(_updateRulesEventHandler);
  }

  void _loadRulesEventHandler(LoadRulesEvent event, emit) async {
    try {
      final rules = await getRulesUseCase.execute(params: event.clubId);
      emit(LoadedRulesState(rules));
    } catch (e) {
      emit(ErrorRulesState('Something went wrong'));
    }
  }

  void _updateRulesEventHandler(UpdateRulesEvent event, emit) async {
    try {
      await updateRulesUseCase.execute(
          params: UpdateRulesParams(
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
      ));
      emit(UpdateRulesSuccessState());
    } catch (e) {
      emit(ErrorRulesState('Something went wrong'));
    }
  }
}
