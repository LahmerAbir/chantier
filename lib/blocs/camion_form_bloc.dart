import 'package:chantier/repository/chantier_repository.dart';
import 'package:form_bloc/form_bloc.dart';

class CamionFormBloc extends FormBloc<String, String> {
  final nom = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final immatriculation = TextFieldBloc(
    validators: [FieldBlocValidators.required],
  );

  final capaciteCharge = TextFieldBloc(
    initialValue: '0',
    validators: [
      (value) => double.tryParse(value ?? '') == null
          ? 'Doit être un nombre valide.'
          : null,
    ],
  );



  CamionFormBloc() {
    addFieldBlocs(
      fieldBlocs: [
        immatriculation,
        capaciteCharge,
        nom
      ],
    );
  }

  @override
  void onSubmitting() async {

    try {
      var res = await ChantierRepository().addCamion(nom: nom.value,
          capacite: capaciteCharge.value,
          matricule: immatriculation.value);
      if (res != null)
        emitSuccess(successResponse: 'Camion créé avec succès.');
      else
        emitFailure(failureResponse: 'Erreur lors de la création du camion');
    }catch(e) {
      emitFailure(failureResponse: 'Erreur lors de la création du camion');
    }

  }
}
