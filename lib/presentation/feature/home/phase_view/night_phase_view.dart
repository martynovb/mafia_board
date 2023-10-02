import 'package:flutter/widgets.dart';

class NightPhaseView extends StatefulWidget {
  const NightPhaseView({Key? key}) : super(key: key);

  @override
  State<NightPhaseView> createState() => _NightPhaseViewState();
}

class _NightPhaseViewState extends State<NightPhaseView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Night phase'),
    );
  }
}
