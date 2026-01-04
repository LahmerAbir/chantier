import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/document.dart';

// --- ÉTATS ---
abstract class ArticleFormState extends Equatable {
  const ArticleFormState();
  @override
  List<Object?> get props => [];
}

class ArticleFormInitial extends ArticleFormState {}
// Pas besoin de loading/success/failure car pas de soumission ici

// --- CUBIT ---
class ArticleFormBloc extends Cubit<ArticleFormState> {
  ArticleFormBloc() : super(ArticleFormInitial());

  String description = '';
  String quantite = '1';
  String prixUnitaire = '';

  void updateDescription(String value) => description = value;
  void updateQuantite(String value) => quantite = value;
  void updatePrixUnitaire(String value) => prixUnitaire = value;

  // Méthode pour récupérer l'objet Article
  Article get articleData {
    final qte = int.tryParse(quantite) ?? 0;
    final prix = int.tryParse(prixUnitaire) ?? 0;

    return Article(
      description: description,
      quantite: qte,
      prixUnitaire: prix,
    );
  }
  
  // Validation (optionnel, peut être appelé par le parent)
  bool isValid() {
    return description.isNotEmpty && 
           quantite.isNotEmpty && int.tryParse(quantite) != null &&
           prixUnitaire.isNotEmpty && int.tryParse(prixUnitaire) != null;
  }
}
