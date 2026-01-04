import 'package:auto_route/annotations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_units/responsive_units.dart';
import 'package:auto_route/auto_route.dart';

import '../blocs/login_form_bloc.dart';
import '../repository/auth_repository.dart';
import '../resources/colors.dart';
import '../resources/images.dart';
import '../router/app_router.dart';

import '../ui/common/button.dart';
import '../ui/common/loading_dialog.dart';
import '../ui/common/row_spacer.dart';
import '../ui/common/unfocusKeybord.dart';
import '../utils/utils.dart';

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
  // Controleurs pour les champs texte
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool isFirst = true;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var email = await Utils.getMailUser();
      var pwd = await Utils.getPasswordlUser();
      
      if (email != null) _usernameController.text = email;
      if (pwd != null) _passwordController.text = pwd;
      
      // Mise à jour de l'état local pour rafraîchir l'UI si nécessaire
      if (mounted) setState(() {});
    });
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: UnfocusKeyboard(
        child: Container(
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

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      horizontalPadding = 9;
    } else {
      horizontalPadding = screenWidth * 0.35;
    }
    
    return BlocProvider(
      create: (context) {
        final bloc = LoginFormBloc(authRepository: authRepository);
        // Initialiser le bloc avec les valeurs récupérées si disponibles
        if (_usernameController.text.isNotEmpty) {
          bloc.updateUsername(_usernameController.text);
          bloc.updatePassword(_passwordController.text);
        }
        return bloc;
      },
      child: BlocConsumer<LoginFormBloc, LoginFormState>(
        listener: (context, state) {
          if (state is LoginFormLoading) {
            LoadingDialog.show(context, root: false);
          } else if (state is LoginFormSuccess) {
            LoadingDialog.hide(context);
            widget.onSuccess?.call();
            Utils.getFromPreference();
            Utils.checkIsfirstCnx();
            Utils.isFirstCnx(true);
            context.router.replaceAll([HomeRoute()]);
          } else if (state is LoginFormFailure) {
            LoadingDialog.hide(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.error),
              ),
            );
          }
        },
        builder: (context, state) {
          final loginBloc = context.read<LoginFormBloc>();
          
          // Mise à jour des valeurs du bloc à chaque changement de texte
          // On peut aussi le faire via onChanged dans les champs
          
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding!,
                vertical: defaultTargetPlatform == TargetPlatform.android ||
                        defaultTargetPlatform == TargetPlatform.iOS
                    ? 15
                    : screenheight * 0.1),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Hero(
                    tag: 'logo_hero_tag',
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
                _form(context, loginBloc),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 1.5),
      ),
    );
  }

  Widget _form(BuildContext context, LoginFormBloc loginFormBloc) {
    return Column(
      children: [
        TextFormField(
          controller: _usernameController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.black),
          decoration: _inputDecoration(hintText: "Email"),
          onChanged: (value) => loginFormBloc.updateUsername(value),
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: const TextStyle(color: Colors.black),
          decoration: _inputDecoration(
            hintText: "Mot de passe",
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          onChanged: (value) => loginFormBloc.updatePassword(value),
        ),
        GestureDetector(
          onTap: () {
            // Mettre à jour l'état local et le bloc
            setState(() {
              loginFormBloc.updateStayConnect(!loginFormBloc.stayConnect);
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: loginFormBloc.stayConnect,
                    onChanged: (bool? value) {
                      setState(() {
                        loginFormBloc.updateStayConnect(value ?? false);
                      });
                    },
                    checkColor: Colors.white,
                    activeColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Rester connecté',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        FormButton(
          labelColor: Colors.white,
          width: double.infinity,
          onPressed: () {
            // Mise à jour finale avant submit pour être sûr
            loginFormBloc.updateUsername(_usernameController.text);
            loginFormBloc.updatePassword(_passwordController.text);
            loginFormBloc.submit();
          },
          primary: DeliveryColors.gray,
          radius: 15,
          label: 'Connexion',
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
