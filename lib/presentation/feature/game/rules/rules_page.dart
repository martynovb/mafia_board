import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/rules_model.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_bloc.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_event.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_state.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/widgets/dialogs.dart';
import 'package:mafia_board/presentation/feature/widgets/input_text_field.dart';

class RulesPage extends StatefulWidget {
  const RulesPage({Key? key}) : super(key: key);

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  late GameRulesBloc gameRulesBloc;
  late String clubId;
  RulesModel? rules;
  final civilWinController = TextEditingController();
  final mafWinController = TextEditingController();
  final civilLossController = TextEditingController();
  final mafLossController = TextEditingController();
  final kickLossController = TextEditingController();
  final defaultBonusController = TextEditingController();
  final ppkLossController = TextEditingController();
  final defaultGameLossController = TextEditingController();
  bool changesFlag = false;

  @override
  void initState() {
    gameRulesBloc = GetIt.I.get();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    clubId = args?['clubId'] ?? '';
    gameRulesBloc.add(LoadRulesEvent(clubId));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _showExitConfirmationDialog,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Club rules'),
          centerTitle: true,
        ),
        body: BlocConsumer(
          listener: (context, RulesState state) {
            if (state is UpdateRulesSuccessState) {
              Navigator.of(context).popUntil(
                (route) => route.settings.name == AppRouter.gamePage,
              );
            }
          },
          bloc: gameRulesBloc,
          builder: (context, RulesState state) {
            if (state is LoadedRulesState) {
              //return Center(child: Text('LoadedRulesState'),);
              rules = state.rules;
              return _body(state.rules);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _body(RulesModel rules) {
    return Padding(
        padding: const EdgeInsets.all(Dimensions.defaultSidePadding),
        child: Column(
          children: [
            //
            Row(
              children: [
                const SizedBox(
                    width: Dimensions.inputTextHeight * 2,
                    child: Text('Civilian win:')),
                const SizedBox(
                  width: Dimensions.sidePadding0_5x,
                ),
                SizedBox(
                    width: Dimensions.inputTextRuleWidth,
                    child: InputTextField(
                      textInputType: TextInputType.number,
                      controller: civilWinController,
                      preText: rules.civilWin.toString(),
                    )),
              ],
            ),
            //
            const Divider(
              height: Dimensions.defaultSidePadding,
            ),
            Row(
              children: [
                const SizedBox(
                  width: Dimensions.inputTextHeight * 2,
                  child: Text('Mafia win:'),
                ),
                const SizedBox(
                  width: Dimensions.sidePadding0_5x,
                ),
                SizedBox(
                    width: Dimensions.inputTextRuleWidth,
                    child: InputTextField(
                      textInputType: TextInputType.number,
                      controller: mafWinController,
                      preText: rules.mafWin.toString(),
                    )),
              ],
            ),
            //
            const Divider(
              height: Dimensions.defaultSidePadding,
            ),
            Row(
              children: [
                const SizedBox(
                    width: Dimensions.inputTextHeight * 2,
                    child: Text('Civilian loss:')),
                const SizedBox(
                  width: Dimensions.sidePadding0_5x,
                ),
                SizedBox(
                  width: Dimensions.inputTextRuleWidth,
                  child: InputTextField(
                    textInputType: TextInputType.number,
                    controller: civilLossController,
                    preText: rules.civilLoss.toString(),
                  ),
                ),
              ],
            ),
            //
            const Divider(
              height: Dimensions.defaultSidePadding,
            ),
            Row(
              children: [
                const SizedBox(
                    width: Dimensions.inputTextHeight * 2,
                    child: Text('Mafia loss:')),
                const SizedBox(
                  width: Dimensions.sidePadding0_5x,
                ),
                SizedBox(
                    width: Dimensions.inputTextRuleWidth,
                    child: InputTextField(
                      textInputType: TextInputType.number,
                      controller: mafLossController,
                      preText: rules.mafLoss.toString(),
                    )),
              ],
            ),
            //
            const Divider(
              height: Dimensions.defaultSidePadding,
            ),
            Row(
              children: [
                const SizedBox(
                    width: Dimensions.inputTextHeight * 2,
                    child: Text('Disqualification loss:')),
                const SizedBox(
                  width: Dimensions.sidePadding0_5x,
                ),
                SizedBox(
                    width: Dimensions.inputTextRuleWidth,
                    child: InputTextField(
                      textInputType: TextInputType.number,
                      controller: kickLossController,
                      preText: rules.kickLoss.toString(),
                    )),
              ],
            ),
            //
            const Divider(
              height: Dimensions.defaultSidePadding,
            ),
            Row(
              children: [
                const SizedBox(
                    width: Dimensions.inputTextHeight * 2,
                    child: Text('Default bonus:')),
                const SizedBox(
                  width: Dimensions.sidePadding0_5x,
                ),
                SizedBox(
                    width: Dimensions.inputTextRuleWidth,
                    child: InputTextField(
                      textInputType: TextInputType.number,
                      controller: defaultBonusController,
                      preText: rules.defaultBonus.toString(),
                    )),
              ],
            ),
            //
            const Divider(
              height: Dimensions.defaultSidePadding,
            ),
            Row(
              children: [
                const SizedBox(
                    width: Dimensions.inputTextHeight * 2,
                    child: Text('PPK loss:')),
                const SizedBox(
                  width: Dimensions.sidePadding0_5x,
                ),
                SizedBox(
                  width: Dimensions.inputTextRuleWidth,
                  child: InputTextField(
                    textInputType: TextInputType.number,
                    controller: ppkLossController,
                    preText: rules.ppkLoss.toString(),
                  ),
                ),
              ],
            ),
            //
            const Divider(
              height: Dimensions.defaultSidePadding,
            ),
            Row(
              children: [
                const SizedBox(
                    width: Dimensions.inputTextHeight * 2,
                    child: Text('Default game loss:')),
                const SizedBox(
                  width: Dimensions.sidePadding0_5x,
                ),
                SizedBox(
                  width: Dimensions.inputTextRuleWidth,
                  child: InputTextField(
                    textInputType: TextInputType.number,
                    controller: defaultGameLossController,
                    preText: rules.defaultGameLoss.toString(),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDefaultDialog(
      context: context,
      title: 'Do you want to save the changes before leaving?',
      actions: <Widget>[
        TextButton(
          child: const Text('No'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        TextButton(
          child: const Text('Yes'),
          onPressed: () {
            gameRulesBloc.add(
              UpdateRulesEvent(
                clubId: clubId,
                civilWin: double.tryParse(civilWinController.text.trim()) ??
                    rules?.civilWin ??
                    0.0,
                mafWin: double.tryParse(mafWinController.text.trim()) ??
                    rules?.mafWin ??
                    0.0,
                civilLoss: double.tryParse(civilLossController.text.trim()) ??
                    rules?.civilLoss ??
                    0.0,
                mafLoss: double.tryParse(mafLossController.text.trim()) ??
                    rules?.mafLoss ??
                    0.0,
                kickLoss: double.tryParse(kickLossController.text.trim()) ??
                    rules?.kickLoss ??
                    0.0,
                defaultBonus:
                    double.tryParse(defaultBonusController.text.trim()) ??
                        rules?.defaultBonus ??
                        0.0,
                ppkLoss: double.tryParse(ppkLossController.text.trim()) ??
                    rules?.ppkLoss ??
                    0.0,
                gameLoss:
                    double.tryParse(defaultGameLossController.text.trim()) ??
                        rules?.defaultGameLoss ??
                        0.0,
              ),
            );
          },
        ),
      ],
    );
  }
}
