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
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<Facture> documents = [];

  void _openAddDocumentScreen() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewDocumentScreen()))
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
                  height: isMobile
                      ? MediaQuery.of(context).size.height * 0.6
                      : MediaQuery.of(context).size.height * 0.8,
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
                                      Text(
                                        "${Utils.formatNumber(doc.totalTtc ?? 0)}",
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
                                            onPressed: () =>
                                                _navigateToEdit(doc),
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
  NewDocumentScreen({Key? key, this.factureToEdit}) : super(key: key);
  final Facture? factureToEdit;

  @override
  State<NewDocumentScreen> createState() => _NewDocumentScreenState();
}

bool isMobile =
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

class _NewDocumentScreenState extends State<NewDocumentScreen> {
  List<Client> clients = [];
  bool isLoading = true;

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
    return isLoading
        ? Loader()
        : BlocProvider(
            create: (context) => DocumentFormBloc(
              initialFacture: widget.factureToEdit,
              availableClients: clients,
            ),

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
                    onSuccess: (context, state) async {
                      LoadingDialog.hide(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.successResponse ?? "")),
                      );
                      if(docFormBloc.type.value == "EA")
                        {
                          print("pdf EA");


                        }else {
                        if (widget.factureToEdit != null) {
                          ScaffoldMessenger.of(context)
                            ..showSnackBar(
                              SnackBar(content: Text(state.successResponse!)),
                            );
                          Navigator.of(context).pop(true);
                        } else {
                          final List<Article> finalArticles = docFormBloc
                              .articleBlocs
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
                      }
                    },
                    onFailure: (context, state) {
                      LoadingDialog.hide(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.failureResponse!)),
                      );
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

                              isLoading
                                  ? Loader()
                                  : Expanded(
                                      child: DropdownFieldBlocBuilder<Client>(
                                        selectFieldBloc: docFormBloc.client,
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
                                    ),
                            ],
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.85,

                            width: MediaQuery.of(context).size.width ,
                            child:
                                BlocBuilder<
                                  SelectFieldBloc<String, dynamic>,
                                  SelectFieldBlocState<String, dynamic>
                                >(
                                  bloc: docFormBloc.type,
                                  builder: (context, state) {
                                    if (state.value == 'EA') {
                                      return _buildEASection(
                                        context,
                                        docFormBloc,
                                      );
                                    }
                                    return SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        children: [
                                          const SizedBox(width: 15),
                                          SizedBox(
                                            height: 100,
                                            width: MediaQuery.of(
                                              context,
                                            ).size.width,
                                            child: _buildStatusField(
                                              context,
                                              docFormBloc,
                                            ),
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
                                          _buildArticleList(
                                            context,
                                            docFormBloc,
                                          ),

                                          Expanded(
                                            child: _buildTextField(

                                              docFormBloc.notes,
                                              "Notes",
                                              "Ecrire ...",
                                            ),
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
                                        ],
                                      ),
                                    );
                                  },
                                ),
                          ),
                          const SizedBox(height: 15),

                          // Bouton Soumettre
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:() async {
                                if(docFormBloc.type.value == "EA" ) await generateEAPdf(docFormBloc); else docFormBloc.submit();},
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
  Future<void> generateEAPdf(DocumentFormBloc formBloc) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // On crée un thème qui applique ces polices à tout le document
    final theme = pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
    );

    // Calculs (utilisez tryParse pour éviter les crashs si un champ est vide)
    double A = double.tryParse(formBloc.totalCommandeBase.value) ?? 0.0;
    double G = double.tryParse(formBloc.totalSupplements.value) ?? 0.0;
    double B = double.tryParse(formBloc.avancementCumule.value) ?? 0.0;
    double C = double.tryParse(formBloc.retenueRetard.value) ?? 0.0;

    double E = formBloc.facturesEmises.value.fold(
      0.0,
          (sum, item) => sum + (double.tryParse(item.montantHTVA.value) ?? 0.0),
    );

    double montantMarche = A + G;
    double soldeBase = A + G - B; // Formule (A)+(G)-(B) de l'image
    double cumuleAFacturer = B + C; // (D) = (B) + somme(C)


    double aFacturerMaintenant = cumuleAFacturer - E; // (F) = (D) - (E)
    String dateDuJour = DateFormat('dd/MM/yyyy').format(formBloc.date.value ?? DateTime.now());
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme:  theme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Align(

                alignment: pw.Alignment.topRight,
                child: pw.Text("Date ${dateDuJour}"),
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  "SYNTHESE D'ETAT D'AVANCEMENT",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // TABLEAU GAUCHE : INFOS CLIENT
                  pw.Container(
                    width: 250, // Un peu plus large pour l'adresse
                    child: pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        _buildSimpleRow("Client", formBloc.client.value?.nom?.toUpperCase() ?? ""),
                        _buildSimpleRow("Adresse", formBloc.client.value?.adresse ?? ""),
                        _buildSimpleRow("Tel", formBloc.client.value?.telephone ?? ""),
                        _buildSimpleRow("Email", formBloc.client.value?.email ?? ""),
                      ],
                    ),
                  ),

                  // TABLEAU DROITE : INFOS COMMANDE (Votre code existant)
                  pw.Align(
                    alignment: pw.Alignment.topRight,
                    child: pw.Container(
                      width: 200,
                      child: pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          _buildSimpleRow(
                            "Firme",
                            formBloc.client.value?.nom ?? "",
                          ),
                          _buildSimpleRow(
                            "N° de commande",
                            formBloc.numCommande.value,
                          ),
                          _buildSimpleRow(
                            "Période de l'EA",
                            formBloc.periodeEA.value,
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),

              pw.SizedBox(height: 30),

              // --- Section Financière ---
              _buildFinancialLine("Total commande =", A, "(A)"),
              _buildFinancialLine("Total des suppléments =", G, "(G)"),
              _buildFinancialLine(
                "Etat d'avancement cumulé avec supplt =",
                B,
                "(B)",
                isBold: true,
              ),

              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text("Solde commande de base = "),
                  _buildValueBox(soldeBase),
                  pw.Text(" (A) + (G) - (B)", style: pw.TextStyle(fontSize: 8)),
                ],
              ),

              pw.SizedBox(height: 20),
              _buildFinancialLine(
                "Retenue contractuelle pour retard",
                C,
                "(C)",
              ),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text(
                    "Cumulé à facturer = ",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  _buildValueBox(cumuleAFacturer),
                  pw.Text(
                    " (D) = (B) + somme (C)",
                    style: pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Text("Détails des factures émises :"),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text(" N° facture"),
                      pw.Text(" Montant HTVA"),
                    ],
                  ),
                  ...formBloc.facturesEmises.value.map(
                    (f) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(2),
                          child: pw.Text(f.numFacture.value),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(2),
                          child: pw.Text("${f.montantHTVA.value} "),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // --- LIGNE FINALE : A FACTURER ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    "Total factures émises = ",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  _buildValueBox(E),
                  pw.Text(" (E)", style: pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    "A FACTURER = ",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Container(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text(
                      "${aFacturerMaintenant.toStringAsFixed(2)} ",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Text(" (F) = (D) - (E)", style: pw.TextStyle(fontSize: 8)),
                ],
              ),
            ],
          );






        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());

  }

  // Helpers pour le style du tableau
  pw.TableRow _buildSimpleRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(label, style: pw.TextStyle(fontSize: 9)),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildValueBox(double value) {
    return pw.Container(
      width: 80,
      margin: pw.EdgeInsets.symmetric(horizontal: 5),
      padding: pw.EdgeInsets.all(2),
      child: pw.Text(
        "${value.toStringAsFixed(2)}",
        textAlign: pw.TextAlign.right,
      ),
    );
  }

  pw.Widget _buildFinancialLine(
    String label,
    double value,
    String index, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        // Aligne tout vers la droite comme sur l'image
        children: [
          // Libellé de la ligne
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.SizedBox(width: 10),
          // Boîte du montant
          pw.Container(
            width: 100,
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
            ),
            child: pw.Text(
              "${value.toStringAsFixed(2)} ",
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
          // Indice de référence (A, G, B...)
          pw.Container(
            width: 25,
            padding: const pw.EdgeInsets.only(left: 5),
            child: pw.Text(
              index,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEASection(BuildContext context, DocumentFormBloc formBloc) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.6,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          Row(
            children: [
              Expanded(
                child: TextFieldBlocBuilder(
                  textFieldBloc: formBloc.numCommande,
                  isEnabled: false,
                  decoration: const InputDecoration(labelText: 'N° Commande'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFieldBlocBuilder(
                  textFieldBloc: formBloc.periodeEA,
                  decoration: const InputDecoration(
                    labelText: 'Période de l\'EA ',
                  ),
                ),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: TextFieldBlocBuilder(
                  textFieldBloc: formBloc.totalCommandeBase,
                  decoration: const InputDecoration(
                    labelText: 'Total Commande (A)',
                    suffixText: '',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFieldBlocBuilder(
                  textFieldBloc: formBloc.totalSupplements,
                  decoration: const InputDecoration(
                    labelText: 'Suppléments (G)',
                    suffixText: '',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFieldBlocBuilder(
                  textFieldBloc: formBloc.avancementCumule,
                  decoration: const InputDecoration(
                    labelText: 'Etat d\'avancement cumulé avec supplt (B)',
                    suffixText: '',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: TextFieldBlocBuilder(
                  textFieldBloc: formBloc.retenueRetard,
                  decoration: const InputDecoration(
                    labelText: 'Retenue contractuelle pour retard (C)',
                    suffixText: '',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Text(
            "Factures déjà émises (E)",
            style: TextStyle(fontWeight: FontWeight.bold , color: Colors.black),
          ),

          BlocBuilder<
            ListFieldBloc<FactureInfoFieldBloc, dynamic>,
            ListFieldBlocState<FactureInfoFieldBloc, dynamic>
          >(
            bloc: formBloc.facturesEmises,
            builder: (context, state) {
              if (state.fieldBlocs.isEmpty) {
                return Text(
                  "Aucune facture émise",
                );
              }

              return Column(
                children: state.fieldBlocs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final fieldBloc = entry.value;
                  return Row(
                    children: [
                      Expanded(
                        child: TextFieldBlocBuilder(
                          textFieldBloc: fieldBloc.numFacture,
                          decoration: InputDecoration(labelText: 'N° Facture'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFieldBlocBuilder(
                          textFieldBloc: fieldBloc.montantHTVA,
                          decoration: InputDecoration(
                            labelText: 'Montant',
                            suffixText: '€',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            formBloc.facturesEmises.removeFieldBlocAt(index),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),

          TextButton.icon(
            onPressed: () {
              final uniqueName =
                  'facture_${DateTime.now().millisecondsSinceEpoch}';
              formBloc.facturesEmises.addFieldBloc(
                FactureInfoFieldBloc.create(uniqueName),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Ajouter une facture émise'),
          ),
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
          maxLines: label == "Notes" ? 4 : 1,
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
