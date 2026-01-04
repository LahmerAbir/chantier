import 'package:chantier/model/homme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_form_bloc/flutter_form_bloc.dart'; // SUPPRIMÉ

import '../blocs/camion_form_bloc.dart';
import '../model/simple_entity.dart';
import '../repository/chantier_repository.dart';
import '../ui/common/loading.dart';
import '../ui/common/loading_dialog.dart';
// import 'entity_add.dart'; // Si nécessaire

class CamionManagementScreen extends StatefulWidget {
  final String title;
  final String entityName;

  const CamionManagementScreen({
    required this.title,
    required this.entityName,
    super.key,
  });

  @override
  State<CamionManagementScreen> createState() => _EntityManagementScreenState();
}

class _EntityManagementScreenState extends State<CamionManagementScreen> {
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

  void _showAddCamionModal(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => 
       BlocProvider(
         create: (context) => CamionFormBloc(),
         child: const CamionForm()
       )
    ));

    if (result == true) {
      {
        try {
          setState(() {
            isLoading = true;
          });
          camions = await ChantierRepository().getCamions() ?? [];
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
                    _showAddCamionModal(context);
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

class CamionForm extends StatefulWidget {
  const CamionForm({super.key});

  @override
  State<CamionForm> createState() => _CamionFormState();
}

class _CamionFormState extends State<CamionForm> {
  // Contrôleurs
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _immatriculationController = TextEditingController();
  final TextEditingController _capaciteController = TextEditingController(text: "0");

  @override
  void dispose() {
    _nomController.dispose();
    _immatriculationController.dispose();
    _capaciteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Le bloc est fourni par le parent via BlocProvider
    final formBloc = context.read<CamionFormBloc>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Ajouter un Nouveau Camion',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: BlocListener<CamionFormBloc, CamionFormState>(
        listener: (context, state) {
          if (state is CamionFormLoading) {
            LoadingDialog.show(context);
          } else if (state is CamionFormSuccess) {
            LoadingDialog.hide(context);
            ScaffoldMessenger.of(context)
              ..showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.of(context).pop(true);
          } else if (state is CamionFormFailure) {
            LoadingDialog.hide(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: SingleChildScrollView(
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
                  controller: _immatriculationController,
                  decoration: const InputDecoration(
                    labelText: 'Matricule (Obligatoire)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: formBloc.updateImmatriculation,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _capaciteController,
                  decoration: const InputDecoration(
                    labelText: 'Capacité',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: formBloc.updateCapacite,
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () {
                    // Update final avant submit
                    formBloc.updateNom(_nomController.text);
                    formBloc.updateImmatriculation(_immatriculationController.text);
                    formBloc.updateCapacite(_capaciteController.text);
                    formBloc.submit();
                  },
                  icon: const Icon(Icons.local_shipping),
                  label: const Text('Enregistrer le Camion'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
