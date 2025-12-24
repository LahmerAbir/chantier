import 'package:chantier/model/chantier.dart';
import 'package:chantier/model/chantier_single.dart';
import 'package:chantier/model/homme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/auth_api.dart';
import '../data/chantier_api.dart';
import '../model/AuthResponse.dart';
import '../model/client.dart';
import '../model/user_response.dart';
import '../utils/utils.dart';

class ChantierRepository {
  final chantierApi = ChantierApi();
  String? token;

  Future<List<Chantier>?> getChantiers() async {
    try {
      final resp = await chantierApi.getChantier();
      if (resp != null) {
          var response = ChantierData.fromJson(resp.data);
          final List<Chantier> list = response.data ?? [];
          return list;

      }
      return null;
    } catch (e) {
      print("exceeeppttion chantier $e");
      return null;
    }
  }

  Future<ChantierSingle?> getChantiersById(int? id) async {
    try {
      final resp = await chantierApi.getChantierById(id);
      if (resp != null) {
        var response = ChantierSingle.fromJson(resp.data);
        final ChantierSingle list = response;
        return list;

      }
      return null;
    } catch (e) {
      print("exceeeppttion chantier $e");
      return null;
    }
  }

  Future<List<Client>?> getClients() async {
    try {
      final resp = await chantierApi.getClients();
      if (resp != null) {
        var response = ClientData.fromJson(resp.data);
        final List<Client> list = response.data ?? [];
        return list;

      }
      return null;
    } catch (e) {
      print("exceeeppttion client $e");
      return null;
    }
  }
  Future<bool?> addClient({
    String? nom , String? email , String? adresse , String? telephone , String? ville  , String? pays
  }) async {
    try {
      final resp = await chantierApi.addClient(
        nom: nom,
        email: email,
        adresse: adresse,
        telephone: telephone,
        ville: ville,
        pays: pays,
      );
      if (resp != null) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      print("exceeeppttion client $e");
      return null;
    }
  }
  Future<bool?> addMatr({
    String? nom,
    String? type,
    String? matricule,
    int? cout_journalier,
  }) async {
    try {
      final resp = await chantierApi.addMat(
        nom: nom,
        type: type,
        matricule: matricule,
        cout_journalier: cout_journalier,

      );
      if (resp != null) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      print("exceeeppttion materiel $e");
      return null;
    }
  }
  Future<bool?> addHomme({
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? specialite,
  }) async {
    try {
      final resp = await chantierApi.addHomme(
        nom : nom,
        prenom : prenom,
        email : email,
        telephone : telephone,
        specialite :  specialite,
      );
      if (resp != null) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      print("exceeeppttion homme $e");
      return null;
    }
  }
  Future<bool?> addCamion({
    String? nom,
    String? capacite,
    String? matricule,
    int? cout_journalier
  }) async {
    try {
      final resp = await chantierApi.addCamion(
        nom: nom,
        capacite: capacite,
        matricule: matricule,
        cout_journalier: cout_journalier,

      );
      if (resp != null) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      print("exceeeppttion camion $e");
      return null;
    }
  }

  Future<bool?> addChantiers({
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
    try {
      final resp = await chantierApi.addChantier(
        nom: nom,
        owner: owner,
        description: description,
        adresse: adresse,
        date_emission: date_emission,
        dateecheeance: dateecheeance,
        total: total,
        status: status,
        ouvrier_ids: ouvrier_ids,
        machine_ids: machine_ids,
        camion_ids: camion_ids,
      );
      if (resp != null) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      print("exceeeppttion chantier $e");
      return null;
    }
  }

  Future<bool?> editChantiers({
    int? id,
    String? nom,
    String? owner,
    String? adresse,
    String? description,
    String? date_emission,
    String? dateecheeance,
    String? remarque,
    int? total,
    String? status,
    List<int>? ouvrier_ids,
    List<int>? machine_ids,
    List<int>? camion_ids,
  }) async {
    try {
      final resp = await chantierApi.editChantier(
        id : id ,
        nom: nom,
        owner: owner,
        description: description,
        adresse: adresse,
        remarque: remarque,
        date_emission: date_emission,
        dateecheeance: dateecheeance,
        total: total,
        status: status,
        ouvrier_ids: ouvrier_ids,
        machine_ids: machine_ids,
        camion_ids: camion_ids,
      );
      if (resp != null) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      print("exceeeppttion chantier $e");
      return null;
    }
  }

  Future<List<Homme>?> getHommes() async {
    try {
      final resp = await chantierApi.getHommes();
      if (resp != null) {
        if (resp.statusCode == 200) {
          var response = HommeData.fromJson(resp.data);
          final List<Homme> list = response.data ?? [];

          return list;
        } else {
          return null;
        }
      }
      return null;
    } catch (e) {
      print("exceeeppttion chantier $e");
      return null;
    }
  }

  Future<List<Materiel>?> getMateriel() async {
    try {
      final resp = await chantierApi.getMachines();
      if (resp != null) {
        if (resp.statusCode == 200) {
          var response = MaterielData.fromJson(resp.data);
          final List<Materiel> list = response.data ?? [];

          return list;
        } else {
          return null;
        }
      }
      return null;
    } catch (e) {
      print("exceeeppttion chantier $e");
      return null;
    }
  }

  Future<List<Camion>?> getCamions() async {
    try {
      final resp = await chantierApi.getCamions();
      if (resp != null) {
        if (resp.statusCode == 200) {
          var response = CamionData.fromJson(resp.data);
          final List<Camion> list = response.data ?? [];

          return list;
        } else {
          return null;
        }
      }
      return null;
    } catch (e) {
      print("exceeeppttion chantier $e");
      return null;
    }
  }
}
