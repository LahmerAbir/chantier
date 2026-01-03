import 'package:auto_route/annotations.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_units/responsive_units.dart';

import '../blocs/login_form_bloc.dart';

import '../repository/auth_repository.dart';
import '../resources/colors.dart';
import '../resources/images.dart';
import '../resources/strings.dart';
import '../resources/styles.dart';
import '../router/app_router.dart';
import 'package:auto_route/auto_route.dart';

import '../ui/common/button.dart';
import '../ui/common/loading_dialog.dart';
import '../ui/common/row_spacer.dart';
import '../ui/common/text_button.dart';
import '../ui/common/text_control.dart';
import '../ui/common/unfocusKeybord.dart';
import '../utils/utils.dart';
import 'package:flutter/foundation.dart';
@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.onSuccess, this.padding = true})
    : super(key: key);

  final Function? onSuccess;
  final bool? padding;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? mail;
  String? password;
  bool isFirst = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var email = await Utils.getMailUser();
      var pwd = await Utils.getPasswordlUser();
      setState(() {
        mail = email;
        password = pwd;
      });
    });
    super.initState();
  }
  double? horizontalPadding;


  @override
  Widget build(BuildContext context) {

    return UnfocusKeyboard(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Container(
        decoration:   BoxDecoration(
          ),
          height: MediaQuery.of(context).size.height,
          child: loginForm(context),
        ),
      ),
    );
  }

  Widget loginForm(BuildContext context) {
    var authRepository = context.read<AuthRepository>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    // Détection de la plateforme d'exécution
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      horizontalPadding =  9;
    }
    else
      {
        horizontalPadding =  screenWidth*0.35;


      }
    return BlocProvider(
      create: (context) => LoginFormBloc(authRepository: authRepository),
      child: Builder(
        builder: (context) {
          final loginFormBloc = context.read<LoginFormBloc>();
          if (isFirst) {
            if (mail != null && password != null) {
              if (mail!.isNotEmpty && password!.isNotEmpty) {
                isFirst = false;
                loginFormBloc.password.updateInitialValue(password!);
                loginFormBloc.username.updateInitialValue(mail!);
              }
            }
          }
          return FormBlocListener<LoginFormBloc, String, String>(
            onLoading: (context, state) {
              LoadingDialog.show(context, root: false);
            },
            onSuccess: (context, state) async {
              LoadingDialog.show(context, root: false);

              widget.onSuccess?.call();
              Utils.getFromPreference();
              Utils.checkIsfirstCnx();
              Utils.isFirstCnx(true);
              LoadingDialog.hide(context);
           context.router.replaceAll([HomeRoute()]);
              return;
            },
            onFailure: (context, state) {
              print("");
              LoadingDialog.hide(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Identifiants non correctes'),
                ),
              );

              // Navigator.of(context, rootNavigator: true).pop();
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding! , vertical: defaultTargetPlatform == TargetPlatform.android ||
                  defaultTargetPlatform == TargetPlatform.iOS ? 15 : screenheight *0.1),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Hero(
                        tag: 'logo_hero_tag', // Tag UNiQUE pour la transition
                      child: Image(
                        image: AssetImage(Utils.getImagePath(DeliveryImage.logo)),
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      children: [
                        Text(
                          "Bienvenue",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                            color: DeliveryColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _form(context, loginFormBloc),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


Widget _form(BuildContext context, LoginFormBloc loginFormBloc) {


  return Column(
      children: [
        TextFormControl(
          textFieldBloc: loginFormBloc.username,
          suffixButton: SuffixButton.asyncValidating,
          keyboardType: TextInputType.emailAddress,
          label: "Email",

        ),
        TextFormControl(
          textFieldBloc: loginFormBloc.password,
          suffixButton: SuffixButton.obscureText,
          label: "Mot de passe",
        ),
        GestureDetector(
          onTap: () {
            loginFormBloc.stayConnect.updateValue(
              !loginFormBloc.stayConnect.value,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150.sp,
                child: CheckboxFieldBlocBuilder(
                  padding: const EdgeInsets.only(left: 0, right: 0),
                  overlayColor: MaterialStateProperty.all<Color>(
                    Colors.black,
                  ),
                  fillColor: MaterialStateProperty.all<Color>(Colors.grey),
                  checkColor: MaterialStateProperty.all<Color>(Colors.black),
                  side: BorderSide(color: Colors.black),
                  textColor: MaterialStateProperty.all<Color>(Colors.black),
                  booleanFieldBloc: loginFormBloc.stayConnect,
                  controlAffinity: FieldBlocBuilderControlAffinity.leading,
                  body: Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: Text(
                      'Rester connecté',
                      style: GoogleFonts.inter(fontSize: 10),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
        RowSpacer(),
        FormButton(
          labelColor: Colors.white,
          width: double.infinity,
          onPressed: () async {
            loginFormBloc.submit();
          },
          primary: DeliveryColors.gray,
          radius: 15,
          label: 'Connexion',
        ),

        RowSpacer(),
      ],
    );
}
