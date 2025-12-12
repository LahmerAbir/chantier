import 'package:auto_route/auto_route.dart';

import 'package:flutter/material.dart';

import '../pages/dashboard.dart';
import '../pages/login.dart';
import '../pages/splash_screen_view.dart';




part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  factory AppRouter() => AppRouter.instance;

  @override
  List<AutoRoute> get routes => [
 //   AutoRoute(page: SplashScreenRoute.page, initial: true),
   // AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: HomeRoute.page),
    CustomRoute(
      page: LoginRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      durationInMilliseconds: 650,
    ),
    CustomRoute(
      page: SplashScreenRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      durationInMilliseconds: 650,
        initial: true
    ),
  ];

  AppRouter._()
    : super(
        navigatorKey: GlobalKey<NavigatorState>(),
        // anonymousGuard: AnonymousGuard(),
      ) {}

  static final instance = AppRouter._();

  final Map<String, String> deepPaths = {};
}
