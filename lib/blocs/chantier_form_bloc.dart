import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:intl/intl.dart';

import '../model/homme.dart';



class ChantierFormBloc extends FormBloc<String, String> {
  final nomChantier = TextFieldBloc(
    validators: [FieldBlocValidators.required],
  );
  final client = TextFieldBloc(
    validators: [FieldBlocValidators.required],
  );
  final budget = TextFieldBloc(
    validators: [FieldBlocValidators.required, _validateBudget], // Ajout d'une validation simple
  );

  // 2. Champ Status (Dropdown)
  final status = SelectFieldBloc<String, dynamic>(
    validators: [FieldBlocValidators.required],
    items: ['En cours', 'Livré', 'Retard', 'En attente'],
    initialValue: 'En attente',
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

  final hommesAssigned = InputFieldBloc<List<Homme>, dynamic>(
    initialValue: [],
  );
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
        ressourcesAssigned
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
    print('Ressources assignées: ${assigned.map((r) => r.name).join(', ')}');

    // Simuler l'envoi des données
    await Future.delayed(const Duration(seconds: 1));

    emitSuccess(
      canSubmitAgain: true,
      successResponse: 'Chantier ${nomChantier.value} créé avec succès.',
    );
  }
}