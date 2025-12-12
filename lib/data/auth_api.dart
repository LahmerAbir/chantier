import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../resources/config.dart';
import '../utils/utils.dart';

class AuthApi {
  var dio = Dio();

  Future<Response?> login(
    String username,
    String password,
  ) async {
    dio.options.headers['Content-Type'] = "Application/json";
    print(Config.baseUrl + '/auth/login');
    print(username + password);

    try {
      return await dio.post(Config.baseUrl + '/auth/login', data: {
        "email": username,
        "password": password,

      }).catchError((onError) {
        print("exceeeppttion login $onError");

        return null;
      });
    } catch (error) {
      print("exceeeppttion login $error");

      return null;
    }
  }





  Future<Response?> getMe() async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer $token";
    try {
      return await dio.get('${Config.baseUrl}/users/me');
    } catch (e) {
      return null;
    }
  }




  Future<Response?> putProfil(
      {String? firstName,
      String? lastName,
      String? gsm,
      String? gouv,
      String? email}) async {
    var token = await Utils.getToken();

    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer $token";
    try {
      return await dio.put('${Config.baseUrl}/user', data: {
        "firstname": firstName,
        "lastname": lastName,
        "phone": gsm,
        "mail": email,
      });
    } catch (e) {
      return null;
    }
  }

  Future<Response?> logOut(String? token) async {
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer $token";
    try {
      return await dio.delete('${Config.baseUrl}/sanctum/token');
    } catch (e) {
      return null;
    }
  }


}


