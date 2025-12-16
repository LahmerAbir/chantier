
import 'package:form_bloc/form_bloc.dart';

import '../repository/chantier_repository.dart';

class MaterielFormBloc extends FormBloc<String, String> {

  final nom = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final numeroSerie = TextFieldBloc();
  final type = TextFieldBloc();

  final coutLocationJournalier = TextFieldBloc(
      initialValue: '0',
      validators: [
        FieldBlocValidators.required,
            (value) => double.tryParse(value ?? '') == null ? 'Doit être un nombre valide.' : null,
      ]
  );



  MaterielFormBloc() {
    addFieldBlocs(
      fieldBlocs: [nom, numeroSerie, type, coutLocationJournalier],
    );
  }

  @override
  void onSubmitting() async {
    try {
      var res = await ChantierRepository().addMatr(nom: nom.value,
        type: type.value,
        matricule: numeroSerie.value,
        cout_journalier: int.parse(coutLocationJournalier.value),
      );
      if (res != null)
        emitSuccess(successResponse: 'Machine créé avec succès.');
      else
        emitFailure(failureResponse: 'Erreur lors de la création du Machine');
    }catch(e) {
      emitFailure(failureResponse: 'Erreur lors de la création du Machine');
    }


}
}