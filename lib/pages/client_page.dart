import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../blocs/client_form_bloc.dart';
import '../model/client.dart';
import '../repository/chantier_repository.dart';
import '../ui/common/loading.dart';



class ClientManagementScreen extends StatefulWidget {
  const ClientManagementScreen({super.key});

  @override
  State<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<ClientManagementScreen> {
  bool _isLoading = true;
  List<Client> clients = [];

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        clients = await ChantierRepository().getClients() ?? [];
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("exception list chantier $e");
      }
    });
  }


  void _showAddClientModal() async {
    // Utiliser showModalBottomSheet pour une meilleure gestion du clavier
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // IMPORTANT pour la gestion du clavier
      builder: (context) {
        return BlocProvider(
          create: (context) => ClientFormBloc(),
          child: const _ClientForm(),
        );
      },
    );

  }

  final ScrollController scrollController = ScrollController();
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
                "Gestion des clients",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: Colors.blue.shade700,
                  size: 40,
                ),
                onPressed: _showAddClientModal,
              ),
            ],
          ),
          const SizedBox(height: 20),

          _isLoading
              ? Loader()
              : clients.isNotEmpty
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: isMobile
                          ? Axis.horizontal
                          : Axis.vertical,
                      controller: scrollController,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: _buildClientsDataTable(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Text("Liste est vide"),
        ],
      ),
    );
  }

  // --- Widget pour la DataTable ---
  Widget _buildClientsDataTable() {
    return DataTable(
      columns: const [
        DataColumn(
          label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text('Ville', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
      rows: clients.map((client) {
        return DataRow(
          cells: [
            DataCell(Text(client.id.toString())),
            DataCell(Text(client.nom ?? 'N/A')),
            DataCell(Text(client.email ?? 'N/A')),
            DataCell(Text(client.ville ?? 'N/A')),
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      // Logique de modification
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () {
                      // Logique de suppression
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _ClientForm extends StatelessWidget {
  const _ClientForm();

  @override
  Widget build(BuildContext context) {
    final formBloc = BlocProvider.of<ClientFormBloc>(context);

    // Utiliser FormBlocListener pour gérer le succès/échec
    return FormBlocListener<ClientFormBloc, int, String>(
      onSubmitting: (context, state) {
        // Afficher une barre de progression ou un Spinner
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Soumission en cours...')));
      },
      onSuccess: (context, state) {
        // En cas de succès, fermer la modale et renvoyer 'true' pour rafraîchir la liste
        Navigator.of(context).pop(true);
      },
      onFailure: (context, state) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
            Text(
              'Ajouter un Nouveau Client',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),

            // --- Champ Nom ---
            TextFieldBlocBuilder(
              textFieldBloc: formBloc.nom,
              decoration: const InputDecoration(labelText: 'Nom (Obligatoire)'),
            ),

            // --- Champ Email ---
            TextFieldBlocBuilder(
              textFieldBloc: formBloc.email,
              decoration: const InputDecoration(
                labelText: 'Email (Obligatoire)',
              ),
            ),

            // --- Champ Téléphone ---
            TextFieldBlocBuilder(
              textFieldBloc: formBloc.telephone,
              decoration: const InputDecoration(labelText: 'Téléphone'),
            ),

            // --- Champ Adresse ---
            TextFieldBlocBuilder(
              textFieldBloc: formBloc.adresse,
              decoration: const InputDecoration(labelText: 'Adresse'),
            ),

            // --- Champ Ville ---
            TextFieldBlocBuilder(
              textFieldBloc: formBloc.ville,
              decoration: const InputDecoration(labelText: 'Ville'),
            ),

            // --- Champ Pays ---
            TextFieldBlocBuilder(
              textFieldBloc: formBloc.pays,
              decoration: const InputDecoration(labelText: 'Pays'),
            ),

            const SizedBox(height: 20),

            // --- Bouton Soumettre ---
            ElevatedButton.icon(
              onPressed: formBloc.submit,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer le Client'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
