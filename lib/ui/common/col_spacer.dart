import 'package:flutter/material.dart';

class ColSpacer extends StatelessWidget {
  final double space;

  const ColSpacer({Key? key, this.space = 20}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(left: space));
  }
}