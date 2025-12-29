
import 'package:form_bloc/form_bloc.dart';

import '../model/homme.dart';
import '../repository/chantier_repository.dart';

class HommeFormBloc extends FormBloc<String, String> {

  final nom = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final prenom = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final email = TextFieldBloc(validators: [FieldBlocValidators.email]);
  final telephone = TextFieldBloc();
  final specialite = TextFieldBloc();
  final SelectFieldBloc<String, dynamic> type = SelectFieldBloc(
    items: ['ouvrier', 'chef projet', 'désamianteur', 'conducteur'],
    initialValue: 'ouvrier',
    validators: [FieldBlocValidators.required],
  );
  final coutJournalier = TextFieldBloc(
      initialValue: '0',
      validators: [
        FieldBlocValidators.required,
            (value) {
          // Valide si la valeur est un nombre décimal ou entier valide
          if (double.tryParse(value ?? '') == null) {
            return 'Doit être un nombre valide.';
          }
          return null;
        },
      ]
  );



  HommeFormBloc() {
    addFieldBlocs(
      fieldBlocs: [nom, prenom, email, telephone, specialite, type ,coutJournalier],
    );
  }

  @override
  void onSubmitting() async {
    try {


      try {
        var res = await ChantierRepository().addHomme(nom: nom.value,
          prenom: prenom.value,
          email: email.value,
          telephone: telephone.value,
          specialite: specialite.value,
          type: type.value,
         );
        if (res != null)
          emitSuccess(successResponse: 'Homme créé avec succès.');
        else
          emitFailure(failureResponse: 'Erreur lors de la création du Homme');
      }catch(e) {
        emitFailure(failureResponse: 'Erreur lors de la création du Homme');
      }

    } catch (e) {
      emitFailure(failureResponse: 'Échec de l\'ajout de l\'employé: ${e.toString()}');
    }
  }
}