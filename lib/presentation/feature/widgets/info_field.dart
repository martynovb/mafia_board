import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';

class InfoField extends StatelessWidget {
  final String message;
  final InfoFieldType infoFieldType;

  const InfoField({
    Key? key,
    required this.message,
    required this.infoFieldType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: Dimensions.infoFieldHeight,
        decoration: BoxDecoration(
          color: _mapInfoTypeToColor(infoFieldType).withOpacity(0.2),
          borderRadius: BorderRadius.circular(3.0),
          border: Border.all(
            color: _mapInfoTypeToColor(infoFieldType).shade400,
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            message,
            style: TextStyle(
                color: _mapInfoTypeToColor(infoFieldType).shade400,
                fontSize: 14.0,
                fontWeight: FontWeight.bold),
          ),
        ));
  }

  MaterialColor _mapInfoTypeToColor(InfoFieldType infoFieldType) {
    switch (infoFieldType) {
      case InfoFieldType.info:
        return Colors.blue;
      case InfoFieldType.error:
        return Colors.red;
      case InfoFieldType.success:
        return Colors.green;
    }
  }
}

enum InfoFieldType { info, error, success }
