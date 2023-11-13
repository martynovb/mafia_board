import 'package:flutter/material.dart';

Future<bool> showDefaultDialog({
  required BuildContext context,
  required String title,
  required List<Widget>? actions,
}) async {
  return (await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(title),
            actions: actions ??
                <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                  ),
                ],
          );
        },
      )) ??
      false;
}
