import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/chantier.dart';
import 'add_chantier.dart';

class ChantiersPage extends StatefulWidget {
  const ChantiersPage({super.key});

  @override
  State<ChantiersPage> createState() => _ChantiersPageState();
}

class _ChantiersPageState extends State<ChantiersPage> {
  List<Chantier> chantiers = [
    Chantier(
      name: "Résidence Le Parc",
      client: "Société Immobilière Paris",
      dateLivraison: "15/11/2026",
      budget: "450 000 €",
      status: "En cours",
    ),
    Chantier(
      name: "Centre Commercial Lyon",
      client: "Lyon Développement SA",
      dateLivraison: "12/07/2024",
      budget: "850 000 €",
      status: "Retard",
    ),
    Chantier(
      name: "Bureau La Défense",
      client: "AXA Immobilier",
      dateLivraison: "16/11/1996",
      budget: "1 200 000 €",
      status: "Livré",
    ),
    Chantier(
      name: "École Primaire",
      client: "Mairie de Lille",
      dateLivraison: "18/12/2026",
      budget: "200 000 €",
      status: "En attente",
    ),
  ];
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
  void _openAddProjectModal() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NewProjectDragDropScreen()),
    );
  }

  void _editChantier(Chantier chantier) {
    print("Modification de : ${chantier.name}");
  }

  void _deleteChantier(Chantier chantier) {
    setState(() {
      chantiers.remove(chantier);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chantier "${chantier.name}" supprimé.')),
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En cours':
        return Colors.blue.shade700;
      case 'Livré':
        return Colors.green.shade700;
      case 'Retard':
        return Colors.red.shade700;
      case 'En attente':
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
                onPressed: _openAddProjectModal,
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                 child :
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                                      'Client',
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
                                          chantier.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(chantier.client)),
                                      DataCell(Text(chantier.budget)),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              chantier.status,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            chantier.status,
                                            style: TextStyle(
                                              color: _getStatusColor(
                                                chantier.status,
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
                                              "${(chantier.dateLivraison).toString()}",
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
                                                  _editChantier(chantier),
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
          ),)
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
              'Client',
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
                  chantier.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              DataCell(
                Text(
                  chantier.client,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              DataCell(
                Text(
                  chantier.budget,
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
                    color: _getStatusColor(chantier.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    chantier.status,
                    style: TextStyle(
                      color: _getStatusColor(chantier.status),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    Text(
                      "${(chantier.dateLivraison).toString()}",
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
                      onPressed: () => _editChantier(chantier),
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
