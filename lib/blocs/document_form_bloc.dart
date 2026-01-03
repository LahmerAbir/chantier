// --- DOCUMENT FORM BLOC (Méthode Alternative) ---

import 'dart:async';
import 'dart:math';

import 'package:chantier/repository/devis&facture_repository.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../model/client.dart';
import '../model/document.dart';
import '../utils/utils.dart';
import 'art_form_bloc.dart';

class DocumentFormBloc extends FormBloc<String, String> {
  final type = SelectFieldBloc<String, dynamic>(
    validators: [FieldBlocValidators.required],
    items: ['Facture', 'Devis', 'EA'],
    initialValue: 'Facture',
  );

  final date = InputFieldBloc<DateTime?, dynamic>(
    validators: [(value) => value == null ? 'Date requise.' : null],
    initialValue: DateTime.now(),
  );

  int? factureId;
  final client = SelectFieldBloc<Client, dynamic>(
    validators: [FieldBlocValidators.required],
    initialValue: null,
    items: const [],
  );
  final notes = TextFieldBloc(validators: []);

  final status = SelectFieldBloc<String, dynamic>(
    validators: [FieldBlocValidators.required],
    items: ['payée', 'non payée', 'partiellement payée'],
    initialValue: 'non payée',
  );
  final List<ArticleFormBloc> articleBlocs = [ArticleFormBloc()];

  final articlesListState = InputFieldBloc<List<ArticleFormBloc>, dynamic>(
    initialValue: [],
  );

  final totalTTC = TextFieldBloc(initialValue: '00 ');
  final totalTTCAPayer = TextFieldBloc(initialValue: '00 ');

  final Map<FormBloc, List<StreamSubscription>> _articleSubscriptions = {};

  ////////////EA
  final TextFieldBloc periodeEA = TextFieldBloc(); // ex: Désamiantage EA 3
  final TextFieldBloc numCommande = TextFieldBloc();
  final TextFieldBloc totalCommandeBase = TextFieldBloc(validators: [
    FieldBlocValidators.required,
    _mustBeDouble, // Validateur personnalisé ci-dessous
  ],
  );
  final TextFieldBloc totalSupplements = TextFieldBloc(validators: [
    FieldBlocValidators.required,
    _mustBeDouble, // Validateur personnalisé ci-dessous
  ],);
  final TextFieldBloc retenueRetard = TextFieldBloc(validators: [
    FieldBlocValidators.required,
    _mustBeDouble, // Validateur personnalisé ci-dessous
  ],);
  final TextFieldBloc avancementCumule = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      _mustBeDouble, // Validateur personnalisé ci-dessous
    ],
  );

  // Liste dynamique pour les factures déjà émises
  final ListFieldBloc<FactureInfoFieldBloc, dynamic> facturesEmises =
      ListFieldBloc();
  final postesEA = ListFieldBloc<PosteEAFieldBloc, dynamic>(name: 'postesEA');
  DocumentFormBloc({
    Facture? initialFacture,
    List<Client> availableClients = const [],
  }) : factureId = initialFacture?.id {
    addFieldBlocs(
      fieldBlocs: [type, date, client, status, articlesListState, notes ,],
    );
    postesEA.stream.listen((state) {
      recalculerTotalB();
    });

    final randomNum = Random().nextInt(10000).toString().padLeft(4, '0');
    numCommande.updateInitialValue("EA-$randomNum");
    type.onValueChanges(
      onData: (previous, current) async* {
        if (current.value == 'EA') {
          addFieldBlocs(
            fieldBlocs: [
              periodeEA,
              numCommande,
              totalCommandeBase,
              totalSupplements,
              retenueRetard,
              avancementCumule,
              facturesEmises,
              postesEA
            ],
          );
        } else {
          removeFieldBlocs(
            fieldBlocs: [
              periodeEA,
              numCommande,
              totalCommandeBase,
              totalSupplements,
              retenueRetard,
              avancementCumule,
              facturesEmises,
              postesEA
            ],
          );
        }
      },
    );

    if (initialFacture != null) {
      type.updateValue(
        initialFacture.reference!.contains("FAC") ? "Facture" : "Devis" ?? '',
      );
      notes.updateValue(initialFacture.notes ?? "");
      status.updateValue(initialFacture.status ?? '');
      if (initialFacture.clientId != null) {
        try {
          print('availableClients ${availableClients.length}');
          final selectedClient = availableClients.firstWhere(
            (c) => c.id == initialFacture.clientId,
          );
          client.updateValue(selectedClient);
        } catch (e) {
          print("Client non trouvé dans la liste");
        }
      }

      if (initialFacture.date != null) {
        date.updateValue(DateTime.parse(initialFacture.date!));
      }
    }
    _reconfigureArticleListeners();
  }
  static String? _mustBeDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    final isDouble = double.tryParse(value.replaceFirst(',', '.')) != null;
    if (!isDouble) return 'Veuillez entrer un nombre valide';
    return null;
  }
  void addArticle() {
    print("add article");
    final newArticleBloc = ArticleFormBloc();
    articleBlocs.add(newArticleBloc);
    _listenToArticleBloc(newArticleBloc);
    _updateFormState();
  }
  void recalculerTotalB() {
    double totalGeneralB = 0.0;

    for (var poste in postesEA.value) {
      double prec = double.tryParse(poste.qtePrecedente.value.replaceFirst(',', '.')) ?? 0.0;
      double actu = double.tryParse(poste.qteActuelle.value.replaceFirst(',', '.')) ?? 0.0;
      double pu = double.tryParse(poste.prixUnitaire.value.replaceFirst(',', '.')) ?? 0.0;

      totalGeneralB += (prec + actu) * pu;
    }

    // Mise à jour du champ sans déclencher une boucle infinie
    avancementCumule.updateValue(totalGeneralB.toStringAsFixed(2));
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
        bloc.prixUnitaire.stream.listen((_) => _updateFormState()),
      );

      _articleSubscriptions[bloc] = subscriptions;
    } catch (e) {
      print("exception in listeb article $e");
    }
  }

  void _removeListeners(ArticleFormBloc bloc) {
    _articleSubscriptions[bloc]?.forEach((sub) => sub.cancel());
    _articleSubscriptions.remove(bloc);
  }

  void _reconfigureArticleListeners() {
    // Nettoyage et mise en place des écoutes pour tous les blocs actuels
    _articleSubscriptions.values
        .expand((list) => list)
        .forEach((sub) => sub.cancel());
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
        subtotal += (data.prixUnitaire! * (data.quantite!)) ?? 0;
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
    if (type.value != "EA") {
      final allArticlesValid = articleBlocs.every((bloc) =>
      bloc.state.canSubmit);

      if (!allArticlesValid) {
        articleBlocs.forEach((bloc) => bloc.submit());
        emitFailure(
          failureResponse:
          "Veuillez corriger les erreurs dans la liste des articles.",
        );
        return;
      }
      print("cc in add facture");
      final List<Article> finalArticles = articleBlocs
          .map((bloc) => bloc.articleData)
          .toList();
      var dateD = Utils.convertDateTimeToSqlDateFormat(
        date.value ?? DateTime.now(),
      );
      try {
        if (factureId != null) {
          var ref = Utils.genererReference(
            type.value!.toLowerCase(),
            date.value!,
          );

          var res = await FactureRepository().editFacture(
            id: factureId,
            reference: ref,
            date: dateD,
            client_id: client.value?.id ?? 1,
            status: status.value,

            notes: notes.value,
            articles: finalArticles,
          );
          if (res != null)
            emitSuccess(canSubmitAgain: true, successResponse: ref);
          else
            emitFailure();
        } else {
          var ref = Utils.genererReference(
            type.value!.toLowerCase(),
            date.value!,
          );

          var res = await FactureRepository().addFacture(
            reference: ref,
            date: dateD,
            client_id: client.value?.id ?? 1,
            status: status.value,

            notes: notes.value,
            articles: finalArticles,
          );
          if (res != null)
            emitSuccess(canSubmitAgain: true, successResponse: ref);
          else
            emitFailure();
        }
      } catch (e) {
        print("exception in addd facture $e");
        emitFailure();
      }
    }else
      emitSuccess();
  }
  double calculerTotalFacturesEmises() {
    return facturesEmises.value.fold(0.0, (total, group) {
      // On parse la String du TextField en double
      final montant = double.tryParse(group.montantHTVA.value) ?? 0.0;
      return total + montant;
    });
  }

}

class FactureInfoFieldBloc extends GroupFieldBloc {
  final TextFieldBloc numFacture;
  final TextFieldBloc montantHTVA;

  // Constructeur nommé privé pour l'initialisation propre
  FactureInfoFieldBloc._({
    required String name,
    required this.numFacture,
    required this.montantHTVA,
  }) : super(
    name: name,
    fieldBlocs: [numFacture, montantHTVA],
  );

  // Factory pour créer une nouvelle instance facilement
  factory FactureInfoFieldBloc.create(String name) {
    return FactureInfoFieldBloc._(
      name: name,
      numFacture: TextFieldBloc(
        validators: [FieldBlocValidators.required],
      ),
      montantHTVA: TextFieldBloc(
       // initialValue: '0.0',
        validators: [FieldBlocValidators.required],
      ),
    );
  }
}

class PosteEAFieldBloc extends GroupFieldBloc {
  final TextFieldBloc designation;
  final TextFieldBloc unite;
  final TextFieldBloc qteTotale;
  final TextFieldBloc prixUnitaire;
  final TextFieldBloc qtePrecedente;
  final TextFieldBloc qteActuelle;

  PosteEAFieldBloc._({
    required String name,
    required this.designation,
    required this.unite,
    required this.qteTotale,
    required this.prixUnitaire,
    required this.qtePrecedente,
    required this.qteActuelle,
    required List<FieldBloc> fields,
  }) : super(name: name, fieldBlocs: fields);

  factory PosteEAFieldBloc.create(String name) {
    final d = TextFieldBloc(name: 'designation');
    final u = TextFieldBloc(name: 'unite', initialValue: 'm²');
    final qt = TextFieldBloc(name: 'qteTotale', initialValue: '0');
    final pu = TextFieldBloc(name: 'prixUnitaire', initialValue: '0');
    final qp = TextFieldBloc(name: 'qtePrecedente', initialValue: '0');
    final qa = TextFieldBloc(name: 'qteActuelle', initialValue: '0');

    return PosteEAFieldBloc._(
      name: name,
      designation: d,
      unite: u,
      qteTotale: qt,
      prixUnitaire: pu,
      qtePrecedente: qp,
      qteActuelle: qa,
      fields: [d, u, qt, pu, qp, qa],
    );
  }
}