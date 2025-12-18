import 'package:chantier/model/chantier_single.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
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
                "Planning",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          isLoading
              ? Loader()
              : _chantiers.isNotEmpty
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
                                  'Description',
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
                                  DataCell(Text(chantier.dateEmission ?? "")),
                                  DataCell(Text(chantier.dateEcheance ?? "")),
                                  DataCell(
                                    // Limiter la largeur de la description pour ne pas casser le tableau
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 200,
                                      ),
                                      child: Text(
                                        chantier.description ?? "",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    // Le bouton PDF
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_document,
                                        color: Colors.blue,
                                      ),
                                      // Icône de préparation
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PlanningEditPdfScreen(
                                                  chantier: chantier,
                                                ),
                                          ),
                                        );
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

  const PlanningEditPdfScreen({super.key, required this.chantier});

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
    _remarqueController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        chantierSing = await ChantierRepository().getChantiersById(widget.chantier.id) ;
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
      body: isLoading ? Loader() : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Informations Non-Éditables ---
            _buildReadOnlyField('Nom du Chantier', widget.chantier.nom ?? ""),
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


            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _remarqueController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Planning du lendemain / Remarques',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            _buildResourceList("Ouvriers affectés",chantierSing!.data!.ouvriers as List<Homme>, (h) => "${h.prenom} ${h.nom}"),
            _buildResourceList("Camions sur site", chantierSing!.data!.camions as List<Camion>, (c) => "${c.nom} - ${c.matricule}"),
            _buildResourceList("Machines / Matériel", chantierSing!.data!.machines as List<Materiel>, (m) => "${m.nom}"),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  generateAndPrintPlanningPdf(
                    widget.chantier,
                    updatedDescription: _descriptionController.text,
                    remarque: _remarqueController.text,
                  );
                },                // Utilise la fonction submit du FormBloc
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
            // --- Bouton Impression ---
          ],
        ),
      ) ,
    );
  }
  Widget _buildResourceList(String title, List<dynamic> items, String Function(dynamic) labelExtractor) {
    if (items.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.map((item) => Chip(
            label: Text(labelExtractor(item), style: const TextStyle(fontSize: 12)),
            backgroundColor: Colors.blue[50],
          )).toList(),
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
  Future<void> generateAndPrintPlanningPdf(
      Chantier chantier, {
        required String updatedDescription,
        required String remarque,
      }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final String dateAujourdhui = dateFormat.format(DateTime.now());
    final String dateDemain = dateFormat.format(DateTime.now().add(const Duration(days: 1)));

    // --- Widget pour créer un Badge Horizontal ---
    pw.Widget _buildResourceBadge(String text, PdfColor color) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(right: 4, bottom: 4),
        padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100, // Fond gris très clair
          borderRadius: pw.BorderRadius.circular(3),
          border: pw.Border.all(color: color, width: 0.5),
        ),
        child: pw.Text(text, style: pw.TextStyle(fontSize: 11, color: color)),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('PLANNING DE TRAVAIL DU $dateAujourdhui')),

              pw.Text('Chantier : ${chantier.nom}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.SizedBox(height: 15),

              // --- Section des Ressources Horizontales ---
              pw.Text('RESSOURCES :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
              pw.SizedBox(height: 8),

              // 1. Hommes (Bleu)
              if(chantierSing!.data!.ouvriers != null)
                if (chantierSing!.data!.ouvriers!.isNotEmpty) ...[
                pw.Text("Hommes :", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                pw.SizedBox(height: 4),
                pw.Wrap(
                  children: chantierSing!.data!.ouvriers!.map((h) => _buildResourceBadge("${h.prenom} ${h.nom}", PdfColors.blue800)).toList(),
                ),
                pw.SizedBox(height: 10),
              ],

              // 2. Camions (Vert)
              if(chantierSing!.data!.camions != null)
                if (chantierSing!.data!.camions!.isNotEmpty) ...[
                pw.Text("Camions :", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                pw.SizedBox(height: 4),
                pw.Wrap(
                  children: chantierSing!.data!.camions!.map((c) => _buildResourceBadge("${c.nom} (${c.matricule})", PdfColors.green800)).toList(),
                ),
                pw.SizedBox(height: 10),
              ],

              // 3. Machines (Orange)
              if(chantierSing!.data!.machines != null)
                if (chantierSing!.data!.machines!.isNotEmpty) ...[
                pw.Text("Matériel :", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                pw.SizedBox(height: 4),
                pw.Wrap(
                  children: chantierSing!.data!.machines!.map((m) => _buildResourceBadge("${m.nom}", PdfColors.orange800)).toList(),
                ),
              ],

              pw.SizedBox(height: 25),
              pw.Divider(),

              // Description et Planning du lendemain (vos mots gardés)
              pw.Text('Description du projet :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(updatedDescription),

              pw.SizedBox(height: 25),

              pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.red, width: 1.5),
                      borderRadius: pw.BorderRadius.circular(5)
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PLANNING DU LENDEMAIN ($dateDemain) :',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                        pw.SizedBox(height: 5),
                        pw.Text(remarque.isEmpty ? "Aucune remarque particulière." : remarque),
                      ]
                  )
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }





}
