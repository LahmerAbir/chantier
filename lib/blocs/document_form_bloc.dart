// --- DOCUMENT FORM BLOC (Méthode Alternative) ---

import 'dart:async';

import 'package:chantier/repository/devis&facture_repository.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../model/client.dart';
import '../model/document.dart';
import '../utils/utils.dart';
import 'art_form_bloc.dart';

class DocumentFormBloc extends FormBloc<String, String> {
  final type = SelectFieldBloc<String, dynamic>(
    validators: [FieldBlocValidators.required],
    items: ['Facture', 'Devis'],
    initialValue: 'Facture',
  );

  final date = InputFieldBloc<DateTime?, dynamic>(
    validators: [(value) => value == null ? 'Date requise.' : null],
    initialValue: DateTime.now(),
  );

  final client = SelectFieldBloc<Client, dynamic>(
    validators: [FieldBlocValidators.required],
    initialValue: null,
    items: const [],
  );
  final notes = TextFieldBloc(
    validators: [],
  );

  final status = SelectFieldBloc<String, dynamic>(
    validators: [FieldBlocValidators.required],
    items: ['payée', 'non payée', 'partiellement payée'],
    initialValue: 'non payée',
  );
  final List<ArticleFormBloc> articleBlocs = [
    ArticleFormBloc( ),
  ];

  final articlesListState = InputFieldBloc<List<ArticleFormBloc>, dynamic >(
    initialValue: [],
  );

  // Champs calculés
  final totalTTC = TextFieldBloc(initialValue: '00 ',);
  final totalTTCAPayer = TextFieldBloc(initialValue: '00 ', );

  // Map pour stocker les subscriptions et les annuler
  final Map<FormBloc, List<StreamSubscription>> _articleSubscriptions = {};

  DocumentFormBloc() {
    addFieldBlocs(
      fieldBlocs: [type, date, client, status, articlesListState , notes],
    );
    _reconfigureArticleListeners();
  }



  void addArticle() {
    print("add article");
    final newArticleBloc = ArticleFormBloc();
    articleBlocs.add(newArticleBloc);
    _listenToArticleBloc(newArticleBloc);
    _updateFormState();
  }

  void removeArticleAt(int index) {
    final blocToRemove = articleBlocs.removeAt(index);
    _removeListeners(blocToRemove); // Supprimer les écoutes
    blocToRemove.close();
    _updateFormState(); // Mettre à jour les totaux et l'état
  }

  // --- Gestion des Écoutes et Calculs ---

  void _listenToArticleBloc(ArticleFormBloc bloc) {
    try {
      final subscriptions = <StreamSubscription>[];
      subscriptions.add(bloc.quantite.stream.listen((_) => _updateFormState()));
      subscriptions.add(
          bloc.prixUnitaire.stream.listen((_) => _updateFormState()));

    _articleSubscriptions[bloc] = subscriptions;
    }catch(e)
    {
      print("exception in listeb article $e");
    }
  }

  void _removeListeners(ArticleFormBloc bloc) {
    _articleSubscriptions[bloc]?.forEach((sub) => sub.cancel());
    _articleSubscriptions.remove(bloc);
  }

  void _reconfigureArticleListeners() {
    // Nettoyage et mise en place des écoutes pour tous les blocs actuels
    _articleSubscriptions.values.expand((list) => list).forEach((sub) => sub.cancel());
    _articleSubscriptions.clear();

    for (final articleBloc in articleBlocs) {
      _listenToArticleBloc(articleBloc);
    }
    _updateFormState();
  }

  // Met à jour les totaux et la valeur articlesListState
  void _updateFormState() {
   print("final step");
    int subtotal = 0;
    final List<Article> currentArticles = [];

    for (final bloc in articleBlocs) {
      if (bloc.state.canSubmit) {
        final data = bloc.articleData;
        subtotal += (data.prixUnitaire! * (data.quantite!))  ?? 0;
        currentArticles.add(data);
      }
    }

    // 2. Mise à jour des totaux
    const double tvaRate = 0.20;
    double grandTotal = subtotal * (1 + tvaRate);

    totalTTC.updateValue('${subtotal.toStringAsFixed(2)}');
    totalTTCAPayer.updateValue('${grandTotal.toStringAsFixed(2)}');
    articlesListState.updateValue(articleBlocs);
  }

  @override
  FutureOr<void> onDeleting() {
    print("add article $articleBlocs");
    final newArticleBloc = ArticleFormBloc();
    articleBlocs.add(newArticleBloc);
    _listenToArticleBloc(newArticleBloc);
    _updateFormState();

  }


  @override
  void onSubmitting() async {

    final allArticlesValid = articleBlocs.every((bloc) => bloc.state.canSubmit);

    if (!allArticlesValid) {
      articleBlocs.forEach((bloc) => bloc.submit());
      emitFailure(
          failureResponse: "Veuillez corriger les erreurs dans la liste des articles.");
      return;
    }
    print("cc in add facture");
    final List<Article> finalArticles = articleBlocs.map((bloc) =>
    bloc.articleData).toList();
    var dateD = Utils.convertDateTimeToSqlDateFormat(date.value ?? DateTime.now());
    try {
      var ref = Utils.genererReference(type.value!.toLowerCase(), date.value!);

      var res = await FactureRepository().addFacture(
        reference: ref,
        date:dateD ,
        client_id:client.value?.id ?? 1 ,
        status: status.value,

        notes: notes.value,
        articles: finalArticles,);
      if (res != null)
        emitSuccess(
          canSubmitAgain: true,
          successResponse: ref,
        );
      else
        emitFailure();
    } catch (e) {
      print("exception in addd facture $e");
      emitFailure();
    }

  }
}