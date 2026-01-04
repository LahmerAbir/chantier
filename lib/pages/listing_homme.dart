import 'package:chantier/model/homme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_form_bloc/flutter_form_bloc.dart'; // SUPPRIMÉ

import '../blocs/homme_form_bloc.dart';
import '../model/simple_entity.dart';
import '../repository/chantier_repository.dart';
import '../ui/common/loading.dart';
import '../ui/common/loading_dialog.dart';
// import 'entity_add.dart';

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
    ).push(MaterialPageRoute(builder: (context) => 
        BlocProvider(
          create: (context) => HommeFormBloc(),
          child: const HommeForm()
        )
    ));

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

class HommeForm extends StatefulWidget {
  const HommeForm({super.key});

  @override
  State<HommeForm> createState() => _HommeFormState();
}

class _HommeFormState extends State<HommeForm> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _specialiteController = TextEditingController();
  final TextEditingController _coutJournalierController = TextEditingController(text: "0");
  
  // Pour le dropdown
  String _selectedType = 'ouvrier';

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _specialiteController.dispose();
    _coutJournalierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formBloc = context.read<HommeFormBloc>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Ajouter un Nouvel Employé',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: BlocListener<HommeFormBloc, HommeFormState>(
        listener: (context, state) {
          if (state is HommeFormLoading) {
            LoadingDialog.show(context);
          } else if (state is HommeFormSuccess) {
            LoadingDialog.hide(context);
            ScaffoldMessenger.of(context)
              ..showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.of(context).pop(true);
          } else if (state is HommeFormFailure) {
            LoadingDialog.hide(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
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
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom (Obligatoire)',
                  border: OutlineInputBorder(),
                ),
                onChanged: formBloc.updateNom,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(
                  labelText: 'Prénom (Obligatoire)',
                  border: OutlineInputBorder(),
                ),
                onChanged: formBloc.updatePrenom,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: formBloc.updateEmail,
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                onChanged: formBloc.updateTelephone,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _specialiteController,
                decoration: const InputDecoration(
                  labelText: 'Spécialité',
                  border: OutlineInputBorder(),
                ),
                onChanged: formBloc.updateSpecialite,
              ),
              const SizedBox(height: 15),
              
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                    labelText: 'Type de poste',
                    border: OutlineInputBorder(),
                ),
                items: formBloc.typesDisponibles.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                    formBloc.updateType(newValue);
                  });
                },
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _coutJournalierController,
                decoration: const InputDecoration(
                  labelText: 'Coût Journalier',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: formBloc.updateCoutJournalier,
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () {
                  // Final update just in case
                  formBloc.updateNom(_nomController.text);
                  formBloc.updatePrenom(_prenomController.text);
                  formBloc.updateEmail(_emailController.text);
                  formBloc.updateTelephone(_telephoneController.text);
                  formBloc.updateSpecialite(_specialiteController.text);
                  formBloc.updateCoutJournalier(_coutJournalierController.text);
                  formBloc.updateType(_selectedType);
                  
                  formBloc.submit();
                },
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
