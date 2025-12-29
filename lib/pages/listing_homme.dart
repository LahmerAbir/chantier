import 'package:chantier/model/homme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../blocs/homme_form_bloc.dart';
import '../model/simple_entity.dart';
import '../repository/chantier_repository.dart';
import '../ui/common/loading.dart';
import '../ui/common/loading_dialog.dart';
import 'entity_add.dart';

class HommeManagementScreen extends StatefulWidget {
  final String title;
  final String entityName;

  const HommeManagementScreen({
    required this.title,
    required this.entityName,
    super.key,
  });

  @override
  State<HommeManagementScreen> createState() => _EntityManagementScreenState();
}

class _EntityManagementScreenState extends State<HommeManagementScreen> {
  List<Homme> hommes = [];
  List<Camion> camions = [];
  List<Materiel> matriels = [];
  bool isLoading = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (widget.entityName == 'Matériel') {
          matriels = await ChantierRepository().getMateriel() ?? [];
        } else if (widget.entityName == 'Camion') {
          camions = await ChantierRepository().getCamions() ?? [];
        } else {
          hommes = await ChantierRepository().getHommes() ?? [];
        }
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print("exception list chantier $e");
      }
    });

    super.initState();
  }

  void _showAddHommeModal(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const HommeForm()));

    if (result == true) {
      {
        try {
          setState(() {
            isLoading = true;
          });
          hommes = await ChantierRepository().getHommes() ?? [];
          setState(() {
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          print("exception list chantier $e");
        }
      }
    }
  }

  void _deleteEntity(int index) {
    setState(() {
      widget.entityName == 'Matériel'
          ? matriels.removeAt(index)
          : widget.entityName == 'Camion'
          ? camions.removeAt(index)
          : hommes.removeAt(index);
    });
  }

  bool isMobile =
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: Colors.blue.shade700,
                    size: 40,
                  ),
                  onPressed: () {
                    _showAddHommeModal(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            isLoading
                ? Loader()
                : SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: isMobile
                        ? MediaQuery.of(context).size.height * 0.7
                        : MediaQuery.of(context).size.height * 0.8,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.entityName == 'Matériel'
                          ? matriels.length
                          : widget.entityName == 'Camion'
                          ? camions.length
                          : hommes.length,
                      itemBuilder: (context, index) {
                        final entity = widget.entityName == 'Matériel'
                            ? matriels[index]
                            : widget.entityName == 'Camion'
                            ? camions[index]
                            : hommes[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(
                              entity.nom ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text("ID: ${entity.id}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    // TODO: Ouvrir un modal de modification
                                  },
                                ),
                                // Icône de suppression
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteEntity(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class HommeForm extends StatelessWidget {
  const HommeForm({super.key});

  @override
  Widget build(BuildContext context) {
    final formBloc = BlocProvider.of<HommeFormBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Ajouter un Nouvel Employé',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: FormBlocListener<HommeFormBloc, String, String>(
        onSubmitting: (context, state) {
          LoadingDialog.show(context);
        },
        onSuccess: (context, state) {
          LoadingDialog.hide(context);

          ScaffoldMessenger.of(context)
            ..showSnackBar(SnackBar(content: Text(state.successResponse!)));
          Navigator.of(context).pop(true);
        },
        onFailure: (context, state) {
          LoadingDialog.hide(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failureResponse ?? 'Erreur inconnue')),
          );
        },

        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(),
              TextFieldBlocBuilder(
                textFieldBloc: formBloc.nom,
                decoration: const InputDecoration(
                  labelText: 'Nom (Obligatoire)',
                ),
              ),

              TextFieldBlocBuilder(
                textFieldBloc: formBloc.prenom,
                decoration: const InputDecoration(
                  labelText: 'Prénom (Obligatoire)',
                ),
              ),

              TextFieldBlocBuilder(
                textFieldBloc: formBloc.email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),

              TextFieldBlocBuilder(
                textFieldBloc: formBloc.specialite,
                decoration: const InputDecoration(labelText: 'Spécialité'),
              ),
              SizedBox(
                height: 80,
                child: DropdownFieldBlocBuilder<String>(
                  selectFieldBloc: formBloc.type,
                  textStyle: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Type de poste',
                    labelStyle: TextStyle(color: Colors.black)
                  ),
                  itemBuilder: (context, value) => FieldItem(
                    child: Text(value ,style:  TextStyle(color: Colors.black),),
                  ),

                ),
              ),
              TextFieldBlocBuilder(
                textFieldBloc: formBloc.coutJournalier,
                decoration: const InputDecoration(labelText: 'Coût Journalier'),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: formBloc.submit,
                icon: const Icon(Icons.person_add),
                label: const Text('Enregistrer l\'Employé'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
