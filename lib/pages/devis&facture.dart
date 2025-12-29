// lib/screens/documents_screen.dart
import 'package:chantier/pages/pdf_view.dart';
import 'package:chantier/repository/chantier_repository.dart';
import 'package:chantier/repository/devis&facture_repository.dart';
import 'package:chantier/ui/common/loading.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../blocs/art_form_bloc.dart';
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

  void _openAddDocumentScreen() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) =>  NewDocumentScreen()),
        )
        .then((_) => setState(() {}));
  }

  void _navigateToEdit(Facture facture) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewDocumentScreen(factureToEdit: facture),
      ),
    );

    if (result == true) {
      setState(() {
        isLoading = true;

      });
      try {
        documents = await FactureRepository().getFactures() ?? [];
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print("exception list chantier $e");
      } // Rafraîchir la liste après modification
    }
  }
  bool isLoading = true;

  @override
  initState() {
    super.initState();

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
        print("exception list chantier $e");
      }
    });
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

  final ScrollController scrollController = ScrollController();

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
                                  label: Text(
                                    'Type/N°',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                               /* DataColumn(
                                  label: Text(
                                    'Client',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),*/
                                DataColumn(
                                  label: Text(
                                    'Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Total TTC',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Status',
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

                              rows: documents.map((doc) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        "${doc.reference}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    //DataCell(Text(doc.client)),
                                    DataCell(Text(doc.date ?? "")),
                                    DataCell(
                                      Text("${Utils.formatNumber(doc.totalTtc ?? 0)}"),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            doc.status ?? "",
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          doc.status ?? "",
                                          style: TextStyle(
                                            color: _getStatusColor(
                                              doc.status ?? "",
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
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
                                            onPressed: () => _navigateToEdit(doc),
                                            tooltip: 'Modifier',
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            onPressed: () => setState(
                                              () => documents.remove(doc),
                                            ),
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
                  ),
                )
              : Center(child: Text("Liste est vide")),
        ],
      ),
    );
  }
}

class NewDocumentScreen extends StatefulWidget {
   NewDocumentScreen({Key? key , this.factureToEdit}) : super(key: key);
  final Facture? factureToEdit;

  @override
  State<NewDocumentScreen> createState() => _NewDocumentScreenState();
}

bool isMobile =
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

class _NewDocumentScreenState extends State<NewDocumentScreen> {

  List<Client> clients = [];
  bool  isLoading = true;

  @override
  initState() {
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
        print("exception list chantier $e");
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return isLoading ? Loader() :BlocProvider(
      create: (context) => DocumentFormBloc(initialFacture: widget.factureToEdit , availableClients: clients ),

      child: Builder(
        builder: (context) {
          final docFormBloc = context.read<DocumentFormBloc>();
          docFormBloc.client.updateItems(clients);

          return Scaffold(
            appBar: AppBar(
              title: const Text("Créer Document"),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            body: FormBlocListener<DocumentFormBloc, String, String>(
              onSubmitting: (context, state) {
                LoadingDialog.show(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Soumission en cours...')),
                );
              },
              onDeleting: (context, state) {
                LoadingDialog.hide(context);
                setState(() {
                  print("set stateeee");
                });
              },
              onSuccess: (context, state) {
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.successResponse!)));
                if(widget.factureToEdit != null)
                  {

                    ScaffoldMessenger.of(context)..showSnackBar(
                      SnackBar(content: Text(state.successResponse!)),
                    );
                    Navigator.of(context).pop(true);
                  }else {
                  final List<Article> finalArticles = docFormBloc.articleBlocs
                      .map((bloc) => bloc.articleData)
                      .toList();
                  int totalTTC = 0;
                  int totalHT = 0;

                  for (var e in finalArticles) {
                    totalHT = totalHT + (e.prixUnitaire! * e.quantite!);
                  }
                  totalTTC = totalHT;
                  final Facture newDocument = Facture(
                    notes: docFormBloc.notes.value ?? "",

                    client: docFormBloc.client.value,
                    clientId: docFormBloc.client.value?.id ?? 1,
                    reference: state.successResponse,
                    date: docFormBloc.date.value.toString() ?? "",
                    totalTtc: totalTTC,
                    totalHt: totalHT,
                    status: docFormBloc.status.value ?? "",
                    articles: finalArticles, // Placeholder
                  );

                  // Ouvre la page d'aperçu PDF
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          PdfPreviewPage(document: newDocument),
                    ),
                  );
                }
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.failureResponse!)));
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Informations Générales",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(child: _buildTypeField(context)),
                        const SizedBox(width: 15),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _buildDateField(context)),
                        const SizedBox(width: 15),

                        isLoading ? Loader() :  Expanded(
                         child: DropdownFieldBlocBuilder<Client>(
                                  selectFieldBloc: docFormBloc.client,
                                  itemBuilder: (context, client) => FieldItem(
                                    child: Text(client.nom ?? 'Client sans nom'),
                                  ),


                                  decoration: const InputDecoration(
                                    labelText: 'Client',
                                    hintText: 'Sélectionnez le client',
                                  ),
                                ),
                       )


                            // Si erreur ou état initial (non chargé)
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatusField(context, docFormBloc),
                        ),
                      ],
                    ),

                    // Section Articles
                    const SizedBox(height: 30),
                    const Text(
                      "Liste des Articles",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildArticleList(context, docFormBloc),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            docFormBloc.notes,
                            "état d'avancement",
                            "Ecrire ...",
                          ),
                        ),
                      ],
                    ),
                    // Section Totaux
                    const SizedBox(height: 30),
                    const Text(
                      "Totaux",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTotals(context, docFormBloc),

                    // Bouton Soumettre
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: docFormBloc.submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
        },
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

  Widget _buildTextField(TextFieldBloc bloc, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFieldBlocBuilder(
          textFieldBloc: bloc,
          maxLines: label == "état d'avancement" ? 4 : 1,
          decoration: _inputDecoration(hintText: hint),
          textStyle: TextStyle(fontSize: isMobile ? 12 : 16),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    final bloc = BlocProvider.of<DocumentFormBloc>(context).date;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Date'),
        DateTimeFieldBlocBuilder(
          dateTimeFieldBloc: bloc,
          textStyle: TextStyle(fontSize: isMobile ? 12 : 16),
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

  Widget _buildTypeField(BuildContext context) {
    final bloc = BlocProvider.of<DocumentFormBloc>(context).type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Type'),
        DropdownFieldBlocBuilder<String>(
          selectFieldBloc: bloc,
          decoration: _inputDecoration(hintText: "Facture ou Devis"),
          itemBuilder: (context, value) => FieldItem(child: Text(value)),
          textStyle: TextStyle(fontSize: isMobile ? 14 : 16),
        ),
      ],
    );
  }

  Widget _buildStatusField(BuildContext context, DocumentFormBloc bloc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Status'),
        DropdownFieldBlocBuilder<String>(
          selectFieldBloc: bloc.status,
          decoration: _inputDecoration(hintText: "Statut du document"),
          itemBuilder: (context, value) => FieldItem(child: Text(value)),
          textStyle: TextStyle(fontSize: isMobile ? 14 : 16),
        ),
      ],
    );
  }

  Widget _buildTotals(BuildContext context, DocumentFormBloc docBloc) {
    return Column(
      children: [
        _buildTotalRow("Total TTC", docBloc.totalTTC),
        const SizedBox(height: 10),
        _buildTotalRow(
          "Total TTC à payer",
          docBloc.totalTTCAPayer,
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildTotalRow(
    String label,
    TextFieldBloc bloc, {
    bool isPrimary = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
            color: isPrimary ? Colors.blue.shade800 : Colors.black87,
          ),
        ),
        SizedBox(
          width: 150,
          child: TextFieldBlocBuilder(
            textFieldBloc: bloc,
            readOnly: true,
            decoration: _inputDecoration(hintText: ''),
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
              color: isPrimary ? Colors.blue.shade800 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArticleList(BuildContext context, DocumentFormBloc docBloc) {
    print("lenght articleBlocs ${docBloc.articleBlocs..length}");

    return StreamBuilder<
      FieldBlocState<List<ArticleFormBloc>, dynamic, dynamic>
    >(
      stream: docBloc.articlesListState.stream,
      builder: (context, snapshot) {
        if (docBloc.articleBlocs.isEmpty && !snapshot.hasData) {
          return Center(
            child: TextButton.icon(
              onPressed: docBloc.delete,
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              label: const Text("Ajouter le premier article"),
            ),
          );
        }

        return Column(
          children: [
            ...docBloc.articleBlocs.asMap().entries.map((entry) {
              print("articleBlocs ${docBloc.articleBlocs.length}");
              print("int ${entry.value.articleData.description}");
              final index = entry.key;
              final itemBloc = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Article #${index + 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () => docBloc.removeArticleAt(index),
                          ),
                        ],
                      ),

                      // Utilisation des champs TextFieldBlocBuilder classiques
                      _buildTextField(
                        itemBloc.description,
                        "Description",
                        "Ex: Rénovation Mur",
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              itemBloc.quantite,
                              "Quantité",
                              "1",
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              itemBloc.prixUnitaire,
                              "Prix U. HT",
                              "100",
                            ),
                          ),
                        ],
                      ),

                      // Affichage du Total (Écoute sur le stream de prixUnitaire pour le rebuild)
                      StreamBuilder(
                        stream: itemBloc.prixUnitaire.stream,
                        builder: (context, _) {
                          final article = itemBloc.articleData;
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              "Total Article: ${article.total ?? 0} ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            // Bouton Ajouter
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: docBloc.delete,
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              label: const Text("Ajouter un article"),
            ),
          ],
        );
      },
    );
  }
}




