import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_bloc_plus/flutter_form_bloc_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../resources/colors.dart';
import 'label_control.dart';

class TextFormControl extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final String? label;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final bool autofocus;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final SuffixButton? suffixButton;
  final bool readOnly;
  final VoidCallback? onTap;
  final double fontSize;
  final EdgeInsetsGeometry contentPadding;
  final TextFieldBloc textFieldBloc;
  final Iterable<String>? autofillHints;
  final bool? obscureText;
  final bool? border;
  final EdgeInsetsGeometry padding;
  final Color fillColor;
  final bool? codeVile;
  final Widget widget;
  final FocusNode? focusNode;

  TextFormControl({
    Key? key,
    this.hintText,
    this.codeVile = false,
    this.widget = const CircularProgressIndicator(
      strokeWidth: 2,
      color: DeliveryColors.black,
    ),
    this.obscureText,
    this.labelText,
    this.label,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.autofocus = false,
    this.suffixIcon,
    this.suffixButton,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.border = true,
    this.fontSize = 16,
    this.autofillHints,
    this.padding = EdgeInsets.zero,
    this.fillColor = Colors.white,
    required this.textFieldBloc,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (labelText != null) FormControlLabel(labelText!),

          TextFieldBlocBuilder(
            asyncValidatingIcon: Container(
              height: 15,
              width: 15,
              padding: const EdgeInsets.all(12),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: DeliveryColors.black,
              ),
            ),
            textFieldBloc: textFieldBloc,
            autofillHints: autofillHints,
            keyboardType: keyboardType,
            suffixButton: suffixButton,
            obscureText: obscureText,
            nextFocusNode : focusNode,

            textStyle:
                GoogleFonts.inter(fontSize: fontSize, letterSpacing: 0.2),
            textColor: MaterialStateProperty.all(DeliveryColors.black),
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              labelStyle:  GoogleFonts.inter(color: DeliveryColors.inputBorder, fontSize: fontSize),
              fillColor: readOnly ? DeliveryColors.background : fillColor,
              errorBorder: border == true
                  ? const OutlineInputBorder(
                      borderSide: BorderSide(color: DeliveryColors.errorBorder),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )
                  : const OutlineInputBorder(
                      borderSide: BorderSide(color: DeliveryColors.errorBorder),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
              focusedErrorBorder: border == true
                  ? const OutlineInputBorder(
                      borderSide: BorderSide(color: DeliveryColors.errorBorder),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )
                  : const OutlineInputBorder(
                      borderSide: BorderSide(color: DeliveryColors.errorBorder),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
              enabledBorder: border == true
                  ? const OutlineInputBorder(
                      borderSide: BorderSide(color: DeliveryColors.inputBorder),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )
                  : const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
              focusedBorder: border == true
                  ? OutlineInputBorder(
                      borderSide: readOnly
                          ? BorderSide.none
                          : BorderSide(color: DeliveryColors.gray),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )
                  : const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
              hintText: hintText,
              //focusColor: Colors.black,
              labelText: label,
              floatingLabelStyle: TextStyle(color: DeliveryColors.gray),
              alignLabelWithHint: false,
              isDense: false,
              isCollapsed: false,
              filled: true,
              //prefixIcon:  prefixIcon,
              suffixIcon: suffixIcon,
              contentPadding: contentPadding,
            ),
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            autofocus: autofocus,
            inputFormatters: inputFormatters,
            //cursorColor: GiasColors.black,
          ),
        ],
      ),
    );
  }
}
