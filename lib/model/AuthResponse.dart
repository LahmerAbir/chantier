import 'package:chantier/model/user_response.dart';

class AuthResp {
  bool? success;
  Data? data;
  String? message;

  AuthResp({this.success, this.data, this.message});

  AuthResp.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  UserRes? user;
  Session? session;

  Data({this.user, this.session});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new UserRes.fromJson(json['user']) : null;
    session =
    json['session'] != null ? new Session.fromJson(json['session']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.session != null) {
      data['session'] = this.session!.toJson();
    }
    return data;
  }
}


class Session {
  String? accessToken;
  String? refreshToken;
  int? expiresAt;

  Session({this.accessToken, this.refreshToken, this.expiresAt});

  Session.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
    expiresAt = json['expires_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    data['refresh_token'] = this.refreshToken;
    data['expires_at'] = this.expiresAt;
    return data;
  }
}




