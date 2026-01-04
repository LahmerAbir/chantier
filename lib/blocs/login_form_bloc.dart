import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repository/auth_repository.dart';
import '../utils/utils.dart';

// États du formulaire
abstract class LoginFormState extends Equatable {
  const LoginFormState();
  
  @override
  List<Object?> get props => [];
}

class LoginFormInitial extends LoginFormState {}

class LoginFormLoading extends LoginFormState {}

class LoginFormSuccess extends LoginFormState {}

class LoginFormFailure extends LoginFormState {
  final String error;
  const LoginFormFailure(this.error);
  
  @override
  List<Object?> get props => [error];
}

// Cubit pour gérer la logique
class LoginFormBloc extends Cubit<LoginFormState> {
  final AuthRepository authRepository;
  
  // On garde les valeurs ici (similaire aux TextEditingController mais dans le bloc)
  // Idéalement, on passerait ces valeurs via des events ou state, mais pour une migration simple :
  String username = '';
  String password = '';
  bool stayConnect = true;

  LoginFormBloc({
    required this.authRepository,
  }) : super(LoginFormInitial());

  void updateUsername(String value) {
    username = value;
  }

  void updatePassword(String value) {
    password = value;
  }
  
  void updateStayConnect(bool value) {
    stayConnect = value;
  }

  // Méthode appelée pour pré-remplir (depuis initState de la page)
  void setInitialValues({required String initialUsername, required String initialPassword}) {
    username = initialUsername;
    password = initialPassword;
  }

  Future<void> submit() async {
    if (username.isEmpty || password.isEmpty) {
      emit(const LoginFormFailure("Veuillez remplir tous les champs"));
      // Retour à initial pour permettre de réessayer sans bloquer l'UI
      emit(LoginFormInitial()); 
      return;
    }

    emit(LoginFormLoading());
    
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setBool('stay_connect', stayConnect);

      var response = await authRepository.login(username, password);
      
      if (response != null) {
        Utils.isFirstAccess = null;

        if (stayConnect) {
          await authRepository.stayConnect(response);
          Utils.setMailUser(username);
          Utils.setPasswordUser(password);
        } else {
          Utils.setMailUser(null);
          Utils.setPasswordUser(null);
        }
        
        var me = await Utils.getMeFromShared();
        if (me != null) {
          Utils.isFirstCnx(true);
          Utils.setMe(me);
          Utils.setIdUser(me.id);
          pref.setString("me", jsonEncode(me.toJson()));
        }
        
        emit(LoginFormSuccess());
      } else {
        emit(const LoginFormFailure("Identifiants incorrects"));
        emit(LoginFormInitial());
      }
    } catch (e) {
      print("Login exception: $e");
      emit(const LoginFormFailure("Erreur de connexion"));
      emit(LoginFormInitial());
    }
  }
}
