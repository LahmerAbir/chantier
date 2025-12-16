// lib/services/pdf_service.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../model/client.dart';
import '../model/document.dart';




/// Génère le PDF en mémoire (Uint8List)
Future<Uint8List> generateDocumentPdf(Facture document) async {
  final pdf = pw.Document();
  final dateFormat = DateFormat('dd/MM/yyyy');
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

  // Styles de base pour le PDF
  final defaultStyle = const pw.TextStyle(fontSize: 10);
  final headerStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18);
  final totalStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12);
  final primaryColor = PdfColor.fromInt(0xFF0D47A1); // Bleu foncé

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

            // 1. Titre (Facture ou Devis)
            pw.Center(
              child: pw.Text(
                document.reference ?? "",
                style: headerStyle,
              ),
            ),
            pw.SizedBox(height: 30),

            // 2. En-tête et Infos Client
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Colonne Gauche: Informations du Client
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      buildClientBlock(document.client!)

                    ],
                  ),
                ),
                pw.SizedBox(width: 20),

                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildPdfHeaderRow("Date d'émission:", document.date.toString(), defaultStyle),
                        _buildPdfHeaderRow("Statut:", document.status ?? "", defaultStyle.copyWith(color: _getPdfStatusColor(document.status ?? ""))),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 40),

            // 3. Tableau des Articles
            _buildPdfArticlesTable(document.articles ?? [], defaultStyle, currencyFormat, primaryColor),

            pw.SizedBox(height: 40),

            // 4. Totaux
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 250,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Column(
                    children: [
                      _buildPdfTotalRow("MONTANT HT:", document.totalTtc!.toStringAsFixed(3), currencyFormat, totalStyle.copyWith(fontSize: 10)),
                      pw.Divider(color: PdfColors.grey300, thickness: 1, height: 15),
                     _buildPdfTotalRow("TVA :", "20%", currencyFormat, totalStyle.copyWith(fontSize: 10)),
                      pw.Divider(color: PdfColors.grey300, thickness: 1, height: 15),

                      pw.Container(
                        color: PdfColors.grey200,
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: _buildPdfTotalRow("TOTAL À PAYER TTC:", document.totalHt!.toStringAsFixed(3), currencyFormat, totalStyle.copyWith(color: primaryColor)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.Spacer(),

            // 5. Bas de page
            pw.Text(
              " ${document.notes }",
              style:  pw.TextStyle(fontSize: 8, color: PdfColors.black),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}



pw.Widget buildClientBlock(Client client) {
  // Définir le style pour les étiquettes (gras) et les données
  final pw.TextStyle labelStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10);
  final pw.TextStyle dataStyle = pw.TextStyle(fontSize: 10);
  final PdfColor primaryColor = PdfColors.blueGrey800; // Couleur pour le titre

  return pw.Container(
    // 1. Définir le contour et les marges internes
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey500, width: 1),
      borderRadius: pw.BorderRadius.circular(5),
    ),

    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // --- Titre CLIENT (avec la ligne de séparation) ---
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('CLIENT', style: pw.TextStyle(color: primaryColor, fontWeight: pw.FontWeight.bold, fontSize: 11)),
            pw.SizedBox(width: 8),
            // Ligne décorative à droite du titre (simule la ligne sur votre image)
            pw.Expanded(
              child: pw.Container(
                height: 1,
                color: PdfColors.grey400,
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 8), // Espace après le titre

        // --- 1. Nom du Client (en gras, comme le nom de la société) ---
        pw.Text(
          client.nom ?? 'N/A',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
        ),

        // --- 2. Matricule Fiscale (MF) / ID ---
        _buildClientDetailRow('MF', '1891628/W/A/M/000', labelStyle, dataStyle),
        // NOTE: Le MF n'est pas dans votre modèle Client, vous devrez le passer en paramètre ou l'ajouter au modèle.

        // --- 3. Adresse ---
        _buildClientDetailRow('Adresse', client.adresse ?? 'N/A', labelStyle, dataStyle),

        // --- 4. Téléphone ---
        _buildClientDetailRow('Téléphone', client.telephone ?? 'N/A', labelStyle, dataStyle),

        // --- 5. Email ---
        _buildClientDetailRow('Email', client.email ?? 'N/A', labelStyle, dataStyle),
      ],
    ),
  );
}

// --- Widget Utilitaire pour les lignes de détails (Label : Data) ---
pw.Widget _buildClientDetailRow(
    String label, String data, pw.TextStyle labelStyle, pw.TextStyle dataStyle) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 2),
    child: pw.RichText(
      text: pw.TextSpan(
        // Le label (ex: "Adresse :")
        text: '$label : ',
        style: labelStyle,
        children: [
          // La donnée réelle (ex: "Rue Mahbouba...")
          pw.TextSpan(
            text: data,
            style: dataStyle,
          ),
        ],
      ),
    ),
  );
}
pw.Widget _buildPdfText(String text, pw.TextStyle style) {
  return pw.Text(text, style: style);
}

pw.Widget _buildPdfHeaderRow(String label, String value, pw.TextStyle style) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: style.copyWith(color: PdfColors.grey700)),
        pw.Text(value, style: style.copyWith(fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
}

pw.Widget _buildPdfTotalRow(String label, String amount, NumberFormat format, pw.TextStyle style) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label, style: style),
      pw.Text(amount, style: style),
    ],
  );
}

PdfColor _getPdfStatusColor(String status) {
  switch (status) {
    case 'payée': return PdfColors.green700;
    case 'non payée': return PdfColors.blue700;
    case 'Retard': return PdfColors.red700;
    default: return PdfColors.orange700;
  }
}

pw.Widget _buildPdfArticlesTable(
    List<Article> articles,
    pw.TextStyle defaultStyle,
    NumberFormat currencyFormat,
    PdfColor headerColor
    ) {
  // Définition des colonnes
  const List<String> headers = ["DESCRIPTION", "QUANTITÉ", "PRIX UNIT. HT", "MONTANT HT"];

  // Styles
  final tableHeaderStyle = defaultStyle.copyWith(fontWeight: pw.FontWeight.bold, color: PdfColors.white);
  final tableBodyStyle = defaultStyle.copyWith(fontSize: 9);

  return pw.Table.fromTextArray(
      headers: headers,
      data: articles.map((article) => [
        article.description,
        '${article.quantite}', // S'assurer que c'est une chaîne
        currencyFormat.format(article.prixUnitaire),
      currencyFormat.format(article.prixUnitaire! * article.quantite! ),
      ]).toList(),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerStyle: tableHeaderStyle,
      headerDecoration: pw.BoxDecoration(color: headerColor),
      cellStyle: tableBodyStyle,
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(2),
      },
      cellPadding: const pw.EdgeInsets.all(6),
      cellAlignment: pw.Alignment.centerRight,
      headerAlignment: pw.Alignment.centerRight,
      // Alignement spécifique pour la description
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      headerAlignments: {
        0: pw.Alignment.centerLeft,
      }
  );
}