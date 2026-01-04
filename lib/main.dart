import 'dart:async';

import 'package:chantier/blocs/art_form_bloc.dart';
import 'package:chantier/blocs/camion_form_bloc.dart';
import 'package:chantier/blocs/client_form_bloc.dart';
import 'package:chantier/blocs/document_form_bloc.dart';
import 'package:chantier/blocs/homme_form_bloc.dart';
import 'package:chantier/blocs/mat_form_bloc.dart';
import 'package:chantier/repository/auth_repository.dart';
import 'package:chantier/router/app_router.dart';
import 'package:chantier/router/app_router_observer.dart';
import 'package:chantier/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'blocs/login_form_bloc.dart';
import 'main.data.dart';

final router = AppRouter().delegate(
  navigatorObservers: () => [AppRouterObserver()],
);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded(() async {
    // Init timezone APRÈS Flutter
    tz.initializeTimeZones();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final authRepository = AuthRepository();
    await Utils.getToken();

    Bloc.observer = AppBlocObserver();

    runApp(
      ProviderScope(
        overrides: [
          configureRepositoryLocalStorage(),
        ],
        child: BatiProApp(authRepository: authRepository),
      ),
    );
  }, (error, stack) {
    // En Release iOS, print ne sert à rien
    // mais on évite le crash silencieux
    debugPrint('ZONE ERROR: $error');
  });
}

class BatiProApp extends ConsumerWidget {
  BatiProApp(
      {super.key , required this.authRepository,});

  AuthRepository authRepository = AuthRepository();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: authRepository),
        ],
        child: MultiBlocProvider(
            providers: [
              BlocProvider<LoginFormBloc>(
                  create: (BuildContext context) =>
                      LoginFormBloc(authRepository : authRepository)),
              BlocProvider<DocumentFormBloc>(
                  create: (BuildContext context) =>
                      DocumentFormBloc()),
              BlocProvider<ClientFormBloc>(
                  create: (BuildContext context) =>
                      ClientFormBloc()),
              BlocProvider<ArticleFormBloc>(
                  create: (BuildContext context) =>
                      ArticleFormBloc()),
              BlocProvider<MaterielFormBloc>(
                  create: (BuildContext context) =>
                      MaterielFormBloc()),
              BlocProvider<CamionFormBloc>(
                  create: (BuildContext context) =>
                      CamionFormBloc()),
              BlocProvider<HommeFormBloc>(
                  create: (BuildContext context) =>
                      HommeFormBloc()),
            ],
            child: ref.watch(repositoryInitializerProvider).when(
                error: (error, _) => Container(),
                loading: () => Container(),
                data: (_) {
                  return MaterialApp.router(
                    routeInformationParser: AppRouter().defaultRouteParser(),
                    routerDelegate: router,
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData(
                      brightness: Brightness.light,
                      dividerColor: Colors.white,
                      /* textTheme: GoogleFonts.montserratTextTheme(
                       Theme.of(context).textTheme,
                             ),*/
                      // add tabBarTheme
                    ),
                    builder: (context, child) {
                      return Scaffold(
                        backgroundColor: Colors.white,
                        body: SafeArea(
                          child: child!,
                        ),
                      );
                    },
                  );
                })));
  }
}

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) print(change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}


