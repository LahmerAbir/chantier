import 'package:chantier/model/chantier_single.dart';
import 'package:chantier/ui/common/loading_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc_plus/flutter_form_bloc_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../model/chantier.dart';
import '../model/homme.dart';
import '../repository/chantier_repository.dart';
import '../ui/common/loading.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  // Données simulées
  List<Chantier> _chantiers = [];
  bool isLoading = true;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _chantiers = await ChantierRepository().getChantiers() ?? [];
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

  bool isMobile =
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  final ScrollController scrollController = ScrollController();
  void _navigateToEdit(Chantier chantier) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        // On passe le chantier à la page pour qu'elle le transmette au Bloc
        builder: (context) =>   PlanningEditPdfScreen(
          chantier: chantier,
          listchantier: _chantiers,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        isLoading = true;
      });
      _chantiers = await ChantierRepository().getChantiers() ?? [];
      setState(() {
        isLoading = false;
      });
    setState(() {
    isLoading = false;
    });
    }
  }

  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }


  Future<void> generateAndPrintListeChantiersPdf(List<ChantierSingle> chantiers) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final String dateAujourdhui = dateFormat.format(DateTime.now());
    int index = 0;
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Planning',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text(' $dateAujourdhui', style:  pw.TextStyle(fontSize: 16 , fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 10),
          ],
        ),
        build: (pw.Context context) {
          return [
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
              columnWidths: {
                0: const pw.FlexColumnWidth(1), // Nom du chantier
                1: const pw.FlexColumnWidth(3), // Chef de projet
                2: const pw.FlexColumnWidth(2), // Ressources (Ouvriers/Matériel)
                3: const pw.FlexColumnWidth(4), // Statut/Dates
                4: const pw.FlexColumnWidth(3), // Statut/Dates

                5: const pw.FlexColumnWidth(2), // Statut/Dates
                6: const pw.FlexColumnWidth(3), // Statut/Dates
                7: const pw.FlexColumnWidth(3), // Statut/Dates
                7: const pw.FlexColumnWidth(3), // Statut/Dates
              },
              children: [
                // --- ENTÊTE DU TABLEAU (Le Titre en haut) ---
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildHeaderCell("#"),
                    _buildHeaderCell("Chantier"),
                    _buildHeaderCell("Chef Projet"),
                    _buildHeaderCell("Informations du chantier"),
                    _buildHeaderCell("Ouvriers"),
                    _buildHeaderCell("Conducteur"),
                    _buildHeaderCell("Machines"),
                    _buildHeaderCell("Machines XL"),
                    _buildHeaderCell("Camion , tracteur , notes"),
                  ],
                ),

                ...chantiers.map((c) {
                   index = index + 1;
                  final machinesXL = c.data?.machines != null ?  c.data!.machines!.isNotEmpty ? c.data!.machines!.where((m) => m.typem == "grand").toList() : [] : [];
                  return pw.TableRow(


                    children: [
                      _buildCell(index.toString()),
                      _buildCell(c.data?.nom?.toUpperCase() ?? "SANS NOM"),
                      _buildCell(c.data?.owner != null ? "${c.data?.owner}" : "-"),
                      _buildCell(c.data?.description != null ? "${c.data?.description}" : "-"),
                      _buildCell(c.data?.ouvriers != null ?  c.data!.ouvriers!.isNotEmpty ? c.data!.ouvriers!.map((c) => '${c.prenom} ${c.nom}').join(', ') : "" : "" ),
                      _buildCell( "-" ),
                      _buildCell(c.data?.machines != null ?  c.data!.machines!.isNotEmpty ? c.data!.machines!.map((c) => c.nom).join(', ') : "" : "" ),
                      _buildCell(machinesXL.isEmpty ? "-" : machinesXL.map((m) => m.nom).join('\n')),
                      _buildCell(c.data?.camions != null ?  c.data!.camions!.isNotEmpty ? c.data!.camions!.map((c) => c.matricule).join(', ') : "" : "" ),

                    ],
                  );
                }).toList(),
              ],
            ),
          ];
        },
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Page ${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          textAlign: pw.TextAlign.center),
    );
  }

// Helper pour les cellules de données
  pw.Widget _buildCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
    );
  }



  @override
  Widget build(BuildContext context) {
    return    isLoading
        ? Loader() :  Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Planning",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () async {
                  LoadingDialog.show(context);

                  List<ChantierSingle> listchantising = [];
                  for (var c in _chantiers) {
                    var chantierSin = await ChantierRepository()
                        .getChantiersById(c.id);
                    if (chantierSin != null) listchantising.add(chantierSin);
                  }

                  await generateAndPrintListeChantiersPdf(
                     listchantising,
                  );
                  LoadingDialog.hide(context);
                },
                child: Icon(Icons.print, size: 35),
              ),
            ],
          ),
          const SizedBox(height: 20),

               _chantiers.isNotEmpty
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: isMobile
                      ? MediaQuery.of(context).size.height * 0.65
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
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              Colors.grey[200],
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Nom du Chantier',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Chef de projet',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Date Début',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Date Fin',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),

                              DataColumn(
                                label: Text(
                                  'Action',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: _chantiers.map((chantier) {
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
                                  DataCell(
                                    // Limiter la largeur de la description pour ne pas casser le tableau
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 150,
                                      ),
                                      child: Text(
                                        chantier.owner ?? "",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(chantier.dateEmission ?? "")),
                                  DataCell(Text(chantier.dateEcheance ?? "")),

                                  DataCell(
                                    // Le bouton PDF
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_document,
                                        color: Colors.blue,
                                      ),
                                      // Icône de préparation
                                      onPressed: () {
                                        _navigateToEdit(chantier);
                                      },
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
              : Center(child: Text("Liste est vide ")),
        ],
      ),
    );
  }
}

class PlanningEditPdfScreen extends StatefulWidget {
  final Chantier chantier;
  final List<Chantier> listchantier;

  const PlanningEditPdfScreen({
    super.key,
    required this.chantier,
    required this.listchantier,
  });

  @override
  State<PlanningEditPdfScreen> createState() => _PlanningEditPdfScreenState();
}

class _PlanningEditPdfScreenState extends State<PlanningEditPdfScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _remarqueController;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  ChantierSingle? chantierSing;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.chantier.description,
    );
    _remarqueController = TextEditingController(text: widget.chantier.remarque);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        chantierSing = await ChantierRepository().getChantiersById(
          widget.chantier.id,
        );
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
  void dispose() {
    _descriptionController.dispose();
    _remarqueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Préparation du Planning PDF')),
      body: isLoading
          ? Loader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Informations Non-Éditables ---
                  _buildReadOnlyField(
                    'Nom du Chantier',
                    widget.chantier.nom ?? "",
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadOnlyField(
                          'Date Début',
                          widget.chantier.dateEmission ?? "",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildReadOnlyField(
                          'Date Fin',
                          widget.chantier.dateEcheance ?? "",
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 30),
                  SizedBox(
                    width: 100,
                    height: 70,
                    child: _buildReadOnlyField(
                      'Description',
                      widget.chantier.description ?? "",
                    ),
                  ),

                  const SizedBox(height: 5),

                  TextFormField(
                    controller: _remarqueController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Remarque',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),


                  _buildResourceList(
                    "Ouvriers affectés",
                    chantierSing!.data!.ouvriers as List<Homme>,
                    (h) => "${h.prenom} ${h.nom}",
                  ),
                  _buildResourceList(
                    "Camions sur site",
                    chantierSing!.data!.camions as List<Camion>,
                    (c) => "${c.nom} - ${c.matricule}",
                  ),
                  _buildResourceList(
                    "Machines / Matériel",
                    chantierSing!.data!.machines as List<Materiel>,
                    (m) => "${m.nom}",
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        LoadingDialog.show(context);

                      await ChantierRepository()
                            .editChantiers(
                        id: widget.chantier.id,
                        nom: chantierSing!.data!.nom,
                        owner:  chantierSing!.data!.owner ,
                        description: chantierSing!.data!.description ?? "",
                        adresse: chantierSing!.data!.address ?? "" ,
                        date_emission: chantierSing!.data!.dateEmission,
                        dateecheeance: chantierSing!.data!.dateEcheance,
                        total: chantierSing!.data!.total,
                        status: chantierSing!.data!.status,
                        remarque: _remarqueController.text
                       // ouvrier_ids: chantierSing!.data!.ouvriers ?? [],
                        //camion_ids: chantierSing!.data!.ouvriers ?? [],
                        //machine_ids:  chantierSing!.data!.ouvriers ?? [],
                            );



                        LoadingDialog.hide(context);
                        Navigator.of(context).pop(true);

                      }, // Utilise la fonction submit du FormBloc
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      child: const Text(
                        "Imprimer",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildResourceList(
    String title,
    List<dynamic> items,
    String Function(dynamic) labelExtractor,
  ) {
    if (items.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items
              .map(
                (item) => Chip(
                  label: Text(
                    labelExtractor(item),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue[50],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
