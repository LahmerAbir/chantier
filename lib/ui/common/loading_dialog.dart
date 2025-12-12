import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../resources/colors.dart';

class LoadingDialog extends StatelessWidget {
  final double height;
  final double width;
  final bool light;
  final String? text;

   LoadingDialog({
    Key? key,
    this.height = 80,
    this.width = 80,
    this.text,
    this.light = false,
  }) : super(key: key);

   static void show(BuildContext context,{String? text, Key? key, bool root = true}) => showDialog<void>(
    context: context,
    useRootNavigator: root,
    builder: (_) => LoadingDialog(key: key, text: text,),
  ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.of(context, rootNavigator: true).pop();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: width,
                height: height ,
                padding: const EdgeInsets.all(12.0),
                child:  LoadingIndicator(
                  indicatorType: Indicator.lineSpinFadeLoader,
                  colors: [DeliveryColors.gray],
                )
            ),
            Text(text ?? "", style: TextStyle(color: Colors.white),)
          ],
        ),
      ),
    );
  }
}

