import 'package:auto_route/auto_route.dart';

import 'bus.dart';

class AppRouterObserver extends AutoRouterObserver {
  @override
  didPop(route, previousRoute) {
    bus.emit(BusEvents.navigationEvent);
  }
}