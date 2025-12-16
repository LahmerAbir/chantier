import 'package:chantier/data/devis&facture_api.dart';
import 'package:chantier/model/document.dart';


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

  Future<bool?> addFacture({
    String? reference,
    String? date,
    int? client_id,
    int? total_ht,
    int? total_ttc,
    int? montant_paye,
    String? status,
    String? notes,
    List<Article>? articles
  }) async {
    try {
      final resp = await factureApi.addFactures(
        reference: reference,
        date: date,
        client_id: client_id,
        total_ht: total_ht,
        total_ttc: total_ttc,
        montant_paye: montant_paye,
        status: status,
        notes: notes,
        articles: articles,
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


}
