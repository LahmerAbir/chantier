
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../model/document.dart';
import '../utils/pdf_service.dart';
import 'dart:typed_data';


class PdfPreviewPage extends StatelessWidget {
  final Facture document;

  const PdfPreviewPage({required this.document, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aperçu ${document.reference}"),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) async {
          return await generateDocumentPdf(document);
        },
        allowSharing: true,
        allowPrinting: true,
        maxPageWidth: 700,

      ),
    );
  }
}