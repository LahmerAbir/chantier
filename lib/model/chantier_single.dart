import 'homme.dart';

class ChantierSingle {
  bool? success;
  Data? data;

  ChantierSingle({this.success, this.data});

  ChantierSingle.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? nom;
  String? owner;
  String? address;
  String? dateEmission;
  String? dateEcheance;
  int? total;
  String? status;
  String? remarque;
  String? createdAt;
  String? description;
  List<Homme>? ouvriers;
  List<Materiel>? machines;
  List<Camion>? camions;

  Data(
      {this.id,
        this.nom,
        this.owner,
        this.address,
        this.dateEmission,
        this.dateEcheance,
        this.total,
        this.status,
        this.createdAt,
        this.description,
        this.remarque,
        this.ouvriers,
        this.machines,
        this.camions});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    owner = json['owner'];
    address = json['address'];
    dateEmission = json['date_emission'];
    dateEcheance = json['date_echeance'];
    total = json['total'];
    status = json['status'];
    createdAt = json['created_at'];
    description = json['description'];
    remarque = json['remarque'];
    if (json['ouvriers'] != null) {
      ouvriers = <Homme>[];
      json['ouvriers'].forEach((v) {
        ouvriers!.add(new Homme.fromJson(v));
      });
    }
    if (json['machines'] != null) {
      machines = <Materiel>[];
      json['machines'].forEach((v) {
        machines!.add(new Materiel.fromJson(v));
      });
    }
    if (json['camions'] != null) {
      camions = <Camion>[];
      json['camions'].forEach((v) {
        camions!.add(new Camion.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nom'] = this.nom;
    data['owner'] = this.owner;
    data['address'] = this.address;
    data['date_emission'] = this.dateEmission;
    data['date_echeance'] = this.dateEcheance;
    data['total'] = this.total;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['description'] = this.description;
    data['remarque'] = this.remarque;
    if (this.ouvriers != null) {
      data['ouvriers'] = this.ouvriers!.map((v) => v.toJson()).toList();
    }
    if (this.machines != null) {
      data['machines'] = this.machines!.map((v) => v.toJson()).toList();
    }
    if (this.camions != null) {
      data['camions'] = this.camions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

