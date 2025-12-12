import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_units/responsive_units.dart';
import '../../resources/colors.dart';
import '../../resources/images.dart';
import '../../resources/styles.dart';
import '../../utils/utils.dart';
import 'col_spacer.dart';

class IconContainer extends StatelessWidget {
  final String title;
  final Widget? icon;
  final Color? color;
  final double? width;
  final DeliveryImage? image;
  const IconContainer(
      {Key? key,
      this.icon,
      this.width,
      required this.title,
      this.color,
      this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color ?? Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (icon != null || image != null)
            if (icon is Widget) icon ?? Container(),
          if (image is DeliveryImage)
            Image.asset(
              color: DeliveryColors.blue,
              Utils.getImagePath(image!),
            ),
          ColSpacer(
            space: 10,
          ),
          Text(
            title,
            // textAlign: TextAlign.center,
            style: DeliveryTextStyle.title1Style,
          ),
        ],
      ),
    );
  }
}
