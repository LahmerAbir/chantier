import 'package:chantier/repository/chantier_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:intl/intl.dart';

import '../model/chantier.dart';
import '../model/client.dart';
import '../model/homme.dart';
import '../utils/utils.dart';

class ChantierFormBloc extends FormBloc<String, String> {
  final nomChantier = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final description = TextFieldBloc();
  final client = SelectFieldBloc<Client, dynamic>(
    validators: [FieldBlocValidators.required],
    initialValue: null,
    items: const [],
  );
  final budget = TextFieldBloc(
    validators: [FieldBlocValidators.required, _validateBudget],
  );

  final int? chantierId;
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
  List<Homme> hommes = [];
  List<Materiel> materiels = [];
  List<Camion> camions = [];

  ChantierFormBloc({
    Chantier? initialChantier,
    List<Client> availableClients = const [],
  }) : chantierId = initialChantier?.id {
    addFieldBlocs(
      fieldBlocs: [
        nomChantier,
        client,
        budget,
        description,
        status,
        dateDebut,
        dateFin,
        hommesAssigned,
        materielAssigned,
        ressourcesAssigned,
      ],
    );
    if (initialChantier != null) {
      nomChantier.updateValue(initialChantier.nom ?? '');
      budget.updateValue(initialChantier.total.toString());
      description.updateValue(initialChantier.description ?? "");
      status.updateValue(initialChantier.status ?? '');
      if (initialChantier.clientId != null) {
        try {
          print('availableClients ${availableClients.length}');
          final selectedClient = availableClients.firstWhere(
            (c) => c.id == initialChantier.clientId,
          );
          client.updateValue(selectedClient);
        } catch (e) {
          print("Client non trouvé dans la liste");
        }
      }

      if (initialChantier.dateEmission != null) {
        dateDebut.updateValue(DateTime.parse(initialChantier.dateEmission!));
        dateFin.updateValue(DateTime.parse(initialChantier.dateEcheance!));
      }
    }
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
    var dateD = Utils.convertDateTimeToSqlDateFormat(
      dateDebut.value ?? DateTime.now(),
    );
    var dateF = Utils.convertDateTimeToSqlDateFormat(
      dateDebut.value ?? DateTime.now(),
    );
    final listHomme = ressourcesAssigned.value.whereType<Homme>().toList();
    final listCamion = ressourcesAssigned.value.whereType<Camion>().toList();
    final listMateriel = ressourcesAssigned.value
        .whereType<Materiel>()
        .toList();
    final List<int> hommesIds = listHomme.map((h) => h.id!).toList();
    final List<int> camionsIds = listCamion.map((c) => c.id!).toList();
    final List<int> materielsIds = listMateriel.map((m) => m.id!).toList();
    try {
      if (chantierId != null) {
        var res = await ChantierRepository().editChantiers(
          id: chantierId,
          nom: nomChantier.value,
          owner: client.value?.nom ?? "",
          description: description.value ?? "",
          adresse: nomChantier.value,
          date_emission: dateD,
          dateecheeance: dateF,
          total: int.parse(budget.value),
          status: status.value,
          ouvrier_ids: hommesIds,
          camion_ids: camionsIds,
          machine_ids: materielsIds,
        );
        if (res != null)
          emitSuccess(
            canSubmitAgain: true,
            successResponse:
                'Chantier ${nomChantier.value} modifié avec succès.',
          );
        else
          emitFailure();
      } else {
        var res = await ChantierRepository().addChantiers(
          nom: nomChantier.value,
          owner: client.value?.nom ?? "",

          adresse: nomChantier.value,
          description: description.value,
          date_emission: dateD,
          dateecheeance: dateF,
          total: int.parse(budget.value),
          status: status.value,
          ouvrier_ids: hommesIds,
          camion_ids: camionsIds,
          machine_ids: materielsIds,
        );
        if (res != null)
          emitSuccess(
            canSubmitAgain: true,
            successResponse: 'Chantier ${nomChantier.value} créé avec succès.',
          );
        else
          emitFailure();
      }
    } catch (e) {
      emitFailure();
    }
  }
}
