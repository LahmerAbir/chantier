import 'package:chantier/pages/pdf_view.dart';
import 'package:chantier/repository/chantier_repository.dart';
import 'package:chantier/repository/devis&facture_repository.dart';
import 'package:chantier/ui/common/loading.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../blocs/document_form_bloc.dart';
import '../model/client.dart';
import '../model/document.dart';
import '../ui/common/loading_dialog.dart';
import '../utils/utils.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<Facture> documents = [];
  bool isLoading = true;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        documents = await FactureRepository().getFactures() ?? [];
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print("exception list docs $e");
      }
    });
  }

  void _openAddDocumentScreen() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewDocumentScreen()))
        .then((_) => _loadDocuments());
  }

  void _navigateToEdit(Facture facture) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewDocumentScreen(factureToEdit: facture),
      ),
    );

    if (result == true) {
      _loadDocuments();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'payée':
        return Colors.green.shade700;
      case 'non payée':
        return Colors.red.shade700;
      case 'Annulée':
        return Colors.black54;
      case 'partiellement payée':
        return Colors.orange.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Devis & Factures",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: Colors.blue.shade700,
                  size: 40,
                ),
                onPressed: _openAddDocumentScreen,
              ),
            ],
          ),
          const SizedBox(height: 20),
          isLoading
              ? Loader()
              : documents.isNotEmpty
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: isMobile
                      ? MediaQuery.of(context).size.height * 0.6
                      : MediaQuery.of(context).size.height * 0.8,
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: isMobile ? Axis.horizontal : Axis.vertical,
                      controller: scrollController,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DataTable(
                              columns: const [
                                DataColumn(
                                  label: Text('Type/N°', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                DataColumn(
                                  label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                DataColumn(
                                  label: Text('Total TTC', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                ),
                                DataColumn(
                                  label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                DataColumn(
                                  label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                              rows: documents.map((doc) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text("${doc.reference}", style: const TextStyle(fontWeight: FontWeight.w500))),
                                    DataCell(Text(doc.date ?? "")),
                                    DataCell(Text("${Utils.formatNumber(doc.totalTtc ?? 0)}")),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(doc.status ?? "").withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          doc.status ?? "",
                                          style: TextStyle(color: _getStatusColor(doc.status ?? ""), fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.blue.shade700, size: 20),
                                            onPressed: () => _navigateToEdit(doc),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                            onPressed: () => setState(() => documents.remove(doc)),
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
                  ),
                )
              : const Center(child: Text("Liste est vide")),
        ],
      ),
    );
  }
}

class NewDocumentScreen extends StatefulWidget {
  final Facture? factureToEdit;

  const NewDocumentScreen({Key? key, this.factureToEdit}) : super(key: key);

  @override
  State<NewDocumentScreen> createState() => _NewDocumentScreenState();
}

class _NewDocumentScreenState extends State<NewDocumentScreen> {
  List<Client> clients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        clients = await ChantierRepository().getClients() ?? [];
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print("exception list clients $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Loader());

    return BlocProvider(
      create: (context) => DocumentFormBloc(
        initialFacture: widget.factureToEdit,
        availableClients: clients,
      ),
      child: const _DocumentFormContent(),
    );
  }
}

class _DocumentFormContent extends StatefulWidget {
  const _DocumentFormContent({Key? key}) : super(key: key);

  @override
  State<_DocumentFormContent> createState() => _DocumentFormContentState();
}

class _DocumentFormContentState extends State<_DocumentFormContent> {
  // Controllers
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Controllers EA
  final TextEditingController _periodeEAController = TextEditingController();
  final TextEditingController _numCommandeController = TextEditingController();
  final TextEditingController _totalCommandeBaseController = TextEditingController();
  final TextEditingController _totalSupplementsController = TextEditingController();
  final TextEditingController _retenueRetardController = TextEditingController();
  final TextEditingController _avancementCumuleController = TextEditingController();

  bool isMobile = defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<DocumentFormBloc>();
    
    // Init values
    _notesController.text = bloc.notes;
    _dateController.text = bloc.date != null ? DateFormat('dd/MM/yyyy').format(bloc.date!) : '';
    
    // Init EA values
    _periodeEAController.text = bloc.periodeEA;
    _numCommandeController.text = bloc.numCommande;
    _totalCommandeBaseController.text = bloc.totalCommandeBase;
    _totalSupplementsController.text = bloc.totalSupplements;
    _retenueRetardController.text = bloc.retenueRetard;
    _avancementCumuleController.text = bloc.avancementCumule;
  }
  
  @override
  void dispose() {
    _notesController.dispose();
    _dateController.dispose();
    _periodeEAController.dispose();
    _numCommandeController.dispose();
    _totalCommandeBaseController.dispose();
    _totalSupplementsController.dispose();
    _retenueRetardController.dispose();
    _avancementCumuleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final bloc = context.read<DocumentFormBloc>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: bloc.date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        bloc.date = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final docFormBloc = context.watch<DocumentFormBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer Document"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<DocumentFormBloc, DocumentFormState>(
        listener: (context, state) async {
          if (state is DocumentFormLoading) {
            LoadingDialog.show(context);
          } else if (state is DocumentFormSuccess) {
            LoadingDialog.hide(context);
            
            if (docFormBloc.type == "EA") {
              // Génération PDF EA
              await generateEAPdf(docFormBloc, context);
            } else {
              // Facture/Devis standard
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              Navigator.of(context).pop(true);
            }
          } else if (state is DocumentFormFailure) {
            LoadingDialog.hide(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Informations Générales",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: docFormBloc.type,
                      decoration: _inputDecoration(labelText: "Type"),
                      items: ['Facture', 'Devis', 'EA'].map((e) => 
                        DropdownMenuItem(value: e, child: Text(e))
                      ).toList(),
                      onChanged: (val) {
                         setState(() {
                           docFormBloc.type = val!;
                         });
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
              const SizedBox(height: 15),
              
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dateController,
                          decoration: _inputDecoration(
                            labelText: "Date",
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                     child: DropdownButtonFormField<Client>(
                        value: docFormBloc.client,
                        decoration: _inputDecoration(labelText: "Client", hintText: "Sélectionnez"),
                        items: (context.read<DocumentFormBloc>().availableClients ?? []).map((c) => 
                          DropdownMenuItem(value: c, child: Text(c.nom ?? 'Inconnu'))
                        ).toList(),
                        onChanged: (val) {
                          setState(() {
                             docFormBloc.client = val;
                          });
                        },
                     ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              
              // CONTENU DYNAMIQUE SELON TYPE
              if (docFormBloc.type == 'EA') ...[
                 _buildEASection(context, docFormBloc),
                 const SizedBox(height: 30),
                 isMobile 
                   ? _buildDetailsTab_Mobile(docFormBloc) 
                   : _buildDetailsTab(docFormBloc),
              ] else ...[
                 _buildStandardSection(context, docFormBloc),
              ],
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Update final values
                    docFormBloc.notes = _notesController.text;
                    // EA Fields
                    docFormBloc.periodeEA = _periodeEAController.text;
                    docFormBloc.totalCommandeBase = _totalCommandeBaseController.text;
                    docFormBloc.totalSupplements = _totalSupplementsController.text;
                    docFormBloc.retenueRetard = _retenueRetardController.text;
                    
                    if (docFormBloc.type == "EA") {
                       // Trigger PDF gen directly or via state
                       docFormBloc.submit(); 
                    } else {
                       docFormBloc.submit();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "Sauvegarder le Document",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStandardSection(BuildContext context, DocumentFormBloc bloc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: bloc.status,
          decoration: _inputDecoration(labelText: "Statut"),
          items: ['payée', 'non payée', 'partiellement payée'].map((e) => 
            DropdownMenuItem(value: e, child: Text(e))
          ).toList(),
          onChanged: (val) {
             setState(() => bloc.status = val!);
          },
        ),
        const SizedBox(height: 20),
        
        const Text("Liste des Articles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bloc.articles.length,
          itemBuilder: (context, index) {
            final article = bloc.articles[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Article #${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                               bloc.removeArticleAt(index);
                            });
                          },
                        )
                      ],
                    ),
                    TextFormField(
                      initialValue: article.description,
                      decoration: _inputDecoration(labelText: "Description"),
                      onChanged: (v) => article.description = v,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: article.quantite,
                            decoration: _inputDecoration(labelText: "Qté"),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                               article.quantite = v;
                               setState(() => bloc.recalculateTotals());
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            initialValue: article.prixUnitaire,
                            decoration: _inputDecoration(labelText: "Prix U. HT"),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                               article.prixUnitaire = v;
                               setState(() => bloc.recalculateTotals());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        TextButton.icon(
          onPressed: () {
            setState(() => bloc.addArticle());
          },
          icon: const Icon(Icons.add_circle, color: Colors.blue),
          label: const Text("Ajouter un article"),
        ),
        
        const SizedBox(height: 20),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: _inputDecoration(labelText: "Notes"),
        ),
        
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total HT:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("${bloc.totalHT.toStringAsFixed(2)} €", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
         Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total TTC:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            Text("${bloc.totalTTC.toStringAsFixed(2)} €", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
      ],
    );
  }

  // --- EA SECTION ---
  
  Widget _buildEASection(BuildContext context, DocumentFormBloc bloc) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _numCommandeController,
                readOnly: true,
                decoration: _inputDecoration(labelText: "N° Commande"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _periodeEAController,
                decoration: _inputDecoration(labelText: "Période EA"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _totalCommandeBaseController,
                decoration: _inputDecoration(labelText: "Total Commande (A)"),
                keyboardType: TextInputType.number,
                onChanged: (v) => bloc.totalCommandeBase = v,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _totalSupplementsController,
                decoration: _inputDecoration(labelText: "Suppléments (G)"),
                keyboardType: TextInputType.number,
                onChanged: (v) => bloc.totalSupplements = v,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _avancementCumuleController,
                readOnly: true, // Calculé
                decoration: _inputDecoration(labelText: "Avancement (B)"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _retenueRetardController,
                decoration: _inputDecoration(labelText: "Retenue (C)"),
                keyboardType: TextInputType.number,
                onChanged: (v) => bloc.retenueRetard = v,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        const Text("Factures émises (E)", style: TextStyle(fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bloc.facturesEmises.length,
          itemBuilder: (context, index) {
            final item = bloc.facturesEmises[index];
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.numFacture,
                    decoration: _inputDecoration(labelText: "N° Facture"),
                    onChanged: (v) => item.numFacture = v,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: item.montantHTVA,
                    decoration: _inputDecoration(labelText: "Montant HT"),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => item.montantHTVA = v,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() => bloc.removeFactureEmiseAt(index));
                  },
                )
              ],
            );
          },
        ),
        TextButton.icon(
          onPressed: () => setState(() => bloc.addFactureEmise()),
          icon: const Icon(Icons.add),
          label: const Text("Ajouter facture émise"),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(DocumentFormBloc bloc) {
     // Version Desktop / Tablette (Tableau)
     return Column(
       children: [
          Row(
            children: const [
               Expanded(flex: 3, child: Text("Désignation", style: TextStyle(fontWeight: FontWeight.bold))),
               Expanded(child: Text("Unité", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
               Expanded(child: Text("Qté Tot.", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
               Expanded(child: Text("Préc.", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
               Expanded(child: Text("Actuel", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
               Expanded(child: Text("Cumul", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
               Expanded(child: Text("P.U.", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
               SizedBox(width: 40),
            ],
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bloc.postesEA.length,
            itemBuilder: (context, index) {
               final poste = bloc.postesEA[index];
               double prec = double.tryParse(poste.qtePrecedente) ?? 0;
               double actu = double.tryParse(poste.qteActuelle) ?? 0;
               double cumul = prec + actu;
               
               return Padding(
                 padding: const EdgeInsets.symmetric(vertical: 4),
                 child: Row(
                   children: [
                      Expanded(
                        flex: 3, 
                        child: TextFormField(
                          initialValue: poste.designation, 
                          decoration: _inputDecoration(hintText: ""),
                          onChanged: (v) => poste.designation = v,
                        )
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextFormField(
                           initialValue: poste.unite,
                           onChanged: (v) => poste.unite = v,
                           decoration: _inputDecoration(hintText: "")
                        )
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextFormField(
                           initialValue: poste.qteTotale,
                           onChanged: (v) => poste.qteTotale = v,
                           decoration: _inputDecoration(hintText: "")
                        )
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextFormField(
                           initialValue: poste.qtePrecedente,
                           onChanged: (v) {
                              poste.qtePrecedente = v;
                              setState(() {
                                 bloc.recalculerTotalB();
                                 _avancementCumuleController.text = bloc.avancementCumule;
                              });
                           },
                           decoration: _inputDecoration(hintText: "")
                        )
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextFormField(
                           initialValue: poste.qteActuelle,
                           onChanged: (v) {
                              poste.qteActuelle = v;
                              setState(() {
                                 bloc.recalculerTotalB();
                                 _avancementCumuleController.text = bloc.avancementCumule;
                              });
                           },
                           decoration: _inputDecoration(hintText: "")
                        )
                      ),
                      const SizedBox(width: 4),
                      Expanded(child: Text(cumul.toStringAsFixed(2), textAlign: TextAlign.center)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextFormField(
                           initialValue: poste.prixUnitaire,
                           onChanged: (v) {
                              poste.prixUnitaire = v;
                              setState(() {
                                 bloc.recalculerTotalB();
                                 _avancementCumuleController.text = bloc.avancementCumule;
                              });
                           },
                           decoration: _inputDecoration(hintText: "")
                        )
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                           setState(() {
                              bloc.removePosteEAAt(index);
                              _avancementCumuleController.text = bloc.avancementCumule;
                           });
                        },
                      )
                   ],
                 ),
               );
            },
          ),
          TextButton.icon(
             onPressed: () => setState(() => bloc.addPosteEA()),
             icon: const Icon(Icons.add),
             label: const Text("Ajouter un poste"),
          )
       ],
     );
  }

  Widget _buildDetailsTab_Mobile(DocumentFormBloc bloc) {
    return Column(
      children: [
        ...bloc.postesEA.asMap().entries.map((entry) {
          final index = entry.key;
          final poste = entry.value;
          
          double prec = double.tryParse(poste.qtePrecedente) ?? 0;
          double actu = double.tryParse(poste.qteActuelle) ?? 0;
          double cumul = prec + actu;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: poste.designation,
                    decoration: _inputDecoration(labelText: "Désignation"),
                    onChanged: (v) => poste.designation = v,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: poste.qtePrecedente,
                          decoration: _inputDecoration(labelText: "Préc."),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                             poste.qtePrecedente = v;
                             setState(() {
                               bloc.recalculerTotalB();
                               _avancementCumuleController.text = bloc.avancementCumule;
                             });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: poste.qteActuelle,
                          decoration: _inputDecoration(labelText: "Actuel"),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                             poste.qteActuelle = v;
                             setState(() {
                               bloc.recalculerTotalB();
                               _avancementCumuleController.text = bloc.avancementCumule;
                             });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Cumul: ${cumul.toStringAsFixed(2)}"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       SizedBox(
                         width: 100,
                         child: TextFormField(
                            initialValue: poste.prixUnitaire,
                            decoration: _inputDecoration(labelText: "P.U."),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                               poste.prixUnitaire = v;
                               setState(() {
                                  bloc.recalculerTotalB();
                                  _avancementCumuleController.text = bloc.avancementCumule;
                               });
                            },
                         ),
                       ),
                       IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                             setState(() {
                                bloc.removePosteEAAt(index);
                                _avancementCumuleController.text = bloc.avancementCumule;
                             });
                          },
                       )
                    ],
                  )
                ],
              ),
            ),
          );
        }).toList(),
        TextButton.icon(
          onPressed: () => setState(() => bloc.addPosteEA()),
          icon: const Icon(Icons.add),
          label: const Text("Ajouter un poste"),
        )
      ],
    );
  }

  InputDecoration _inputDecoration({String? labelText, String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blue.shade700)),
    );
  }
}

// --- GENERATION PDF EA ---
Future<void> generateEAPdf(DocumentFormBloc formBloc, BuildContext context) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final theme = pw.ThemeData.withFont(base: font, bold: fontBold);

    double A = double.tryParse(formBloc.totalCommandeBase) ?? 0.0;
    double G = double.tryParse(formBloc.totalSupplements) ?? 0.0;
    double B = double.tryParse(formBloc.avancementCumule) ?? 0.0;
    double C = double.tryParse(formBloc.retenueRetard) ?? 0.0;

    double E = formBloc.facturesEmises.fold(
      0.0,
      (sum, item) => sum + (double.tryParse(item.montantHTVA) ?? 0.0),
    );

    double soldeBase = A + G - B; 
    double cumuleAFacturer = B + C; 
    double aFacturerMaintenant = cumuleAFacturer - E; 
    
    String dateDuJour = DateFormat('dd/MM/yyyy').format(formBloc.date ?? DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Align(alignment: pw.Alignment.topRight, child: pw.Text("Date $dateDuJour")),
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text("SYNTHESE D'ETAT D'AVANCEMENT", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))),
              pw.SizedBox(height: 20),
              
              // Infos Client
              pw.Text("Client: ${formBloc.client?.nom ?? ''}"),
              pw.Text("Chantier: ${formBloc.notes}"), // Using notes as chantier name approx
              pw.Divider(),
              
              // Totaux
              pw.Text("Total Commande (A): ${A.toStringAsFixed(2)} €"),
              pw.Text("Suppléments (G): ${G.toStringAsFixed(2)} €"),
              pw.Text("Avancement (B): ${B.toStringAsFixed(2)} €", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text("Retenue (C): ${C.toStringAsFixed(2)} €"),
              pw.SizedBox(height: 10),
              pw.Text("A FACTURER: ${aFacturerMaintenant.toStringAsFixed(2)} €", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ],
          );
        },
      ),
    );
    
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
