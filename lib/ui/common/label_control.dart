import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../resources/colors.dart';



class FormControlLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const FormControlLabel(this.text,{this.color,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 5, bottom: 5, left: 5,top: 5),
      child: Text(
        text,
        style:  GoogleFonts.montserrat(
          fontSize: 14,
          color: DeliveryColors.black,
        ),
      ),
    );
  }
}