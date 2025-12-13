import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../resources/config.dart';
import '../utils/utils.dart';

class ChantierApi {
  var dio = Dio();

  Future<Response?> getChantier() async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio.get(Config.baseUrl + '/chantiers', data: {}).catchError((
        onError,
      ) {
        print("exceeeppttion chantier $onError");
        return null;
      });
    } catch (error) {
      print("exceeeppttion chantier $error");

      return null;
    }
  }

  Future<Response?> addChantier({String? nom , String? owner , String? adresse , String? date_emission , String? dateecheeance , int? total , String? status}) async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio.post(Config.baseUrl + '/chantiers', data: {
          "nom": nom,
          "owner": owner,
          "address": adresse,
          "date_emission": date_emission,
          "date_echeance": dateecheeance,
          "total": total,
          "status": status

      }).catchError((
          onError,
          ) {
        print("exceeeppttion chantier $onError");
        return null;
      });
    } catch (error) {
      print("exceeeppttion chantier $error");

      return null;
    }
  }
  Future<Response?> getHommes() async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio.get(Config.baseUrl + '/ouvriers', data: {}).catchError((
          onError,
          ) {
        print("exceeeppttion chantier $onError");
        return null;
      });
    } catch (error) {
      print("exceeeppttion chantier $error");

      return null;
    }
  }
  Future<Response?> getMachines() async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio.get(Config.baseUrl + '/machines', data: {}).catchError((
          onError,
          ) {
        print("exceeeppttion chantier $onError");
        return null;
      });
    } catch (error) {
      print("exceeeppttion chantier $error");

      return null;
    }
  }
  Future<Response?> getCamions() async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio.get(Config.baseUrl + '/camions', data: {}).catchError((
          onError,
          ) {
        print("exceeeppttion chantier $onError");
        return null;
      });
    } catch (error) {
      print("exceeeppttion chantier $error");

      return null;
    }
  }
}
