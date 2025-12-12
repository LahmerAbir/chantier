import 'package:flutter/material.dart';

class RowSpacer extends StatelessWidget {
  final double space;
  final bool withspaceBlack ;

  const RowSpacer({Key? key, this.space = 20 , this.withspaceBlack = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  withspaceBlack ?  Padding(
      padding: const EdgeInsets.only(top : 4.0 , bottom: 4),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 0.5,
        color: Colors.black,
      ),
    ) : Padding(
        padding: EdgeInsets.only(top: space),
         );
  }
}
