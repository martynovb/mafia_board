import 'package:flutter/cupertino.dart';

class RuleItemViewModel {
  final String key;
  final double value;
  final TextEditingController controller;

  RuleItemViewModel({
    required this.key,
    required this.value,
    required this.controller,
  });

  static List<RuleItemViewModel> generateRuleItems(
    Map<String, dynamic> settings,
  ) {
    return settings.entries
        .map(
          (entry) => RuleItemViewModel(
            key: entry.key,
            value: entry.value,
            controller: TextEditingController()..text = entry.value,
          ),
        )
        .toList();
  }

  MapEntry<String, double> toMapEntry() => MapEntry(
        key,
        double.tryParse(controller.text.trim()) ?? value,
      );
}
