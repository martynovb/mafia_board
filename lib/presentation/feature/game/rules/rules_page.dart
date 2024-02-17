import 'package:collection/collection.dart';
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

  @override
  void initState() {
    gameRulesBloc = GetIt.I.get();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? clubId = args?['clubId'] ?? gameRulesBloc.state.clubId;
    gameRulesBloc.add(LoadRulesEvent(clubId));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Club rules'),
        centerTitle: true,
        actions: [
          TextButton(onPressed: () => _save(), child: const Text('Save'))
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
            return _body(state.settings ?? []);
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
            const Text('Bes move:'),
            Center(child: _bestMoveSettings(settings)),
            const SizedBox(height: Dimensions.defaultSidePadding),
            const Divider(height: Dimensions.defaultSidePadding),
            const Text('Civilian:'),
            const SizedBox(height: Dimensions.defaultSidePadding),
            _getInputSettingsFieldWithLabel(
              settings: settings,
              key: FirestoreKeys.civilWin,
              label: 'Civilian win',
            ),
            const SizedBox(height: Dimensions.defaultSidePadding),
            _getInputSettingsFieldWithLabel(
              settings: settings,
              key: FirestoreKeys.civilLoss,
              label: 'Civilian loss',
            ),
            const SizedBox(height: Dimensions.defaultSidePadding),
            const Divider(height: Dimensions.defaultSidePadding),
            const Text('Mafia:'),
            const SizedBox(height: Dimensions.defaultSidePadding),
            _getInputSettingsFieldWithLabel(
              settings: settings,
              key: FirestoreKeys.mafWin,
              label: 'Mafia win',
            ),
            const SizedBox(height: Dimensions.defaultSidePadding),
            _getInputSettingsFieldWithLabel(
              settings: settings,
              key: FirestoreKeys.mafLoss,
              label: 'Mafia loss',
            ),
            const SizedBox(height: Dimensions.defaultSidePadding),
            const Divider(height: Dimensions.defaultSidePadding),
            const Text('Violations:'),
            const SizedBox(height: Dimensions.defaultSidePadding),
            _getInputSettingsFieldWithLabel(
              settings: settings,
              key: FirestoreKeys.disqualificationLoss,
              label: 'Kick loss',
            ),
            const SizedBox(height: Dimensions.defaultSidePadding),
            _getInputSettingsFieldWithLabel(
              settings: settings,
              key: FirestoreKeys.ppkLoss,
              label: 'PPK loss',
            ),
            const SizedBox(height: Dimensions.defaultSidePadding),
            const Divider(height: Dimensions.defaultSidePadding),
            const Text('Other:'),
            const SizedBox(height: Dimensions.defaultSidePadding),
            _getInputSettingsFieldWithLabel(
              settings: settings,
              key: FirestoreKeys.defGameLoss,
              label: 'Default game loss',
            ),
          ],
        ));
  }

  Widget _getInputSettingsFieldWithLabel({
    required List<RuleItemViewModel> settings,
    required String key,
    required String label,
  }) {
    return Row(
      children: [
        SizedBox(
          width: Dimensions.inputTextHeight * 2,
          child: Text('$label:'),
        ),
        const SizedBox(width: Dimensions.sidePadding0_5x),
        _getInputSettingsField(settings, key),
      ],
    );
  }

  Widget _getInputSettingsField(List<RuleItemViewModel> settings, String key) {
    final settingsItem =
        settings.firstWhereOrNull((settingsItem) => settingsItem.key == key);
    if (settingsItem == null) {
      return const SizedBox();
    }
    return SizedBox(
      width: Dimensions.inputTextRuleWidth,
      child: InputTextField(
        textInputType: TextInputType.number,
        controller: settingsItem.controller,
        preText: settingsItem.value.toString(),
      ),
    );
  }

  Widget _bestMoveSettings(List<RuleItemViewModel> settings) {
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
          _getInputSettingsField(settings, FirestoreKeys.bestMoveWin0),
          const SizedBox(
            width: Dimensions.sidePadding0_5x,
          ),
          _getInputSettingsField(settings, FirestoreKeys.bestMoveLoss0),
        ]),
        const SizedBox(
          height: Dimensions.sidePadding0_5x,
        ),
        Row(children: [
          const SizedBox(
            width: Dimensions.inputTextRuleWidth,
            child: Center(child: Text('BM (1/3)')),
          ),
          const SizedBox(width: Dimensions.sidePadding0_5x),
          _getInputSettingsField(settings, FirestoreKeys.bestMoveWin1),
          const SizedBox(width: Dimensions.sidePadding0_5x),
          _getInputSettingsField(settings, FirestoreKeys.bestMoveLoss1),
        ]),
        const SizedBox(
          height: Dimensions.sidePadding0_5x,
        ),
        Row(children: [
          const SizedBox(
            width: Dimensions.inputTextRuleWidth,
            child: Center(child: Text('BM (2/3)')),
          ),
          const SizedBox(width: Dimensions.sidePadding0_5x),
          _getInputSettingsField(settings, FirestoreKeys.bestMoveWin2),
          const SizedBox(width: Dimensions.sidePadding0_5x),
          _getInputSettingsField(settings, FirestoreKeys.bestMoveLoss2),
        ]),
        const SizedBox(
          height: Dimensions.sidePadding0_5x,
        ),
        Row(children: [
          const SizedBox(
            width: Dimensions.inputTextRuleWidth,
            child: Center(child: Text('BM (3/3)')),
          ),
          const SizedBox(width: Dimensions.sidePadding0_5x),
          _getInputSettingsField(settings, FirestoreKeys.bestMoveWin3),
          const SizedBox(width: Dimensions.sidePadding0_5x),
          _getInputSettingsField(settings, FirestoreKeys.bestMoveLoss3),
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
