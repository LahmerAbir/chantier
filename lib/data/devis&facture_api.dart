import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/document.dart';
import '../resources/config.dart';
import '../utils/utils.dart';

class FactureApi {
  var dio = Dio();

  Future<Response?> getFactures() async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio.get(Config.baseUrl + '/factures', data: {}).catchError((
        onError,
      ) {
        print("exceeeppttion factures $onError");
        return null;
      });
    } catch (error) {
      print("exceeeppttion factures $error");

      return null;
    }
  }
  Future<Response?> editFactures({int? id ,   String? reference,
    String? date,
    int? client_id,
    int? total_ht,
    int? total_ttc,
    int? montant_paye,
    String? status,
    String? notes,
    List<Article>? articles ,}) async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio.put(Config.baseUrl + '/factures/$id', data: {
        "reference": reference,
        "client_id": client_id,
        "date": date,
        "status" : status,

        "tva": 20,
        "lignes": articles ?? []

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
  Future<Response?> addFactures({  String? reference,
    String? date,
    int? client_id,
    int? total_ht,
    int? total_ttc,
    int? montant_paye,
    String? status,
    String? notes,
    List<Article>? articles ,}) async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio.post(Config.baseUrl + '/factures', data: {
        "reference": reference,
        "client_id": client_id,
        "date": date,
        "status" : status,

        "tva": 20,
        "lignes": articles ?? []

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
