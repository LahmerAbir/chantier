import 'package:chantier/repository/chantier_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../model/chantier.dart';
import '../ui/common/loading.dart';
import '../utils/utils.dart';
import 'add_chantier.dart';

class ChantiersPage extends StatefulWidget {
  const ChantiersPage({super.key});

  @override
  State<ChantiersPage> createState() => _ChantiersPageState();
}

class _ChantiersPageState extends State<ChantiersPage> {
  List<Chantier> chantiers = [];
  final ScrollController scrollController = ScrollController();

  bool isLoading = true;

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        chantiers = await ChantierRepository().getChantiers() ?? [];
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
  }

  Future<void> _loadChantiers() async {
    setState(() {
      isLoading = true;
    });

    try {
      chantiers = await ChantierRepository().getChantiers() ?? [];
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

  void _navigateToAddChantier(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NewProjectDragDropScreen()),
    );

    if (result == true) {
      await _loadChantiers();
    }
  }
  void _navigateToEdit(Chantier chantier) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        // On passe le chantier à la page pour qu'elle le transmette au Bloc
        builder: (context) => NewProjectDragDropScreen(chantierToEdit: chantier),
      ),
    );

    if (result == true) {
      _loadChantiers(); // Rafraîchir la liste après modification
    }
  }
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }


  void _editChantier(Chantier chantier) {
    print("Modification de : ${chantier.nom}");
  }

  void _deleteChantier(Chantier chantier) {
    setState(() {
      chantiers.remove(chantier);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chantier "${chantier.nom}" supprimé.')),
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'en cours':
        return Colors.blue.shade700;
      case 'terminé':
        return Colors.green.shade700;
      case 'retard':
        return Colors.red.shade700;
      case 'en attente':
        return Colors.orange.shade700;
      default:
        return Colors.grey;
    }
  }

  bool isMobile =
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Gestion des chantiers",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: Colors.blue.shade700,
                  size: 40,
                ),
                onPressed: () {
                  _navigateToAddChantier(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          isLoading
              ? Loader()
              : chantiers.isNotEmpty
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: isMobile ?  MediaQuery.of(context).size.height * 0.6 : MediaQuery.of(context).size.height * 0.8,
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: isMobile
                          ? Axis.horizontal
                          : Axis.vertical,
                      controller: scrollController,
                      child: SingleChildScrollView(
                        child: isMobile
                            ? CardMobile()
                            : Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DataTable(
                                  columnSpacing: 30,
                                  horizontalMargin: 15,
                                  dataRowMinHeight: 50,
                                  dataRowMaxHeight: 60,

                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'Chantier',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Chef de projet',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Budget',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Statut',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Date de livraison',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Actions',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Lignes de données
                                  rows: chantiers.map((chantier) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            chantier.nom ?? "",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(chantier.owner ?? "")),
                                        DataCell(
                                          Text(
                                            Utils.formatNumber(
                                              chantier.total ?? 0,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                chantier.status ?? "",
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              chantier.status ?? "",
                                              style: TextStyle(
                                                color: _getStatusColor(
                                                  chantier.status ?? "",
                                                ),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              Text(
                                                "${(chantier.dateEmission).toString()}",
                                              ),
                                              const SizedBox(width: 5),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.blue.shade700,
                                                  size: 20,
                                                ),
                                                onPressed: () =>
                                                    _navigateToEdit(chantier),
                                                tooltip: 'Modifier',

                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                                onPressed: () =>
                                                    _deleteChantier(chantier),
                                                tooltip: 'Supprimer',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                    ),
                  ),
                )
              : Center(child: Text("Liste est vide")),
        ],
      ),
    );
  }

  Widget CardMobile() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 5,
        dataRowMinHeight: 50,
        dataRowMaxHeight: 60,

        columns: const [
          DataColumn(
            label: Text(
              'Chantier',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          DataColumn(
            label: Text(
              'Chef de projet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          DataColumn(
            label: Text(
              'Budget',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          DataColumn(
            label: Text(
              'Statut',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          DataColumn(
            label: Text(
              'Date de livraison',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          DataColumn(
            label: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],

        // Lignes de données
        rows: chantiers.map((chantier) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  chantier.nom ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              DataCell(
                Text(
                  chantier.owner ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              DataCell(
                Text(
                  Utils.formatNumber(chantier.total ?? 0),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      chantier.status ?? "",
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    chantier.status ?? "",
                    style: TextStyle(
                      color: _getStatusColor(chantier.status ?? ""),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    Text(
                      "${(chantier.dateEmission).toString()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      onPressed: () => _navigateToEdit(chantier),
                      tooltip: 'Modifier',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => _deleteChantier(chantier),
                      tooltip: 'Supprimer',
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
