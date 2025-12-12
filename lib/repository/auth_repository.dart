import 'package:shared_preferences/shared_preferences.dart';

import '../data/auth_api.dart';
import '../model/AuthResponse.dart';
import '../model/user_response.dart';
import '../utils/utils.dart';

class AuthRepository {
  final authApi = AuthApi();
  String? token;
  String? role;

  Future<UserRes?> me() async {
    final response = await authApi.getMe();
    if (response != null) {
      var me = UserRes.fromJson(response.data);
      Utils.setMe(me);
      return me;
    }
    return null;
  }

  Future<String?> getConst() async {
    final response = await authApi.getMe();
    if (response != null) {
      return response.data;
    }
    return null;
  }

  Future<UserRes?> putProfil(
      {String? id,String? firstName, String? lastName, String? email, String? gouv,String? gsm}) async {
    final response = await authApi.putProfil(
        firstName: firstName, lastName: lastName,gsm: gsm,gouv:gouv, email: email);
    if (response != null) {
      var me = UserRes.fromJson(response.data);
      return me;
    }
    return null;
  }



  Future<void> stayConnect(String? token) async {
    final pref = await SharedPreferences.getInstance();
    if (token != null) {
      pref.setString('connected_user', token);

      Utils.setCache(token);
    }
  }

  Future<String?> login(
    String username,
    String password,
  ) async {
    try {
      final resp = await authApi.login(username, password);
      if (resp != null) {
        if (resp.statusCode == 200) {
          var response = AuthResp.fromJson(resp.data);
          print('token' + response.toString());
          token = response?.data?.session?.accessToken ?? "";
          await Utils.setToken(token ?? "");
          var me = response.data?.user;
          await  Utils.setMe(me);

          return token;
        } else {
          return null;

        }
      }
      return null;
    } catch (e) {
      print("exceeeppttion login $e");
      return null;
    }
  }





  Future<bool> logout() async {
    final response = await authApi.logOut(Utils.token);
    if (response != null && response.statusCode == 200) {
      token = null;
      Utils.setToken(null);
      Utils.setMe(null);
      Utils.setCache(null);
      final pref = await SharedPreferences.getInstance();
      pref.remove('connected_user');
      return true;
    } else {
      return false;
    }
  }


}
