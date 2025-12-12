// --- ARTICLE FORM BLOC (Méthode Alternative) ---
import 'dart:async';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../model/document.dart';
import '../utils/utils.dart';

class ArticleFormBloc extends FormBloc<String, String> {
  final description = TextFieldBloc(validators: [Utils.required]);
  final quantite = TextFieldBloc(
    initialValue: '1',
    validators: [Utils.required, ],
  );
  final prixUnitaire = TextFieldBloc(
    validators: [Utils.required, ],
  );

  ArticleFormBloc() {

    addFieldBlocs(fieldBlocs: [description, quantite, prixUnitaire]);
  }

  Article get articleData {
    final qte = int.tryParse(quantite.value) ?? 0;
    final prix = double.tryParse(prixUnitaire.value) ?? 0.0;

    return Article(
      description: description.value,
      quantite: qte,
      prixUnitaire: prix,
    );
  }

  @override
  FutureOr<void> onSubmitting() {
    // TODO: implement onSubmitting
    throw UnimplementedError();
  }

// Pas de onSubmitting, il est géré par le DocumentFormBloc
}