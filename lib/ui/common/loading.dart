import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../resources/colors.dart';


class Loader extends StatelessWidget {
  final Size size;
  final bool light;
  final Indicator? indicatorType;
  final List<Color>? colors;
  final double? strokeWidth;

  const Loader({
    Key? key,
    this.size = const Size.square(56),
    this.light = false,
    this.indicatorType,
    this.colors,
    this.strokeWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
          size: size,
          child: Transform.rotate(
            angle: pi,
            child: LoadingIndicator(
              
              indicatorType: indicatorType ?? Indicator.ballPulse,
              colors: colors ?? [DeliveryColors.gray],
              backgroundColor: Colors.transparent,
              strokeWidth: strokeWidth,
            ),
          )),
    );
  }
}