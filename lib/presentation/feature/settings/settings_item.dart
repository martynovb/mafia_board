import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String? subTitle;
  final String? description;
  final Widget? titleWidget;
  final Widget? subTitleWidget;
  final Widget? descriptionWidget;
  final VoidCallback? onPressed;
  final String? btnText;
  final Color btnColor;

  const SettingsItem({
    Key? key,
    required this.title,
    this.subTitle,
    this.subTitleWidget,
    this.description,
    this.titleWidget,
    this.descriptionWidget,
    this.onPressed,
    this.btnText,
    this.btnColor = Colors.white30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(
          top: Dimensions.sidePadding0_5x,
          bottom: Dimensions.sidePadding0_5x,
        ),
        child: Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: Dimensions.sidePadding0_25x,
                ),
                description != null
                    ? Text(
                        description!,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      )
                    : Container(),
                descriptionWidget ?? Container(),
              ],
            )),
            if (btnText != null && onPressed != null) ...[
              const Spacer(),
              SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(btnColor),
                    ),
                    child: Text(
                      btnText!,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  )),
            ]
          ],
        ));
  }
}
