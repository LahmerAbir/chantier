import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class RessourceBase {
  final int? id;
  final String? nom;
  final String type; // 'homme', 'materiel', ou 'camion'
  final IconData icon;

  RessourceBase(this.id, this.nom, this.type, this.icon);
}

class HommeData {
  bool? success;
  List<Homme>? data;
  Meta? meta;

  HommeData({this.success, this.data, this.meta});

  HommeData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Homme>[];
      json['data'].forEach((v) {
        data!.add(new Homme.fromJson(v));
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

class Homme extends RessourceBase {
  int? id;
  String? nom;
  String? prenom;
  String? email;
  String? telephone;
  String? specialite;
  int? coutJournalier;
  String? status;
  String? createdAt;

  Homme({
    this.id,
    this.nom,
    this.prenom,
    this.email,
    this.telephone,
    this.specialite,
    this.coutJournalier,
    this.status,
    this.createdAt,
  }) : super(id, nom, 'homme', Icons.person);

  Homme.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      nom = json['nom'],
      super(json['id'], json['nom'], 'homme', Icons.person) {
    prenom = json['prenom'];
    email = json['email'];
    telephone = json['telephone'];
    specialite = json['specialite'];
    coutJournalier = json['cout_journalier'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nom'] = this.nom;
    data['prenom'] = this.prenom;
    data['email'] = this.email;
    data['telephone'] = this.telephone;
    data['specialite'] = this.specialite;
    data['cout_journalier'] = this.coutJournalier;
    data['status'] = this.status;
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

class MaterielData {
  bool? success;
  List<Materiel>? data;
  Meta? meta;

  MaterielData({this.success, this.data, this.meta});

  MaterielData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Materiel>[];
      json['data'].forEach((v) {
        data!.add(new Materiel.fromJson(v));
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

class Materiel extends RessourceBase {
  int? id;
  String? nom;
  String? typem;
  String? matricule;
  int? coutJournalier;
  String? status;
  String? createdAt;

  Materiel({
    this.id,
    this.nom,
    this.typem,
    this.matricule,
    this.coutJournalier,
    this.status,
    this.createdAt,
  }) : super(id, nom, 'materiel', Icons.agriculture);

  Materiel.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      nom = json['nom'],
      super(json['id'], json['nom'], 'homme', Icons.person) {
    typem = json['type'];
    matricule = json['matricule'];
    coutJournalier = json['cout_journalier'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nom'] = this.nom;
    data['type'] = this.type;
    data['matricule'] = this.matricule;
    data['cout_journalier'] = this.coutJournalier;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    return data;
  }
}

class CamionData {
  bool? success;
  List<Camion>? data;
  Meta? meta;

  CamionData({this.success, this.data, this.meta});

  CamionData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Camion>[];
      json['data'].forEach((v) {
        data!.add(new Camion.fromJson(v));
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

class Camion extends RessourceBase {
  int? id;
  String? nom;
  String? matricule;
  String? capacite;
  int? coutJournalier;
  String? status;
  String? createdAt;

  Camion({
    this.id,
    this.nom,
    this.matricule,
    this.capacite,
    this.coutJournalier,
    this.status,
    this.createdAt,
  }) : super(id, nom, 'camion', Icons.local_shipping);

  Camion.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      nom = json['nom'],
      super(json['id'], json['nom'], 'homme', Icons.person) {
    id = json['id'];
    nom = json['nom'];
    matricule = json['matricule'];
    capacite = json['capacite'];
    coutJournalier = json['cout_journalier'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nom'] = this.nom;
    data['matricule'] = this.matricule;
    data['capacite'] = this.capacite;
    data['cout_journalier'] = this.coutJournalier;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    return data;
  }
}
