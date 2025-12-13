import 'package:flutter/material.dart';

import '../blocs/art_form_bloc.dart';

class FactureData {
  bool? success;
  List<Facture>? data;
  Meta? meta;

  FactureData({this.success, this.data, this.meta});

  FactureData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Facture>[];
      json['data'].forEach((v) {
        data!.add(new Facture.fromJson(v));
      });
    }
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    return data;
  }
}

class Facture {
  int? id;
  String? reference;
  int? clientId;
  int? devisId;
  String? date;
  String? dateEcheance;
  double? totalHt;
  int? tva;
  int? totalTtc;
  int? montantPaye;
  String? status;
  String? notes;
  String? createdAt;
  List<Article>? articles;

  Facture(
      {this.id,
        this.reference,
        this.clientId,
        this.devisId,
        this.date,
        this.dateEcheance,
        this.totalHt,
        this.tva,
        this.totalTtc,
        this.montantPaye,
        this.status,
        this.notes,
        this.articles,
        this.createdAt});

  Facture.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reference = json['reference'];
    clientId = json['client_id'];
    devisId = json['devis_id'];
    date = json['date'];
    dateEcheance = json['date_echeance'];
    totalHt = json['total_ht'];
    tva = json['tva'];
    totalTtc = json['total_ttc'];
    montantPaye = json['montant_paye'];
    status = json['status'];
    notes = json['notes'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['reference'] = this.reference;
    data['client_id'] = this.clientId;
    data['devis_id'] = this.devisId;
    data['date'] = this.date;
    data['date_echeance'] = this.dateEcheance;
    data['total_ht'] = this.totalHt;
    data['tva'] = this.tva;
    data['total_ttc'] = this.totalTtc;
    data['montant_paye'] = this.montantPaye;
    data['status'] = this.status;
    data['notes'] = this.notes;
    data['created_at'] = this.createdAt;
    return data;
  }
}

class Meta {
  int? page;
  int? limit;
  int? total;

  Meta({this.page, this.limit, this.total});

  Meta.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['total'] = this.total;
    return data;
  }
}

class Article {
  String description;
  int quantite;
  double prixUnitaire;

  Article({
    required this.description,
    required this.quantite,
    required this.prixUnitaire,
  });

  double get prixTotal => quantite * prixUnitaire;
}