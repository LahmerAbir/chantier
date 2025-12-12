import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_units/responsive_units.dart';

import 'colors.dart';

class DeliveryTextStyle {
  static TextStyle get title1Style =>
      GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: DeliveryColors.green
      );
  static TextStyle get title1StyleBlack =>
      GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: DeliveryColors.black
      );
}