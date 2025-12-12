import 'dart:async';

import 'package:flutter/material.dart';
import '../resources/colors.dart';

import '../utils/utils.dart';

import 'package:flutter/painting.dart';

class AppScaffold extends StatefulWidget {
  final bool showAppBar;
  final bool tabBarScroll;
  final double tabFontSize;
  final bool? banniere;
  final bool? showCart;
  final bool showBack;

  final bool? landing;
  final bool? showBurger;
  final bool? showNotif;
  final bool showIcon;
  final bool tabFixed;
  final bool showBackground;
  final Widget? icon;
  final bool appBarColor;
  final Widget? body;
  final String leadingTitle;
  final List<Widget>? tabBarView;
  final Future<void> Function()? refrechPage;
  final List<Widget>? tabs;

  AppScaffold({
    Key? key,
    this.showAppBar = true,
    this.showCart = true,
    this.appBarColor = false,
    this.tabFixed = false,
    this.showIcon = false,
    this.showBackground = false,
    this.icon,
    this.showBack = false,
    this.refrechPage,
    this.banniere = false,
    this.landing = false,
    this.showBurger = true,
    this.showNotif = false,
    this.tabFontSize = 14,
    this.body,
    this.leadingTitle = "",
    this.tabBarView,
    this.tabs,
    this.tabBarScroll = false,
  }) : super(key: key);

  @override
  State<AppScaffold> createState() => _appScaffoldeState();
}

class _appScaffoldeState extends State<AppScaffold> {
  _appScaffoldeState();

  final PageController controller = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double value = 0;
  bool showMenuAn = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: MediaQuery.of(context).size.width,
        elevation: 0,
        toolbarHeight: 80,
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.showBurger == true)
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: DeliveryColors.greenleight,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                if (widget.showBurger == true)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 25,
                      child: Text.rich(
                        TextSpan(
                          text: "Livrer à ",
                          style: TextStyle(fontSize: 16),
                          children: [
                            TextSpan(
                              text:
                                  "${Utils.me?.nom} ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (widget.showBack)
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: DeliveryColors.lightGray,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              if(_scaffoldKey.currentState?.isDrawerOpen == true) {
                                Navigator.of(context).pop();
                              }
                              Navigator.of(context).pop();},
                            icon: Center(
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.black,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        widget.leadingTitle,
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ],
                  ),

              ],
            ),
          ),
        ),
      ),
      backgroundColor: widget.showBackground
          ? DeliveryColors.panierColor
          : Colors.white,
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      if (widget.showBurger == true)
                        SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (widget.showBurger == true)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    height: 30,
                                    child: Text.rich(
                                      TextSpan(
                                        text:
                                            "Bonjour ${Utils.me?.nom ?? ""}, ",
                                        style: TextStyle(fontSize: 16),
                                        children: [
                                          TextSpan(
                                            text: "Chahya Tayba!",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.body is Widget) widget.body!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
