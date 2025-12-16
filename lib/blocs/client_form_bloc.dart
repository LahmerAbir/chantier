// Fichier: lib/form_blocs/client_form_bloc.dart

import 'package:form_bloc/form_bloc.dart';

import '../model/client.dart';

// Définissons le type de succès comme 'int' (l'ID du client créé) et le type d'erreur comme 'String'
class ClientFormBloc extends FormBloc<int, String> {

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

  // 3. Logique de soumission
  @override
  void onSubmitting() async {
    try {
      // 3.1. Créer l'objet Client à partir des valeurs du formulaire
      final newClientData = Client(
        nom: nom.value,
        email: email.value,
        telephone: telephone.value,
        adresse: adresse.value,
        ville: ville.value,
        pays: pays.value,
      );

      // 3.2. Simulation de l'appel API
      // final int newClientId = await _clientService.createClient(newClientData.toJson());
      // Remplacer par l'ID réel retourné par l'API
      await Future.delayed(const Duration(milliseconds: 800));
      final int newClientId = 99; // ID simulé pour l'exemple

      // 3.3. Succès : émettre l'ID
      emitSuccess(
        successResponse: newClientId,
        canSubmitAgain: true, // Permet de soumettre à nouveau le formulaire
      );

      // 3.4. Réinitialiser les champs pour un nouvel ajout
      nom.updateValue('');
      email.updateValue('');
      // ... autres champs ...

    } catch (e) {
      // Échec : émettre l'erreur
      emitFailure(failureResponse: 'Erreur lors de la création du client: ${e.toString()}');
    }
  }
}