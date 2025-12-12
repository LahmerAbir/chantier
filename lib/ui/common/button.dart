import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../resources/colors.dart';
import 'col_spacer.dart';
import 'loading.dart';

class FormButton extends StatelessWidget {
  final String? label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final double elevated;
  final double height;
  final double? width;
  final double? textwidth;
  final double radius;
  final double? labelSize;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color primary;
  final Color onPrimary;
  final EdgeInsets padding;
  final Color? labelColor;
  final FontWeight? fontWeight;
  final TextStyle? textStyle ;

  FormButton({
    Key? key,
    //  String? formControlName,
    this.label,
    this.onPressed,
    this.width = double.infinity,
    this.textwidth,
    this.loading = false,
    this.outlined = false,
    this.elevated = 0,
    this.height = 50,
    this.radius = 10,
    this.prefixIcon,
    this.labelSize = 16,
    this.fontWeight,
    this.suffixIcon,
    this.textStyle ,
    this.primary = DeliveryColors.red,
    this.onPrimary = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
    this.labelColor= Colors.white,
  }) : super(
          key: key,
          //   formControlName: formControlName,
        );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: TextButton(
        style: outlined
            ? OutlinedButton.styleFrom(
                backgroundColor: primary,
          elevation: elevated,
                side: BorderSide(color: onPrimary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(radius))),
              )
            : ElevatedButton.styleFrom(
                backgroundColor: primary,
                // onPrimary: onPrimary,
                elevation: elevated,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(radius))),
              ),
        onPressed: onPressed is Function
            ? () {
                if (!loading) {
                  onPressed?.call();
                }
              }
            : null,
        child: Container(
          padding: padding,
          child: loading
              ? Loader(light: !outlined, colors: [Colors.white],)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (prefixIcon is Widget) ...[
                      prefixIcon!,

                    ],
                    SizedBox(
                      width: textwidth,
                      child: Center(
                        child: AutoSizeText(
                          label ?? 'Submit',
                          textAlign : TextAlign.center,
                          softWrap: true,
                          minFontSize: 5,
                          maxFontSize: labelSize ?? 16,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle ?? GoogleFonts.inter(
                              fontSize: labelSize,
                              fontWeight: fontWeight ?? FontWeight.w600,
                              letterSpacing: 1.0,
                              color: labelColor),
                          maxLines: 3,
                        ),
                      ),
                    ),
                    if (suffixIcon is Widget) ...[
                      const ColSpacer(space: 5),
                      suffixIcon!,
                    ]
                  ],
                ),
        ),
      ),
    );
  }
}
