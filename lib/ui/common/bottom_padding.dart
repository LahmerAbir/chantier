import 'package:flutter/material.dart';

import '../../resources/colors.dart';

class BottomPadding extends StatelessWidget {
  const BottomPadding({Key? key, this.color = false}) : super(key: key);

  final bool color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ? Colors.white : null,
      padding: EdgeInsets.only(
        top: 20 + 2 //* TabBarParams.padding.top,
      ),
    );
  }
}