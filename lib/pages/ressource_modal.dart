import 'package:flutter/material.dart';

import '../model/homme.dart';

class ResourceSelectionModal extends StatefulWidget {
  final List<RessourceBase> availableResources;
  // La liste actuelle des ressources déjà assignées (pour pré-cocher)
  final List<RessourceBase> initialSelection;

  const ResourceSelectionModal({
    required this.availableResources,
    required this.initialSelection,
    super.key,
  });

  @override
  State<ResourceSelectionModal> createState() => _ResourceSelectionModalState();
}

class _ResourceSelectionModalState extends State<ResourceSelectionModal> {
  // Un Set est idéal pour gérer les sélections uniques et rapides
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    // Initialise le Set avec les IDs des éléments déjà sélectionnés
    _selectedIds = widget.initialSelection.map((r) => r.id).toSet();
  }

  // Fonction utilitaire pour obtenir les ressources sélectionnées complètes
  List<RessourceBase> _getSelectedResources() {
    // Filtrer la liste complète des disponibles pour ne garder que ceux dont l'ID est dans le Set
    return widget.availableResources
        .where((r) => _selectedIds.contains(r.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sélectionner les Ressources"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.availableResources.length,
              itemBuilder: (context, index) {
                final res = widget.availableResources[index];
                final isSelected = _selectedIds.contains(res.id);

                return CheckboxListTile(
                  value: isSelected,
                  secondary: Icon(res.icon, color: Colors.blue),
                  title: Text(res.name),
                  subtitle: Text(res.type.toUpperCase()),
                  onChanged: (bool? newValue) {
                    setState(() {
                      if (newValue == true) {
                        _selectedIds.add(res.id);
                      } else {
                        _selectedIds.remove(res.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          // Bouton de confirmation en bas
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Retourne la liste finale des objets sélectionnés
                Navigator.of(context).pop(_getSelectedResources());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text("Confirmer la sélection (${_selectedIds.length})"),
            ),
          ),
        ],
      ),
    );
  }
}