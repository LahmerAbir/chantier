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
  Future<Response?> getChantierById(int? id) async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio.get(Config.baseUrl + '/chantiers/$id', data: {}).catchError((
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


  Future<Response?> getClients() async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio.get(Config.baseUrl + '/clients', data: {}).catchError((
        onError,
      ) {
        print("exceeeppttion clients $onError");
        return null;
      });
    } catch (error) {
      print("exceeeppttion clients $error");

      return null;
    }
  }

  Future<Response?> addClient({
    String? nom,
    String? email,
    String? adresse,
    String? telephone,
    String? ville,
    String? pays,
  }) async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio
          .post(
            Config.baseUrl + '/clients',
            data: {
              "nom": nom,
              "email": email,
              "telephone": telephone,
              "adresse": adresse,
              "ville": ville,
              "pays": pays,
            },
          )
          .catchError((onError) {
            print("exceeeppttion client $onError");
            return null;
          });
    } catch (error) {
      print("exceeeppttion chantier $error");

      return null;
    }
  }

  Future<Response?> editChantier({
    int? id,
    String? nom,
    String? owner,
    String? adresse,
    String? description,
    String? date_emission,
    String? dateecheeance,
    int? total,
    String? status,
    String? remarque,
    List<int>? ouvrier_ids,
    List<int>? machine_ids,
    List<int>? camion_ids,
  }) async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio
          .put(
            Config.baseUrl + '/chantiers/$id',
            data: {
              "nom": nom,
              "owner": owner,
              "description": description,
              "address": adresse,
              "date_emission": date_emission,
              "date_echeance": dateecheeance,
              "total": total,
              "status": status,
              "remarque": remarque,

            if(ouvrier_ids != null) if(ouvrier_ids.isNotEmpty) "ouvrier_ids":ouvrier_ids ?? [],
              if(machine_ids != null) if(machine_ids.isNotEmpty)   "machine_ids": machine_ids ?? [],
              if(camion_ids != null) if(camion_ids.isNotEmpty)   "camion_ids":camion_ids ?? []
            },
          )
          .catchError((onError) {
            print("exceeeppttion chantier $onError");
            return null;
          });
    } catch (error) {
      print("exceeeppttion chantier $error");

      return null;
    }
  }

  Future<Response?> addChantier({
    String? nom,
    String? owner,
    String? description,
    String? adresse,
    String? date_emission,
    String? dateecheeance,
    int? total,
    String? status,
    List<int>? ouvrier_ids,
    List<int>? machine_ids,
    List<int>? camion_ids,
  }) async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio
          .post(
            Config.baseUrl + '/chantiers',
            data: {
              "nom": nom,
              "owner": owner,
              "description": description,
              "address": adresse,
              "date_emission": date_emission,
              "date_echeance": dateecheeance,
              "total": total,
              "status": status,
              "ouvrier_ids":ouvrier_ids ?? [],
              "machine_ids": machine_ids ?? [],
              "camion_ids":camion_ids ?? []
            },
          )
          .catchError((onError) {
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

  Future<Response?> addHomme({
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? specialite,
  }) async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio
          .post(
            Config.baseUrl + '/ouvriers',
            data: {
              "nom": nom,
              "prenom": prenom,
              "email": email,
              "telephone": telephone,
              "specialite": specialite,
              "cout_journalier": 185,
              "status": "actif",
            },
          )
          .catchError((onError) {
            print("exceeeppttion client $onError");
            return null;
          });
    } catch (error) {
      print("exceeeppttion chantier $error");

      return null;
    }
  }

  Future<Response?> addCamion({
    String? nom,
    String? capacite,
    String? matricule,
    int? cout_journalier,
  }) async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio
          .post(
            Config.baseUrl + '/camions',
            data: {
              "nom": nom,
              "matricule": matricule,
              "capacite": capacite,
              "cout_journalier": 100,
              "status": "disponible",
            },
          )
          .catchError((onError) {
            print("exceeeppttion client $onError");
            return null;
          });
    } catch (error) {
      print("exceeeppttion chantier $error");

      return null;
    }
  }

  Future<Response?> addMat({
    String? nom,
    String? type,
    String? matricule,
    int? cout_journalier,
  }) async {
    var token = await Utils.getToken();
    dio.options.headers['Content-Type'] = "Application/json";
    dio.options.headers['accept'] = "Application/json";
    dio.options.headers['authorization'] = "Bearer ${token}";

    try {
      return await dio
          .post(
            Config.baseUrl + '/machines',
            data: {
              "nom": nom,
              "type": type,
              "matricule": matricule,
              "cout_journalier": cout_journalier,
              "status": "disponible",
            },
          )
          .catchError((onError) {
            print("exceeeppttion client $onError");
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
