import 'dart:async';
import 'dart:convert';


import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_response.dart';
import '../repository/auth_repository.dart';
import '../resources/images.dart';

abstract class Utils {
  static String? token;
  static String? cache;
  static String? idUser;
  static String? idVerification;
  static String? idOrdreEncours;
  static bool? isFirstAccess;
  static UserRes? me;
  static String? status;

  static ValueNotifier<int> totalItems = ValueNotifier<int>(0); // <-- this one





  static String getImagePath(DeliveryImage image, {String format = 'png'}) {
    return 'assets/${image.name}.$format';
  }

  static Future<String> getConst() async {
    var res = await AuthRepository().getConst();
    return res ?? "";
  }

  static String? emailSingUp(String? string) {
    final emailRegExp =
        RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
    if (string == null || string.isEmpty || emailRegExp.hasMatch(string)) {
      return null;
    }
    return 'Adresse e-mail invalide';
  }

  static Future<bool?> getFromPreference() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool('isFirst');
  }

  static String? getCache() {
    return cache;
  }

  static void setCache(String? cache) {
    Utils.cache = cache;
  }


  static void setIdUser(String? id) {
    Utils.idUser = id;
  }

  static Future<String?> getMailUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('mail');
  }

  static Future<void> setMailUser(String? mail) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('mail', mail ?? "");
  }

  static Future<String?> getStatusUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('status');
  }

  static Future<void> setStatusUser(String? status) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('status', status ?? "");
  }




  static Future<String?> getPasswordlUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('password');
  }

  static Future<void> setPasswordUser(String? password) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('password', password ?? "");
  }

  static Future<bool?> checkIsfirstCnx() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool('isFirstCnx');
  }

  static Future<void> isFirstCnx(bool value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool('isFirstCnx', value);
  }

  static Future<String?> getToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var t = pref.getString('token');
    token = t;
    return t;
  }

  static String? getTokenStatic() {
    return token;
  }


  static Future<void> setToken(String? token) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('token', token ?? "");
    Utils.token = token;
  }

  static Future<void> setMe(UserRes? me) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(me != null)
    pref.setString("me", jsonEncode(me?.toJson()));
    else
    pref.setString("me", "null");
    Utils.me = me;
  }

  static UserRes? getMe() {
    return me;
  }
  static Future<UserRes?> getMeFromShared() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final String? userJson = pref.getString("me");

    UserRes? meShared;
    if (userJson != null) {
      if (userJson != "null") {
        final Map<String, dynamic> data = jsonDecode(userJson);
        meShared = UserRes.fromJson(data);
      }
      Utils.me = meShared;
      return meShared;
    }else
      return null;

  }

  static Future<bool?> getIsFirst() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var data = pref.getBool('isFirst');
    return data;
  }
  static Future<void> setisFirst(bool? isFirst) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool('isFirst', isFirst ?? false);
  }
  static Future<String?> getCachedToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var data = pref.getString('connected_user');
    setCache(data);
    return data;
  }

  static Map<String, String> headers() => {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer ${getTokenStatic() ?? ""}',
      };



  static String? required(String? value) {
    if (value != null && value.isNotEmpty) {
      return null;
    }
    return 'Ce champ est requis';
  }

}
