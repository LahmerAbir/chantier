
import 'AuthResponse.dart';
class UserRes {
  String? id;
  String? email;
  String? nom;
  String? role;

  UserRes({this.id, this.email, this.nom, this.role});

  UserRes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    nom = json['nom'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['nom'] = this.nom;
    data['role'] = this.role;
    return data;
  }
}

