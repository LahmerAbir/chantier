// Réutilisation des classes Resource et ChantierFormBloc
// ...

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chantier/pages/ressource_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../blocs/chantier_form_bloc.dart';
import '../model/chantier.dart';
import '../model/client.dart';
import '../model/homme.dart';
import '../repository/chantier_repository.dart';
import '../ui/common/loading.dart';
import '../ui/common/loading_dialog.dart';

class NewProjectDragDropScreen extends StatefulWidget {
  const NewProjectDragDropScreen({super.key, this.chantierToEdit});

  final Chantier? chantierToEdit;

  @override
  State<NewProjectDragDropScreen> createState() =>
      _NewProjectDragDropScreenState();
}

class _NewProjectDragDropScreenState extends State<NewProjectDragDropScreen> {
  List<Homme> _availableHommes = [];
  List<Materiel> _availableMateriels = [];
  List<Camion> _availableCamions = [];

  List<Homme> _assignedHommes = [];
  List<Materiel> _assignedMateriels = [];
  List<Camion> _assignedCamions = [];
  List<Client> clients = [];
  late List<RessourceBase> _allResources;

  List<Homme> _initialHommes = [];
  List<Materiel> _initialMateriels = [];
  List<Camion> _initialCamions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        var hommes = await ChantierRepository().getHommes() ?? [];
        var machines = await ChantierRepository().getMateriel() ?? [];
        var camions = await ChantierRepository().getCamions() ?? [];
        clients = await ChantierRepository().getClients() ?? [];
        setState(() {
          _initialHommes = hommes;
          _availableHommes = hommes;
          _initialMateriels = machines;
          _availableMateriels = machines;
          _initialCamions = camions;
          _availableCamions = camions;
          isLoading = false;
        });
      } catch (e) {
        print("exception add chantier $e");
        setState(() {
          isLoading = false;
        });
      }
    });

    _allResources = [
      ..._initialHommes,
      ..._initialMateriels,
      ..._initialCamions,
    ];

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
    return isLoading
        ? Loader()
        : BlocProvider(
            create: (context) => ChantierFormBloc(
              initialChantier: widget.chantierToEdit,
              availableClients: clients,
              tousLesHommes: _initialHommes,
            ),
            child: Builder(
              builder: (context) {
                final chantierFormBloc = BlocProvider.of<ChantierFormBloc>(
                  context,
                );
                chantierFormBloc.client.updateItems(clients);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateAssignedResources(chantierFormBloc);
                });

                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      widget.chantierToEdit != null
                          ? "Modifier le Chantier"
                          : "Créer un nouveau chantier",
                      style: TextStyle(fontSize: isMobile ? 16 : 20),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),
                  body: FormBlocListener<ChantierFormBloc, String, String>(
                    onSubmitting: (context, state) {
                      LoadingDialog.show(context);
                    },
                    onSuccess: (context, state) {
                      LoadingDialog.hide(context);

                      ScaffoldMessenger.of(context)..showSnackBar(
                        SnackBar(content: Text(state.successResponse!)),
                      );
                      Navigator.of(context).pop(true);
                    },

                    onFailure: (context, state) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text("une erreur s'est produite"),
                            backgroundColor: Colors.red,
                          ),
                        );
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
                                const Text(
                                  "Informations du projet",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                _buildTextField(
                                  chantierFormBloc.nomChantier,
                                  "Nom du chantier",
                                  "Ex: Résidence Le Parc",
                                ),
                                const SizedBox(height: 15),
                                isLoading
                                    ? Loader()
                                    : DropdownFieldBlocBuilder<Client>(
                                        selectFieldBloc:
                                            chantierFormBloc.client,
                                        itemBuilder: (context, client) =>
                                            FieldItem(
                                              child: Text(
                                                client.nom ?? 'Client sans nom',
                                              ),
                                            ),

                                        decoration: const InputDecoration(
                                          labelText: 'Client',
                                          hintText: 'Sélectionnez le client',
                                        ),
                                      ),
                                const SizedBox(height: 15),
                                _buildLabel('Chef de projet'),

                                DropdownFieldBlocBuilder<Homme>(
                                  selectFieldBloc: chantierFormBloc.chefProjet,
                                  decoration: InputDecoration(
                                    labelText: 'Chef de Projet',
                                  ),
                                  itemBuilder: (context, homme) => FieldItem(
                                    child: Text("${homme.prenom} ${homme.nom}"),
                                  ),
                                ),
                                const SizedBox(height: 15),

                                _buildLabel('Status'),
                                DropdownFieldBlocBuilder<String>(
                                  selectFieldBloc: chantierFormBloc.status,
                                  decoration: _inputDecoration(
                                    hintText: "Sélectionner un statut",
                                  ),
                                  itemBuilder: (context, value) =>
                                      FieldItem(child: Text(value)),
                                ),
                                const SizedBox(height: 15),

                                _buildTextField(
                                  chantierFormBloc.budget,
                                  "Budget (Total)",
                                  "Ex: 450000 €",
                                ),
                                const SizedBox(height: 15),

                                // Dates
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateField(
                                        chantierFormBloc.dateDebut,
                                        "Date début",
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: _buildDateField(
                                        chantierFormBloc.dateFin,
                                        "Date fin",
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                _buildTextField(
                                  chantierFormBloc.description,
                                  "Description",
                                  "",
                                  maxline: 3,
                                ),
                                const SizedBox(height: 30),

                                const Text(
                                  "Ressources assignées",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  "Glissez-déposez des ressources ici",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                isMobile
                                    ? InkWell(
                                        onTap: () {
                                          if (!(_initialHommes.isEmpty &&
                                              _initialMateriels.isEmpty &&
                                              _availableCamions.isEmpty))
                                            _openTapToSelectModal(
                                              chantierFormBloc,
                                            );
                                        }, // Appelle la méthode d'ouverture de la modale
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: assignedList.isEmpty
                                              ? Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .people_alt_outlined,
                                                        size: 40,
                                                        color: Colors
                                                            .grey
                                                            .shade400,
                                                      ),
                                                      const Text(
                                                        "Aucune ressource assignée. Cliquez sur Modifier.",
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Wrap(
                                                  spacing: 10,
                                                  runSpacing: 10,
                                                  children: assignedList.map((
                                                    res,
                                                  ) {
                                                    return Chip(
                                                      avatar: Icon(
                                                        res.icon,
                                                        size: 16,
                                                      ),
                                                      label: Text(
                                                        res.nom ?? "",
                                                      ),
                                                      onDeleted: () {
                                                        _openTapToSelectModal(
                                                          chantierFormBloc,
                                                        );
                                                      },
                                                      deleteIcon: const Icon(
                                                        Icons.edit,
                                                        size: 16,
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                        ),
                                      )
                                    : DragTarget<RessourceBase>(
                                        onWillAccept: (data) => true,
                                        onAccept: (resource) {
                                          setState(() {
                                            if (resource is Homme) {
                                              _availableHommes.removeWhere(
                                                (h) => h.id == resource.id,
                                              );
                                              _assignedHommes.add(resource);
                                            } else if (resource is Materiel) {
                                              _availableMateriels.removeWhere(
                                                (m) => m.id == resource.id,
                                              );
                                              _assignedMateriels.add(resource);
                                            } else if (resource is Camion) {
                                              _availableCamions.removeWhere(
                                                (c) => c.id == resource.id,
                                              );
                                              _assignedCamions.add(resource);
                                            }

                                            _updateAssignedResources(
                                              chantierFormBloc,
                                            ); // Mettre à jour le bloc
                                          });
                                        },
                                        builder: (context, candidateData, rejectedData) {
                                          final assignedList =
                                              _getAllAssignedResources();

                                          return Container(
                                            width: double.infinity,
                                            constraints: const BoxConstraints(
                                              minHeight: 150,
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              // ...
                                              border: Border.all(
                                                color: candidateData.isNotEmpty
                                                    ? Colors.blue
                                                    : Colors.grey.shade300,
                                                style: BorderStyle.solid,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),

                                            child: assignedList.isEmpty
                                                ? Center(
                                                    child: Column(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .add_circle_outline,
                                                          size: 40,
                                                          color: Colors
                                                              .grey
                                                              .shade400,
                                                        ),
                                                        const Text(
                                                          "Déposez ici",
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Wrap(
                                                    spacing: 10,
                                                    runSpacing: 10,
                                                    children: assignedList.map((
                                                      res,
                                                    ) {
                                                      return Chip(
                                                        avatar: Icon(
                                                          res.icon,
                                                          size: 16,
                                                        ),
                                                        label: Text(
                                                          res.nom ?? "",
                                                        ),
                                                        onDeleted: () {
                                                          setState(() {
                                                            if (res is Homme) {
                                                              _assignedHommes
                                                                  .removeWhere(
                                                                    (h) =>
                                                                        h.id ==
                                                                        res.id,
                                                                  );
                                                              _availableHommes
                                                                  .add(res);
                                                            } else if (res
                                                                is Materiel) {
                                                              _assignedMateriels
                                                                  .removeWhere(
                                                                    (m) =>
                                                                        m.id ==
                                                                        res.id,
                                                                  );
                                                              _availableMateriels
                                                                  .add(res);
                                                            } else if (res
                                                                is Camion) {
                                                              _assignedCamions
                                                                  .removeWhere(
                                                                    (c) =>
                                                                        c.id ==
                                                                        res.id,
                                                                  );
                                                              _availableCamions
                                                                  .add(res);
                                                            }
                                                            _updateAssignedResources(
                                                              chantierFormBloc,
                                                            ); // Mettre à jour le bloc
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
                                    onPressed: chantierFormBloc.submit,
                                    // Utilise la fonction submit du FormBloc
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      "Créer le chantier",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (!isMobile)
                          isLoading
                              ? Loader()
                              : _availableHommes.isNotEmpty
                              ? Container(
                                  width: 300,
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Ouvriers",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Container(
                                                  width: 250,
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  color: Colors.white,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        res.icon,
                                                        color: Colors.blue,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(res.nom ?? ""),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              childWhenDragging: Opacity(
                                                opacity: 0.5,
                                                child: _buildResourceCard(res),
                                              ),
                                              child: _buildResourceCard(res),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Center(child: Text("Liste est vide ")),
                        if (!isMobile)
                          Container(
                            height: MediaQuery.of(context).size.height,
                            width: 1,
                            color: Colors.grey,
                          ),
                        if (!isMobile)
                          isLoading
                              ? Loader()
                              : _availableMateriels.isNotEmpty
                              ? Container(
                                  width: 300,
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Matériel",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: _availableMateriels.length,
                                          itemBuilder: (context, index) {
                                            final res =
                                                _availableMateriels[index];
                                            return Draggable<Materiel>(
                                              data: res,
                                              feedback: Material(
                                                elevation: 4,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Container(
                                                  width: 250,
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  color: Colors.white,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        res.icon,
                                                        color: Colors.blue,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(res.nom ?? ""),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              childWhenDragging: Opacity(
                                                opacity: 0.5,
                                                child: _buildResourceCard(res),
                                              ),
                                              child: _buildResourceCard(res),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Center(child: Text("Liste est vide")),
                        if (!isMobile)
                          Container(
                            height: MediaQuery.of(context).size.height,
                            width: 1,
                            color: Colors.grey,
                          ),
                        if (!isMobile)
                          isLoading
                              ? Loader()
                              : _availableCamions.isNotEmpty
                              ? Container(
                                  width: 300,
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Camions",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: _availableCamions.length,
                                          itemBuilder: (context, index) {
                                            final res =
                                                _availableCamions[index];
                                            return Draggable<Camion>(
                                              data: res,
                                              feedback: Material(
                                                elevation: 4,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Container(
                                                  width: 250,
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  color: Colors.white,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        res.icon,
                                                        color: Colors.blue,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(res.nom ?? ""),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              childWhenDragging: Opacity(
                                                opacity: 0.5,
                                                child: _buildResourceCard(res),
                                              ),
                                              child: _buildResourceCard(res),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Center(child: Text("Liste est vide")),
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

    final List<RessourceBase>? finalSelection = await Navigator.of(context)
        .push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => ResourceSelectionModal(
              availableResources: allResources,
              initialSelection: currentAssigned,
            ),
          ),
        );

    if (finalSelection != null) {
      _processFinalSelection(finalSelection, chantierFormBloc);
    }
  }

  void _processFinalSelection(
    List<RessourceBase> finalSelection,
    ChantierFormBloc,
  ) {
    setState(() {
      final Set<int?> finalSetIds = finalSelection.map((r) => r.id).toSet();

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
              SizedBox(
                width: 100,
                child: AutoSizeText(
                  res.nom ?? "",
                  maxLines: 3,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                labelType,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
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

  Widget _buildTextField(
    TextFieldBloc bloc,
    String label,
    String hint, {
    int maxline = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFieldBlocBuilder(
          textFieldBloc: bloc,
          decoration: _inputDecoration(hintText: hint),
          maxLines: maxline,
        ),
      ],
    );
  }

  Widget _buildDateField(
    InputFieldBloc<DateTime?, dynamic> bloc,
    String label,
  ) {
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
            suffixIcon: const Icon(
              Icons.calendar_today,
              size: 20,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
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
