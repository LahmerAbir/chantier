
import 'package:chantier/repository/chantier_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:intl/intl.dart';

import '../model/homme.dart';
import '../utils/utils.dart';

class ChantierFormBloc extends FormBloc<String, String> {
  final nomChantier = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final client = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final budget = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      _validateBudget,
    ],
  );

  // 2. Champ Status (Dropdown)
  final status = SelectFieldBloc<String, dynamic>(
    validators: [FieldBlocValidators.required],
    items: ['en cours', 'terminé', 'en attente'],
    initialValue: 'en attente',
  );

  // 3. Champs de Date
  final dateDebut = InputFieldBloc<DateTime?, dynamic>(
    validators: [(value) => value == null ? 'Date début requise.' : null],
    initialValue: null,
  );
  final dateFin = InputFieldBloc<DateTime?, dynamic>(
    validators: [(value) => value == null ? 'Date fin requise.' : null],
    initialValue: null,
  );

  final hommesAssigned = InputFieldBloc<List<Homme>, dynamic>(initialValue: []);
  final materielAssigned = InputFieldBloc<List<Materiel>, dynamic>(
    initialValue: [],
  );
  final ressourcesAssigned = InputFieldBloc<List<RessourceBase>, dynamic>(
    initialValue: [],
  );

  ChantierFormBloc() {
    addFieldBlocs(
      fieldBlocs: [
        nomChantier,
        client,
        budget,
        status,
        dateDebut,
        dateFin,
        hommesAssigned,
        materielAssigned,
        ressourcesAssigned,
      ],
    );
  }

  static String? _validateBudget(String? budget) {
    if (budget == null || budget.isEmpty) return null;
    final cleanBudget = budget.replaceAll(RegExp(r'[^\d]'), '');
    if (int.tryParse(cleanBudget) == null) {
      return "Le budget doit être un nombre valide.";
    }
    return null;
  }

  @override
  void onSubmitting() async {
    final assigned = hommesAssigned.value;
    final assignedM = materielAssigned.value;

    print('--- Soumission du Chantier ---');
    print('Nom: ${nomChantier.value}');
    print('Client: ${client.value}');
    print('Statut: ${status.value}');
    print('Budget: ${budget.value}');
    print('Ressources assignées: ${assigned.map((r) => r.nom).join(', ')}');
    var dateD = Utils.convertDateTimeToSqlDateFormat(dateDebut.value ?? DateTime.now());
    var dateF = Utils.convertDateTimeToSqlDateFormat(dateDebut.value ?? DateTime.now());
    try {
      var res = await ChantierRepository().addChantiers(
        nom: nomChantier.value,
        owner: client.value,
        adresse: nomChantier.value,
        date_emission: dateD,
        dateecheeance: dateF,
        total: int.parse(budget.value),
        status: status.value == "terminé" ? "fini" :  status.value,
      );
      if (res != null)
        emitSuccess(
          canSubmitAgain: true,
          successResponse: 'Chantier ${nomChantier.value} créé avec succès.',
        );
      else
        emitFailure();
    }catch(e)
    {
      emitFailure();

    }

  }
}
