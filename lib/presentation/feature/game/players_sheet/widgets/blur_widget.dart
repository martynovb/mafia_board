import 'dart:ui';

import 'package:flutter/material.dart';

class BlurWidget extends StatefulWidget {
  final Widget child;
  final Widget? placeholder;
  final bool isBlured;

  const BlurWidget({
    Key? key,
    required this.child,
    this.placeholder,
    this.isBlured = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => BlurWidgetState();
}

class BlurWidgetState extends State<BlurWidget> {
  bool disableBlur = false;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
        enabled: _shouldBeBlured(),
        imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: GestureDetector(
          onTap: () {
            disableBlur = !disableBlur;
            setState(() {});
          },
          child: _shouldBeBlured() && widget.placeholder != null
              ? SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: widget.placeholder)
              : widget.child,
        ));
  }

  bool _shouldBeBlured() {
    return !disableBlur && widget.isBlured;
  }
}
