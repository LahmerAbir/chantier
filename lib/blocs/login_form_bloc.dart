import 'dart:convert';

 
import 'package:flutter_form_bloc_plus/flutter_form_bloc_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repository/auth_repository.dart';
import '../utils/utils.dart';


class LoginFormBloc extends FormBloc<String, String> {
  final AuthRepository authRepository;
  final username = TextFieldBloc(
    validators: [
      Utils.required,
     // _checkEmail
    ],
  );

  final password = TextFieldBloc(
    validators: [
      Utils.required,
    ],
  );

  final stayConnect = BooleanFieldBloc(initialValue: true);
  LoginFormBloc({
    required this.authRepository,
  }) {
    addFieldBlocs(
      fieldBlocs: [
        username,
        password,
        stayConnect,
      ],
    );

  }




  @override
  void onSubmitting() async {
    emitLoading();
    SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setBool('stay_connect', stayConnect.value);

    try{
   var response = await authRepository.login(username.value, password.value);
    print(response.toString());
    if (response != null) {
      Utils.isFirstAccess = null;

      if (stayConnect.value == true) {
        await authRepository.stayConnect(response);
        Utils.setMailUser(username.value);
        Utils.setPasswordUser(password.value);
      } else {
        Utils.setMailUser(null);
        Utils.setPasswordUser(null);
      }
      var me = await Utils.getMeFromShared();
      if (me != null) {
        Utils.isFirstCnx(true);
        SharedPreferences pref = await SharedPreferences.getInstance();
        Utils.setMe(me);
        Utils.setIdUser(me.id);
        pref.setString("me", jsonEncode(me.toJson()));
      }
      emitSuccess();
    }  else {
    print("emitFailure");
    emitFailure();
    }
    }catch(e){
      print("exception $e");
      emitFailure();
    }

  }
}
