import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'dart:math';

import '../model/simple_entity.dart';

class SimpleEntityFormBloc extends FormBloc<SimpleEntity, String> {

  final id = TextFieldBloc(initialValue: '');

  final name = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
          (value) => value.length < 3 ? 'Le nom doit contenir au moins 3 caractères.' : null,
    ],
  );

  SimpleEntityFormBloc() {
    addFieldBlocs(fieldBlocs: [name]);
  }

  @override
  void onSubmitting() async {
    final newId = 'ENT-${Random().nextInt(99999).toString().padLeft(5, '0')}';

    final newEntity = SimpleEntity(
      id: newId,
      name: name.value,
    );

    await Future.delayed(const Duration(seconds: 1));

    emitSuccess(
      canSubmitAgain: true,
    );
  }
}