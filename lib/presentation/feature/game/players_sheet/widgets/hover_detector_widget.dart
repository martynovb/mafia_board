import 'package:flutter/material.dart';

class HoverDetectorWidget extends StatefulWidget {
  final Widget child;
  final Color? changeToColor;
  final bool enabled;

  const HoverDetectorWidget({
    super.key,
    required this.child,
    this.changeToColor,
    this.enabled = true,
  });

  @override
  HoverDetectorWidgetState createState() => HoverDetectorWidgetState();
}

class HoverDetectorWidgetState extends State<HoverDetectorWidget> {
  Color _color = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return widget.enabled ? MouseRegion(
      onEnter: (event) => _onHover(true),
      onExit: (event) => _onHover(false),
      child: Container(
        color: _color,
        child: widget.child,
      ),
    ) : widget.child;
  }

  void _onHover(bool hovering) {
    setState(() {
      _color = hovering
          ? widget.changeToColor ?? Colors.white.withOpacity(0.1)
          : Colors.transparent;
    });
  }
}
