import 'package:auto_route/auto_route.dart';

import 'app_router.dart';

abstract class AuthRelatedGuard extends AutoRouteGuard {}
 /* bool isAuthenticated(NavigationResolver resolver, StackRouter router) {
    final context = router.root.navigatorKey.currentContext;
    final authRepository = context?.read<AuthRepository>();
    print(authRepository?.getToken());

    return authRepository?.getToken()?.isNotEmpty == true;
  }
}

class AuthenticatedGuard extends AuthRelatedGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (isAuthenticated(resolver, router)) {
      return resolver.next(true);
    }

    router.navigate(LoginRoute(onSuccess: () {
      router.popUntil((route) => false);
      resolver.next(true);
    }));
  }
}

class AnonymousGuard extends AuthRelatedGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (isAuthenticated(resolver, router)) {
      router.navigate(const LayoutRoute());
      return resolver.next(false);
    }
    return resolver.next(true);
  }
}*/
