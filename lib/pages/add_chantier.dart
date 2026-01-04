import 'package:auto_size_text/auto_size_text.dart';
import 'package:chantier/pages/ressource_modal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/chantier_form_bloc.dart';
import '../model/chantier.dart';
import '../model/client.dart';
import '../model/homme.dart';
import '../model/simple_entity.dart';
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
  // Contrôleurs
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateDebutController = TextEditingController();
  final TextEditingController _dateFinController = TextEditingController();

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
  
  // Valeurs sélectionnées
  Client? _selectedClient;
  Homme? _selectedChefProjet;
  String _selectedStatus = 'en attente';
  DateTime? _selectedDateDebut;
  DateTime? _selectedDateFin;

  @override
  void initState() {
    super.initState();
    // Init controllers with edit data if exists
    if (widget.chantierToEdit != null) {
      _nomController.text = widget.chantierToEdit!.nom ?? '';
      _budgetController.text = widget.chantierToEdit!.total.toString();
      _descriptionController.text = widget.chantierToEdit!.description ?? '';
      _selectedStatus = widget.chantierToEdit!.status ?? 'en attente';
      
      if (widget.chantierToEdit!.dateEmission != null) {
        try {
           _selectedDateDebut = DateTime.parse(widget.chantierToEdit!.dateEmission!);
           _dateDebutController.text = DateFormat('dd/MM/yyyy').format(_selectedDateDebut!);
        } catch (_) {}
      }
      if (widget.chantierToEdit!.dateEcheance != null) {
        try {
           _selectedDateFin = DateTime.parse(widget.chantierToEdit!.dateEcheance!);
           _dateFinController.text = DateFormat('dd/MM/yyyy').format(_selectedDateFin!);
        } catch (_) {}
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        var hommes = await ChantierRepository().getHommes() ?? [];
        var machines = await ChantierRepository().getMateriel() ?? [];
        var camions = await ChantierRepository().getCamions() ?? [];
        clients = await ChantierRepository().getClients() ?? [];
        
        setState(() {
          _initialHommes = hommes;
          _availableHommes = List.from(hommes);
          _initialMateriels = machines;
          _availableMateriels = List.from(machines);
          _initialCamions = camions;
          _availableCamions = List.from(camions);
          
          if (widget.chantierToEdit?.clientId != null) {
             try {
               _selectedClient = clients.firstWhere((c) => c.id == widget.chantierToEdit!.clientId);
             } catch (_) {}
          }
          
          // Récupération des ressources assignées si edit
          if (widget.chantierToEdit != null) {
             // Logique pour retrouver les ressources assignées (si l'API renvoie les IDs)
             // Ici on suppose que le repository renvoie déjà les objets complets ou on fait avec ce qu'on a
          }
          
          isLoading = false;
        });
      } catch (e) {
        print("exception add chantier $e");
        setState(() {
          isLoading = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _nomController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    _dateDebutController.dispose();
    _dateFinController.dispose();
    super.dispose();
  }

  List<RessourceBase> _getAllAssignedResources() {
    return [..._assignedHommes, ..._assignedMateriels, ..._assignedCamions];
  }

  void _updateAssignedResources(ChantierFormBloc bloc) {
    bloc.updateRessources(_getAllAssignedResources());
  }

  bool isMobile =
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedDateDebut = picked;
          _dateDebutController.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _selectedDateFin = picked;
          _dateFinController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

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
                final chantierFormBloc = context.read<ChantierFormBloc>();
                
                // Init bloc values from local state (important for dropdowns/dates)
                if (_selectedClient != null) chantierFormBloc.updateClient(_selectedClient);
                if (_selectedDateDebut != null) chantierFormBloc.updateDateDebut(_selectedDateDebut);
                if (_selectedDateFin != null) chantierFormBloc.updateDateFin(_selectedDateFin);
                if (_selectedStatus.isNotEmpty) chantierFormBloc.updateStatus(_selectedStatus);

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
                  body: BlocListener<ChantierFormBloc, ChantierFormState>(
                    listener: (context, state) {
                      if (state is ChantierFormLoading) {
                        LoadingDialog.show(context);
                      } else if (state is ChantierFormSuccess) {
                        LoadingDialog.hide(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message)),
                        );
                        Navigator.of(context).pop(true);
                      } else if (state is ChantierFormFailure) {
                        LoadingDialog.hide(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error), backgroundColor: Colors.red),
                        );
                      }
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

                                TextFormField(
                                  controller: _nomController,
                                  decoration: _inputDecoration(hintText: "Ex: Résidence Le Parc", labelText: "Nom du chantier"),
                                  onChanged: chantierFormBloc.updateNomChantier,
                                ),
                                const SizedBox(height: 15),
                                
                                DropdownButtonFormField<Client>(
                                  value: _selectedClient,
                                  decoration: _inputDecoration(hintText: "Sélectionnez le client", labelText: "Client"),
                                  items: clients.map((Client client) {
                                    return DropdownMenuItem<Client>(
                                      value: client,
                                      child: Text(client.nom ?? 'Client sans nom'),
                                    );
                                  }).toList(),
                                  onChanged: (Client? newValue) {
                                    setState(() {
                                      _selectedClient = newValue;
                                      chantierFormBloc.updateClient(newValue);
                                    });
                                  },
                                ),
                                const SizedBox(height: 15),
                                
                                _buildLabel('Chef de projet'),
                                DropdownButtonFormField<Homme>(
                                  value: _selectedChefProjet,
                                  decoration: _inputDecoration(hintText: "Chef de Projet", labelText: "Chef de Projet"),
                                  items: _initialHommes.map((Homme homme) {
                                    return DropdownMenuItem<Homme>(
                                      value: homme,
                                      child: Text("${homme.prenom} ${homme.nom}"),
                                    );
                                  }).toList(),
                                  onChanged: (Homme? newValue) {
                                    setState(() {
                                      _selectedChefProjet = newValue;
                                      chantierFormBloc.updateChefProjet(newValue);
                                    });
                                  },
                                ),
                                const SizedBox(height: 15),

                                _buildLabel('Status'),
                                DropdownButtonFormField<String>(
                                  value: _selectedStatus,
                                  decoration: _inputDecoration(hintText: "Statut", labelText: "Statut"),
                                  items: chantierFormBloc.statusItems.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedStatus = newValue!;
                                      chantierFormBloc.updateStatus(newValue);
                                    });
                                  },
                                ),
                                const SizedBox(height: 15),

                                TextFormField(
                                  controller: _budgetController,
                                  decoration: _inputDecoration(hintText: "Ex: 450000 €", labelText: "Budget (Total)"),
                                  keyboardType: TextInputType.number,
                                  onChanged: chantierFormBloc.updateBudget,
                                ),
                                const SizedBox(height: 15),

                                // Dates
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _selectDate(context, true),
                                        child: IgnorePointer(
                                          child: TextFormField(
                                            controller: _dateDebutController,
                                            decoration: _inputDecoration(
                                              hintText: 'JJ/MM/AAAA', 
                                              labelText: "Date début",
                                              suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _selectDate(context, false),
                                        child: IgnorePointer(
                                          child: TextFormField(
                                            controller: _dateFinController,
                                            decoration: _inputDecoration(
                                              hintText: 'JJ/MM/AAAA', 
                                              labelText: "Date fin",
                                              suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 3,
                                  decoration: _inputDecoration(hintText: "", labelText: "Description"),
                                  onChanged: chantierFormBloc.updateDescription,
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
                                          _openTapToSelectModal(chantierFormBloc);
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: assignedList.isEmpty
                                              ? Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.people_alt_outlined, size: 40, color: Colors.grey.shade400),
                                                      const Text("Aucune ressource assignée. Cliquez sur Modifier."),
                                                    ],
                                                  ),
                                                )
                                              : Wrap(
                                                  spacing: 10,
                                                  runSpacing: 10,
                                                  children: assignedList.map((res) {
                                                    return Chip(
                                                      avatar: Icon(res.icon, size: 16),
                                                      label: Text(res.nom ?? ""),
                                                      onDeleted: () {
                                                         _openTapToSelectModal(chantierFormBloc);
                                                      },
                                                      deleteIcon: const Icon(Icons.edit, size: 16),
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
                                              _availableHommes.removeWhere((h) => h.id == resource.id);
                                              _assignedHommes.add(resource);
                                            } else if (resource is Materiel) {
                                              _availableMateriels.removeWhere((m) => m.id == resource.id);
                                              _assignedMateriels.add(resource);
                                            } else if (resource is Camion) {
                                              _availableCamions.removeWhere((c) => c.id == resource.id);
                                              _assignedCamions.add(resource);
                                            }
                                            _updateAssignedResources(chantierFormBloc);
                                          });
                                        },
                                        builder: (context, candidateData, rejectedData) {
                                          final assignedList = _getAllAssignedResources();

                                          return Container(
                                            width: double.infinity,
                                            constraints: const BoxConstraints(minHeight: 150),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
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
                                                        const Text("Déposez ici"),
                                                      ],
                                                    ),
                                                  )
                                                : Wrap(
                                                    spacing: 10,
                                                    runSpacing: 10,
                                                    children: assignedList.map((res) {
                                                      return Chip(
                                                        avatar: Icon(res.icon, size: 16),
                                                        label: Text(res.nom ?? ""),
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
                                                            _updateAssignedResources(chantierFormBloc);
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
                                    onPressed: () {
                                      // Final update
                                      chantierFormBloc.updateNomChantier(_nomController.text);
                                      chantierFormBloc.updateDescription(_descriptionController.text);
                                      chantierFormBloc.updateBudget(_budgetController.text);
                                      chantierFormBloc.updateDateDebut(_selectedDateDebut);
                                      chantierFormBloc.updateDateFin(_selectedDateFin);
                                      chantierFormBloc.updateClient(_selectedClient);
                                      chantierFormBloc.updateChefProjet(_selectedChefProjet);
                                      chantierFormBloc.updateStatus(_selectedStatus);
                                      
                                      chantierFormBloc.submit();
                                    },
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
                              ? _buildDraggableList("Ouvriers", _availableHommes)
                              : const SizedBox(),
                        if (!isMobile) _buildDivider(),
                        if (!isMobile)
                           isLoading
                              ? Loader()
                              : _availableMateriels.isNotEmpty
                              ? _buildDraggableList("Matériel", _availableMateriels)
                              : const SizedBox(),
                        if (!isMobile) _buildDivider(),
                        if (!isMobile)
                           isLoading
                              ? Loader()
                              : _availableCamions.isNotEmpty
                              ? _buildDraggableList("Camions", _availableCamions)
                              : const SizedBox(),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget _buildDivider() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: 1,
      color: Colors.grey,
    );
  }

  Widget _buildDraggableList<T extends RessourceBase>(String title, List<T> items) {
     return Container(
        width: 300,
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final res = items[index];
                  return Draggable<T>(
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
    ChantierFormBloc bloc,
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

      _updateAssignedResources(bloc);
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

  InputDecoration _inputDecoration({
    required String hintText,
    String? labelText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
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
