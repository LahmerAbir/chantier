import 'package:chantier/data/devis&facture_api.dart';
import 'package:chantier/model/chantier.dart';
import 'package:chantier/model/document.dart';
import 'package:chantier/model/homme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/auth_api.dart';
import '../data/chantier_api.dart';
import '../model/AuthResponse.dart';
import '../model/user_response.dart';
import '../utils/utils.dart';

class FactureRepository {
  final factureApi = FactureApi();
  String? token;

  Future<List<Facture>?> getFactures() async {
    try {
      final resp = await factureApi.getFactures();
      if (resp != null) {
          var response = FactureData.fromJson(resp.data);
          final List<Facture> list = response.data ?? [];
          return list;

      }
      return null;
    } catch (e) {
      print("exceeeppttion Facture $e");
      return null;
    }
  }

 /* Future<bool?> addChantiers({
    String? nom,
    String? owner,
    String? adresse,
    String? date_emission,
    String? dateecheeance,
    int? total,
    String? status,
  }) async {
    try {
      final resp = await chantierApi.addChantier(
        nom: nom,
        owner: owner,
        adresse: adresse,
        date_emission: date_emission,
        dateecheeance: dateecheeance,
        total: total,
        status: status,
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
  }*/


}
