import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class RessourceBase {
  final String id;
  final String name;
  final String type; // 'homme', 'materiel', ou 'camion'
  final IconData icon;

  RessourceBase(this.id, this.name, this.type, this.icon);
}

class Homme extends RessourceBase {
  Homme(String id, String name)
      : super(id, name, 'homme', Icons.person);
}

class Materiel extends RessourceBase {
  Materiel(String id, String name)
      : super(id, name, 'materiel', Icons.agriculture);
}

class Camion extends RessourceBase {
  Camion(String id, String name)
      : super(id, name, 'camion', Icons.local_shipping);
}