import 'package:flutter/cupertino.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';

class RuleItemViewModel {
  final String key;
  final double value;
  final TextEditingController controller;
  final bool isSimpleSetting;

  RuleItemViewModel({
    required this.key,
    required this.value,
    required this.controller,
    required this.isSimpleSetting,
  });

  static List<RuleItemViewModel> generateRuleItems(
    Map<String, dynamic> settings,
  ) {
    return settings.entries
        .map(
          (entry) => RuleItemViewModel(
            key: entry.key,
            value: entry.value,
            controller: TextEditingController()..text = entry.value.toString(),
            isSimpleSetting: !entry.key.contains(FirestoreKeys.bestMoveKey),
          ),
        )
        .toList();
  }

  MapEntry<String, double> toMapEntry() => MapEntry(
        key,
        double.tryParse(controller.text.trim()) ?? value,
      );
}
