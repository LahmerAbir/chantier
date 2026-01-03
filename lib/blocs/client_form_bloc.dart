// Fichier: lib/form_blocs/client_form_bloc.dart

import 'package:chantier/repository/chantier_repository.dart';
import 'package:flutter_form_bloc_plus/flutter_form_bloc_plus.dart';

import '../model/client.dart';

class ClientFormBloc extends FormBloc<String, String> {

  // 1. Déclaration des FieldBlocs
  final nom = TextFieldBloc(
    validators: [FieldBlocValidators.required],
  );

  final email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  final telephone = TextFieldBloc();
  final adresse = TextFieldBloc();
  final ville = TextFieldBloc();
  final pays = TextFieldBloc();

  ClientFormBloc() {
    // 2. Enregistrement des FieldBlocs
    addFieldBlocs(
      fieldBlocs: [
        nom,
        email,
        telephone,
        adresse,
        ville,
        pays,
      ],
    );
  }

  @override
  void onSubmitting() async {
    try {
      final newClientData = Client(
        nom: nom.value,
        email: email.value,
        telephone: telephone.value,
        adresse: adresse.value,
        ville: ville.value,
        pays: pays.value,
      );

      var res = await ChantierRepository().addClient(nom: nom.value,
        email: email.value,
        telephone: telephone.value,
        adresse: adresse.value,
        ville: ville.value,
        pays: pays.value,);
      if (res != null)
        emitSuccess(
          canSubmitAgain: true,
          successResponse: 'Client créé avec succès.',

        );
      else
        emitFailure(failureResponse: 'Erreur lors de la création du client');
    } catch (e) {
      emitFailure(failureResponse: 'Erreur lors de la création du client: ${e
          .toString()}');
    }
  }
}