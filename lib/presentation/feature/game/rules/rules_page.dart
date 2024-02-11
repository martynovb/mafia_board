import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/rules_model.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_bloc.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_event.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_state.dart';
import 'package:mafia_board/presentation/feature/game/rules/rule_item_view_model.dart';
import 'package:mafia_board/presentation/feature/widgets/input_text_field.dart';

class RulesPage extends StatefulWidget {
  const RulesPage({Key? key}) : super(key: key);

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  late GameRulesBloc gameRulesBloc;
  late ClubModel club;
  String? rulesId;
  RulesModel? rules;
  final civilWinController = TextEditingController();
  final mafWinController = TextEditingController();
  final civilLossController = TextEditingController();
  final mafLossController = TextEditingController();
  final kickLossController = TextEditingController();
  final defaultBonusController = TextEditingController();
  final ppkLossController = TextEditingController();
  final defaultGameLossController = TextEditingController();
  final twoBestMoveController = TextEditingController();
  final threeBestMoveController = TextEditingController();
  final compensationWhenFirstKilledController = TextEditingController();
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
    club = args?['club'] ?? ClubModel.empty();
    gameRulesBloc.add(LoadRulesEvent(club));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Club rules'),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: () => _save(gameRulesBloc.state.settings),
              child: const Text('Save'))
        ],
      ),
      body: BlocConsumer(
        listener: (context, RulesState state) {
          if (state.status == StateStatus.success) {
            Navigator.of(context).pop();
          }
        },
        bloc: gameRulesBloc,
        builder: (context, RulesState state) {
          if (state.status == StateStatus.data) {
            return _body(state.settings);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _body(List<RuleItemViewModel> settings) {
    return Padding(
        padding: const EdgeInsets.all(Dimensions.defaultSidePadding),
        child: Column(
          children: [
            //
            const Text('Bes move:'),
            Center(child: _bestMoveSettings()),
            const Divider(),
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
                    controller: settings[FirestoreKeys.civilWin].controller ?? TextEditingController(),
                    preText: rules?.civilWin.toString() ?? '',
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
                      preText: rules?.mafWin.toString() ?? '',
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
                    preText: rules?.civilLoss.toString() ?? '',
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
                      preText: rules?.mafLoss.toString() ?? '',
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
                      preText: rules?.kickLoss.toString() ?? '',
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
                      preText: rules?.defaultBonus.toString() ?? '',
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
                    preText: rules?.ppkLoss.toString() ?? '',
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
                    preText: rules?.defaultGameLoss.toString() ?? '',
                  ),
                ),
              ],
            ), //
            const Divider(
              height: Dimensions.defaultSidePadding,
            ),
            Row(
              children: [
                const SizedBox(
                    width: Dimensions.inputTextHeight * 2,
                    child: Text('Best move (2):')),
                const SizedBox(
                  width: Dimensions.sidePadding0_5x,
                ),
                SizedBox(
                  width: Dimensions.inputTextRuleWidth,
                  child: InputTextField(
                    textInputType: TextInputType.number,
                    controller: twoBestMoveController,
                    preText: rules?.bestMoveWin0.toString() ?? '',
                  ),
                ),
              ],
            ), //
            const Divider(
              height: Dimensions.defaultSidePadding,
            ),
            Row(
              children: [
                const SizedBox(
                    width: Dimensions.inputTextHeight * 2,
                    child: Text('Best move (3):')),
                const SizedBox(
                  width: Dimensions.sidePadding0_5x,
                ),
                SizedBox(
                  width: Dimensions.inputTextRuleWidth,
                  child: InputTextField(
                    textInputType: TextInputType.number,
                    controller: threeBestMoveController,
                    preText: rules?.threeBestMove.toString() ?? '',
                  ),
                ),
              ],
            ),

            const Divider(
              height: Dimensions.defaultSidePadding,
            ),
            Row(
              children: [
                const SizedBox(
                    width: Dimensions.inputTextHeight * 4,
                    child: Text('Compensation when first killed and lose:')),
                const SizedBox(
                  width: Dimensions.sidePadding0_5x,
                ),
                SizedBox(
                  width: Dimensions.inputTextRuleWidth,
                  child: InputTextField(
                    textInputType: TextInputType.number,
                    controller: compensationWhenFirstKilledController,
                    preText:
                        rules?.compensationWhenFirstKilled.toString() ?? '',
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _bestMoveSettings() {
    return Column(
      children: [
        const Row(children: [
          SizedBox(width: Dimensions.inputTextRuleWidth),
          SizedBox(
            width: Dimensions.sidePadding0_5x,
          ),
          SizedBox(
            width: Dimensions.inputTextRuleWidth,
            child: Center(child: Text('WIN')),
          ),
          SizedBox(
            width: Dimensions.sidePadding0_5x,
          ),
          SizedBox(
            width: Dimensions.inputTextRuleWidth,
            child: Center(child: Text('LOSE')),
          ),
        ]),
        const SizedBox(
          height: Dimensions.sidePadding0_5x,
        ),
        Row(children: [
          const SizedBox(
            width: Dimensions.inputTextRuleWidth,
            child: Center(child: Text('BM (0/3)')),
          ),
          const SizedBox(
            width: Dimensions.sidePadding0_5x,
          ),
          SizedBox(
              width: Dimensions.inputTextRuleWidth,
              child: InputTextField(
                textInputType: TextInputType.number,
                controller: TextEditingController(),
              )),
          const SizedBox(
            width: Dimensions.sidePadding0_5x,
          ),
          SizedBox(
              width: Dimensions.inputTextRuleWidth,
              child: InputTextField(
                textInputType: TextInputType.number,
                controller: TextEditingController(),
              )),
        ]),
        const SizedBox(
          height: Dimensions.sidePadding0_5x,
        ),
        Row(children: [
          const SizedBox(
            width: Dimensions.inputTextRuleWidth,
            child: Center(child: Text('BM (1/3)')),
          ),
          const SizedBox(
            width: Dimensions.sidePadding0_5x,
          ),
          SizedBox(
              width: Dimensions.inputTextRuleWidth,
              child: InputTextField(
                textInputType: TextInputType.number,
                controller: TextEditingController(),
              )),
          const SizedBox(
            width: Dimensions.sidePadding0_5x,
          ),
          SizedBox(
              width: Dimensions.inputTextRuleWidth,
              child: InputTextField(
                textInputType: TextInputType.number,
                controller: TextEditingController(),
              )),
        ]),
        const SizedBox(
          height: Dimensions.sidePadding0_5x,
        ),
        Row(children: [
          const SizedBox(
            width: Dimensions.inputTextRuleWidth,
            child: Center(child: Text('BM (2/3)')),
          ),
          const SizedBox(
            width: Dimensions.sidePadding0_5x,
          ),
          SizedBox(
              width: Dimensions.inputTextRuleWidth,
              child: InputTextField(
                textInputType: TextInputType.number,
                controller: TextEditingController(),
              )),
          const SizedBox(
            width: Dimensions.sidePadding0_5x,
          ),
          SizedBox(
              width: Dimensions.inputTextRuleWidth,
              child: InputTextField(
                textInputType: TextInputType.number,
                controller: TextEditingController(),
              )),
        ]),
        const SizedBox(
          height: Dimensions.sidePadding0_5x,
        ),
        Row(children: [
          const SizedBox(
            width: Dimensions.inputTextRuleWidth,
            child: Center(child: Text('BM (3/3)')),
          ),
          const SizedBox(
            width: Dimensions.sidePadding0_5x,
          ),
          SizedBox(
              width: Dimensions.inputTextRuleWidth,
              child: InputTextField(
                textInputType: TextInputType.number,
                controller: TextEditingController(),
              )),
          const SizedBox(
            width: Dimensions.sidePadding0_5x,
          ),
          SizedBox(
              width: Dimensions.inputTextRuleWidth,
              child: InputTextField(
                textInputType: TextInputType.number,
                controller: TextEditingController(),
              )),
        ]),
      ],
    );
  }

  void _save() {
    gameRulesBloc.add(
      CreateOrUpdateRulesEvent(
        id: gameRulesBloc.state.rulesId,
        clubId: gameRulesBloc.state.clubId,
        settings: gameRulesBloc.state.settings,
      ),
    );
  }
}
