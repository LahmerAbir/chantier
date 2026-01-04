import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_form_bloc/flutter_form_bloc.dart'; // SUPPRIMÉ

import '../blocs/client_form_bloc.dart';
import '../model/client.dart';
import '../repository/chantier_repository.dart';
import '../ui/common/loading.dart';
import '../ui/common/loading_dialog.dart';

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

  void _showAddClientModal(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ClientFormBloc(),
          child: const _ClientForm(),
        ),
      ),
    );

    if (result == true) {
      {
        try {
          setState(() {
            _isLoading = true;
          });
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
      }
    }
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
                onPressed:(){ _showAddClientModal(context);}
              ),
            ],
          ),
          const SizedBox(height: 20),

          _isLoading
              ? Loader()
              : clients.isNotEmpty
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child:   SingleChildScrollView(
                        child: Column(
                          children: [
                            Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Scrollbar(
                                  controller: scrollController,
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    scrollDirection: isMobile
                                        ? Axis.horizontal
                                        : Axis.vertical,
                                    controller: scrollController,
                                    child: _buildClientsDataTable(),
                              ),
                                ))),
                          ],
                        ),
                      ),
                )
              : Text("Liste est vide"),
        ],
      ),
    );
  }

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

class _ClientForm extends StatefulWidget {
  const _ClientForm();

  @override
  State<_ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<_ClientForm> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _paysController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _villeController.dispose();
    _paysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formBloc = context.read<ClientFormBloc>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Ajouter un Nouveau Client',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: BlocListener<ClientFormBloc, ClientFormState>(
        listener: (context, state) {
          if (state is ClientFormLoading) {
            LoadingDialog.show(context);
          } else if (state is ClientFormSuccess) {
            LoadingDialog.hide(context);
            ScaffoldMessenger.of(context)..showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.of(context).pop(true);
          } else if (state is ClientFormFailure) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
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
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (Obligatoire)',
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
                  controller: _adresseController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: formBloc.updateAdresse,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _villeController,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: formBloc.updateVille,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _paysController,
                  decoration: const InputDecoration(
                    labelText: 'Pays',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: formBloc.updatePays,
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      formBloc.updateNom(_nomController.text);
                      formBloc.updateEmail(_emailController.text);
                      formBloc.updateTelephone(_telephoneController.text);
                      formBloc.updateAdresse(_adresseController.text);
                      formBloc.updateVille(_villeController.text);
                      formBloc.updatePays(_paysController.text);
                      formBloc.submit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Enregistrer",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
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
