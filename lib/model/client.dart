class ClientData {
  bool? success;
  List<Client>? data;
  Meta? meta;

  ClientData({this.success, this.data, this.meta});

  ClientData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Client>[];
      json['data'].forEach((v) {
        data!.add(new Client.fromJson(v));
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

class Client {
  int? id;
  String? nom;
  String? email;
  String? telephone;
  String? adresse;
  String? ville;
  String? pays;
  String? createdAt;

  Client(
      {this.id,
        this.nom,
        this.email,
        this.telephone,
        this.adresse,
        this.ville,
        this.pays,
        this.createdAt});

  Client.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    email = json['email'];
    telephone = json['telephone'];
    adresse = json['adresse'];
    ville = json['ville'];
    pays = json['pays'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nom'] = this.nom;
    data['email'] = this.email;
    data['telephone'] = this.telephone;
    data['adresse'] = this.adresse;
    data['ville'] = this.ville;
    data['pays'] = this.pays;
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