// lib/screens/add_simple_entity_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc_plus/flutter_form_bloc_plus.dart';

import '../blocs/simple_entity_form_bloc.dart';
import '../model/simple_entity.dart';
// import '../blocs/simple_entity_form_bloc.dart';
// import '../models/simple_entity_model.dart';

class AddSimpleEntityModal extends StatelessWidget {
  final String entityName;

  const AddSimpleEntityModal({required this.entityName, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SimpleEntityFormBloc(),
      child: FormBlocListener<SimpleEntityFormBloc, SimpleEntity, String>(
        onSubmitting: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ajout en cours...')));
        },
        onSuccess: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("créé avec succès")));

          Navigator.of(context).pop();
        },
        onFailure: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.failureResponse!)));
        },
        child: Builder(
          builder: (context) {
            final formBloc = BlocProvider.of<SimpleEntityFormBloc>(context);
            return AlertDialog(
              title: Text("Ajouter un $entityName"),
              content:ConstrainedBox( // <-- AJOUTER UN CADRE DE CONTRAINTE
            constraints: BoxConstraints(
            // Limiter la hauteur à 60% de la hauteur totale de l'écran
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Champ Nom complet
                      const Text("Nom complet", style: TextStyle(fontWeight: FontWeight.w500)),
                      TextFieldBlocBuilder(
                        textFieldBloc: formBloc.name,
                        decoration: InputDecoration(
                          hintText: '' ,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: formBloc.submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                  child: Text('Ajouter'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}