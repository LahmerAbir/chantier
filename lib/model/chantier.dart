import 'homme.dart';

class ChantierData {
  bool? success;
  List<Chantier>? data;
  Meta? meta;

  ChantierData({this.success, this.data, this.meta});

  ChantierData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Chantier>[];
      json['data'].forEach((v) {
        data!.add(new Chantier.fromJson(v));
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

class Chantier {
  int? id;
  String? nom;
  String? owner;
  String? address;
  String? description;
  String? dateEmission;
  String? dateEcheance;
  int? total;
  String? status;
  int? clientId;
  String? createdAt;
  String? remarque;
  List<Homme>? ouvriers;
  List<Camion>? camions;
  List<Materiel>? machines;
  Chantier(
      {this.id,
        this.nom,
        this.owner,
        this.address,
        this.dateEmission,
        this.dateEcheance,
        this.ouvriers ,
        this.camions ,
        this.remarque ,
        this.machines ,
        this.total,
        this.status,
        this.clientId,
        this.createdAt});

  Chantier.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    owner = json['owner'];
    address = json['address'];
    dateEmission = json['date_emission'];
    description = json['description'];
    dateEcheance = json['date_echeance'];
    total = json['total'];
    remarque = json['remarque'];
    status = json['status'];
    ouvriers: (json['ouvriers'] as List?)
        ?.map((i) => Homme.fromJson(i))
        .toList() ?? [];
    camions: (json['camions'] as List?)
        ?.map((i) => Camion.fromJson(i))
        .toList() ?? [];
    machines: (json['machines'] as List?)
        ?.map((i) => Materiel.fromJson(i))
        .toList() ?? [];
    clientId = json['client_id'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nom'] = this.nom;
    data['owner'] = this.owner;
    data['description'] = this.description;
    data['remarque'] = this.remarque;
    data['address'] = this.address;
    data['date_emission'] = this.dateEmission;
    data['date_echeance'] = this.dateEcheance;
    data['total'] = this.total;
    data['status'] = this.status;
    data['client_id'] = this.clientId;
    data['created_at'] = this.createdAt;
    data['ouvriers']= ouvriers?.map((i) => i.toJson()).toList();
    data['camions']= camions?.map((i) => i.toJson()).toList();
    data['machines']= machines?.map((i) => i.toJson()).toList();
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