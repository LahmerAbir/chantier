// Réutilisation des classes Resource et ChantierFormBloc
// ...

import 'package:chantier/pages/ressource_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../blocs/chantier_form_bloc.dart';
import '../model/homme.dart';

class NewProjectDragDropScreen extends StatefulWidget {
  const NewProjectDragDropScreen({super.key});

  @override
  State<NewProjectDragDropScreen> createState() =>
      _NewProjectDragDropScreenState();
}

class _NewProjectDragDropScreenState extends State<NewProjectDragDropScreen> {
  List<Homme> _availableHommes = [Homme("1", "Pierre Martin"), Homme("2", "Marc Dubois")];
  List<Materiel> _availableMateriels = [Materiel("4", "Grue Mobile 50T"), Materiel("5", "Pelleteuse CAT")];
  List<Camion> _availableCamions = [Camion("6", "Camion Benne A"), Camion("7", "Camion Citerne")];

  List<Homme> _assignedHommes = [];
  List<Materiel> _assignedMateriels = [];
  List<Camion> _assignedCamions = [];
  late List<RessourceBase> _allResources;

  final List<Homme> _initialHommes = [
    Homme('H001', 'Jean Dupont'),
    Homme('H002', 'Marie Curie'),
  ];
  final List<Materiel> _initialMateriels = [
    Materiel('M001', 'Bétonnière 500L'),
    Materiel('M002', 'Mini-Pelle CAT'),
  ];
  final List<Camion> _initialCamions = [
    Camion('C001', 'Renault T450'),
  ];

  @override
  void initState() {
    super.initState();

    _allResources = [..._initialHommes, ..._initialMateriels, ..._initialCamions];

    _availableHommes = List.from(_initialHommes);
    _availableMateriels = List.from(_initialMateriels);
    _availableCamions = List.from(_initialCamions);
  }

  List<RessourceBase> _getAllAssignedResources() {
    return [..._assignedHommes, ..._assignedMateriels, ..._assignedCamions];
  }

  void _updateAssignedResources(ChantierFormBloc bloc) {
    bloc.ressourcesAssigned.updateValue(_getAllAssignedResources());
  }
  bool isMobile =
      defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    final assignedList = _getAllAssignedResources();
    return BlocProvider(
      create: (context) => ChantierFormBloc(),
      child: Builder(
        builder: (context) {
          final chantierFormBloc = BlocProvider.of<ChantierFormBloc>(context);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateAssignedResources(chantierFormBloc);
          });

          return Scaffold(
            appBar: AppBar(
              title:  Text("Créer un nouveau chantier" , style: TextStyle( fontSize: isMobile ? 16 : 20 ),),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            body: FormBlocListener<ChantierFormBloc, String, String>(
              onSubmitting: (context, state) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('Création en cours...')));
              },
              onSuccess: (context, state) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(state.successResponse!)));
                Navigator.of(context).pop();
              },
              onFailure: (context, state) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(state.failureResponse!)));
              },
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Informations du projet",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),

                          _buildTextField(chantierFormBloc.nomChantier, "Nom du chantier", "Ex: Résidence Le Parc"),
                          const SizedBox(height: 15),
                          _buildTextField(chantierFormBloc.client, "Client", "Ex: Société Immobilière"),
                          const SizedBox(height: 15),

                          _buildLabel('Status'),
                          DropdownFieldBlocBuilder<String>(
                            selectFieldBloc: chantierFormBloc.status,
                            decoration: _inputDecoration(hintText: "Sélectionner un statut"),
                            itemBuilder: (context, value) => FieldItem(child: Text(value)),
                          ),
                          const SizedBox(height: 15),

                          _buildTextField(chantierFormBloc.budget, "Budget (Total)", "Ex: 450000 €"),
                          const SizedBox(height: 15),

                          // Dates
                          Row(
                            children: [
                              Expanded(child: _buildDateField(chantierFormBloc.dateDebut, "Date début")),
                              const SizedBox(width: 15),
                              Expanded(child: _buildDateField(chantierFormBloc.dateFin, "Date fin")),
                            ],
                          ),
                          const SizedBox(height: 30),

                          const Text("Ressources assignées",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text("Glissez-déposez des ressources ici",
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 10),

                        isMobile ? InkWell(
                          onTap:(){ _openTapToSelectModal(chantierFormBloc);}, // Appelle la méthode d'ouverture de la modale
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: assignedList.isEmpty
                                ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_alt_outlined, size: 40, color: Colors.grey.shade400),
                                  const Text("Aucune ressource assignée. Cliquez sur Modifier.")
                                ],
                              ),
                            )
                                : Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: assignedList.map((res) {
                                return Chip(
                                  avatar: Icon(res.icon, size: 16),
                                  label: Text(res.name),
                                  // Optionnel: Ajouter un onDeleted pour retirer rapidement
                                  onDeleted: () {
                                    // Ouvrir la modale pour la modification complète si c'est plus clair
                                    _openTapToSelectModal(chantierFormBloc);
                                  },
                                  deleteIcon: const Icon(Icons.edit, size: 16),
                                );
                              }).toList(),
                            ),
                          ),
                        ) :   DragTarget<RessourceBase>(
                            onWillAccept: (data) => true,
                            onAccept: (resource) {
                              setState(() {
                                if (resource is Homme) {
                                  _availableHommes.removeWhere((h) => h.id == resource.id);
                                  _assignedHommes.add(resource);
                                } else if (resource is Materiel) {
                                  _availableMateriels.removeWhere((m) => m.id == resource.id);
                                  _assignedMateriels.add(resource);
                                } else if (resource is Camion) {
                                  _availableCamions.removeWhere((c) => c.id == resource.id);
                                  _assignedCamions.add(resource);
                                }

                                _updateAssignedResources(chantierFormBloc); // Mettre à jour le bloc
                              });
                            },
                            builder: (context, candidateData, rejectedData) {
                              final assignedList = _getAllAssignedResources();

                              return Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(minHeight: 150),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  // ...
                                  border: Border.all(
                                    color: candidateData.isNotEmpty ? Colors.blue : Colors.grey.shade300,
                                    style: BorderStyle.solid,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),

                                child: assignedList.isEmpty
                                    ? Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.add_circle_outline, size: 40, color: Colors.grey.shade400),
                                      const Text("Déposez ici")
                                    ],
                                  ),
                                )
                                    : Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: assignedList.map((res) {
                                    return Chip(
                                      avatar: Icon(res.icon, size: 16),
                                      label: Text(res.name),
                                      onDeleted: () {
                                        setState(() {
                                          if (res is Homme) {
                                            _assignedHommes.removeWhere((h) => h.id == res.id);
                                            _availableHommes.add(res);
                                          } else if (res is Materiel) {
                                            _assignedMateriels.removeWhere((m) => m.id == res.id);
                                            _availableMateriels.add(res);
                                          } else if (res is Camion) {
                                            _assignedCamions.removeWhere((c) => c.id == res.id);
                                            _availableCamions.add(res);
                                          }
                                          _updateAssignedResources(chantierFormBloc); // Mettre à jour le bloc
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: chantierFormBloc.submit, // Utilise la fonction submit du FormBloc
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                              ),
                              child: const Text("Créer le chantier", style: TextStyle(color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  if (!isMobile)
                    Container(
                      width: 300,
                      color: Colors.white,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Ouvriers",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _availableHommes.length,
                              itemBuilder: (context, index) {
                                final res = _availableHommes[index];
                                return Draggable<Homme>(
                                  data: res,
                                  feedback: Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 250,
                                      padding: const EdgeInsets.all(12),
                                      color: Colors.white,
                                      child: Row(
                                        children: [
                                          Icon(res.icon, color: Colors.blue),
                                          const SizedBox(width: 10),
                                          Text(res.name),
                                        ],
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(opacity: 0.5, child: _buildResourceCard(res)),
                                  child: _buildResourceCard(res),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  if (!isMobile)
                    Container(height: MediaQuery.of(context).size.height,width: 1 , color: Colors.grey,),
                  if (!isMobile)
                    Container(
                      width: 300,
                      color: Colors.white,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Matériel",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _availableMateriels.length,
                              itemBuilder: (context, index) {
                                final res = _availableMateriels[index];
                                return Draggable<Materiel>(
                                  data: res,
                                  feedback: Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 250,
                                      padding: const EdgeInsets.all(12),
                                      color: Colors.white,
                                      child: Row(
                                        children: [
                                          Icon(res.icon, color: Colors.blue),
                                          const SizedBox(width: 10),
                                          Text(res.name),
                                        ],
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(opacity: 0.5, child: _buildResourceCard(res)),
                                  child: _buildResourceCard(res),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  if (!isMobile)
                    Container(height: MediaQuery.of(context).size.height,width: 1 , color: Colors.grey,),
                  if (!isMobile)
                    Container(
                      width: 300,
                      color: Colors.white,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Camions",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _availableCamions.length,
                              itemBuilder: (context, index) {
                                final res = _availableCamions[index];
                                return Draggable<Camion>(
                                  data: res,
                                  feedback: Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 250,
                                      padding: const EdgeInsets.all(12),
                                      color: Colors.white,
                                      child: Row(
                                        children: [
                                          Icon(res.icon, color: Colors.blue),
                                          const SizedBox(width: 10),
                                          Text(res.name),
                                        ],
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(opacity: 0.5, child: _buildResourceCard(res)),
                                  child: _buildResourceCard(res),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  void _openTapToSelectModal(ChantierFormBloc chantierFormBloc) async {
    final List<RessourceBase> allResources = [
      ..._availableHommes,
      ..._assignedHommes,
      ..._availableMateriels,
      ..._assignedMateriels,
      ..._availableCamions,
      ..._assignedCamions,
    ];

    final List<RessourceBase> currentAssigned = [
      ..._assignedHommes,
      ..._assignedMateriels,
      ..._assignedCamions,
    ];

    final List<RessourceBase>? finalSelection = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ResourceSelectionModal(
          availableResources: allResources,
          initialSelection: currentAssigned,
        ),
      ),
    );

    if (finalSelection != null) {
      _processFinalSelection(finalSelection,chantierFormBloc);
    }
  }

  void _processFinalSelection(List<RessourceBase> finalSelection , ChantierFormBloc ) {
    setState(() {
      final Set<String> finalSetIds = finalSelection.map((r) => r.id).toSet();

      _assignedHommes.clear();
      _assignedMateriels.clear();
      _assignedCamions.clear();
      _availableHommes.clear();
      _availableMateriels.clear();
      _availableCamions.clear();

      for (final res in _allResources) {
        if (finalSetIds.contains(res.id)) {
          if (res is Homme) {
            _assignedHommes.add(res);
          } else if (res is Materiel) {
            _assignedMateriels.add(res);
          } else if (res is Camion) {
            _assignedCamions.add(res);
          }
        } else {
          if (res is Homme) {
            _availableHommes.add(res);
          } else if (res is Materiel) {
            _availableMateriels.add(res);
          } else if (res is Camion) {
            _availableCamions.add(res);
          }
        }
      }

      _updateAssignedResources(ChantierFormBloc);
    });
  }
  Widget _buildResourceCard(RessourceBase res) {
    final Color primaryColor;
    final String labelType;

    if (res is Homme) {
      primaryColor = Colors.blue.shade800;
      labelType = "Ouvrier";
    } else if (res is Materiel) {
      primaryColor = Colors.orange.shade800;
      labelType = "Engin";
    } else if (res is Camion) {
      primaryColor = Colors.red.shade800;
      labelType = "Véhicule";
    } else {
      primaryColor = Colors.grey.shade800;
      labelType = "Inconnu";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(res.icon, size: 16, color: primaryColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(res.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(labelType, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.drag_indicator, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(TextFieldBloc bloc, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFieldBlocBuilder(
          textFieldBloc: bloc,
          decoration: _inputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildDateField(InputFieldBloc<DateTime?, dynamic> bloc, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        DateTimeFieldBlocBuilder(
          dateTimeFieldBloc: bloc,
          textStyle: TextStyle(fontSize: isMobile ? 12 : 18),
          format: DateFormat('dd/MM/yyyy'),
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          decoration: _inputDecoration(
            hintText: 'JJ/MM/AAAA',
            suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 1.5),
      ),
    );
  }


}