import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'col_spacer.dart';
 enum Borderside  {symetric , all , }
class BorderContainer extends StatelessWidget {
  final IconData? icon;
  final IconData? lasticon;
  final String? title;
  final String? route;
  final double? padding;
  final Widget? widget;
  final Borderside? borderside;
  final Color? color;
  final Color? colorIcon;
  final Color? labelcolor;
  final double? margin;

  const BorderContainer({Key? key, this.labelcolor ,this.title,this.icon, this.route, this.padding , this.colorIcon , this.lasticon, this.widget, this.borderside= Borderside.symetric, this.color, this.margin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: margin ?? 0),
      padding: EdgeInsets.symmetric(vertical:  15, horizontal: padding ?? 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget ??
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
          Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon , color: colorIcon,))),
            ColSpacer(space: 5,),
              SizedBox(
                child: Text(title ?? "", style:   TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: labelcolor ?? Colors.black),
                ),
              ),
            ],
          ),

          lasticon != null ?  Icon(lasticon , color: Colors.grey, ) : Container(),
        ],
      ),
    );
  }
}
