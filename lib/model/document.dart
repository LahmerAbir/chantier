import 'package:flutter/material.dart';

import '../blocs/art_form_bloc.dart';

class Document {
  String type; // 'Facture' ou 'Devis'
  String numero;
  DateTime date;
  String client;
  String reference;
  double totalTTC;
  double totalTTCAPayer;
  String status; // 'Payée', 'Émise', 'Annulée', 'En attente'
  List<Article> articles;

  Document({
    required this.type,
    required this.numero,
    required this.date,
    required this.client,
    required this.reference,
    required this.totalTTC,
    required this.totalTTCAPayer,
    required this.status,
    required this.articles,
  });
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