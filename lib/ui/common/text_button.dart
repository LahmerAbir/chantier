
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../resources/colors.dart';


class TextButtonControl extends StatelessWidget {
  final String? text;
  final Color? color;
  final VoidCallback? onPressed;
  final TextAlign? align;
  final FontWeight? fontWeight;
  final bool? underline;
  final double? fontSize;

  const TextButtonControl({Key? key, this.color , this.text, this.onPressed, this.align, this.underline = false, this.fontWeight, this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed is Function ? () {
          onPressed?.call();
      } : null,
      child: Text(
        text ?? "",
        style: GoogleFonts.montserrat(
          color: color ?? DeliveryColors.gray,
          decoration: underline == true ? TextDecoration.underline : TextDecoration.none,
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight ?? FontWeight.w600,
          letterSpacing: 1.05,
        ),
        textAlign: align
      ),
    );
  }
}
