import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chantier/repository/devis&facture_repository.dart';

import '../model/client.dart';
import '../model/document.dart'; // Contient Facture et Article
import '../utils/utils.dart';

// --- MODELS LOCAUX POUR LE FORMULAIRE ---
class ArticleItem {
  String description = '';
  String quantite = '1';
  String prixUnitaire = '0';
  
  Article toArticle() {
    return Article(
      description: description,
      quantite: int.tryParse(quantite) ?? 0,
      prixUnitaire: int.tryParse(prixUnitaire) ?? 0,
    );
  }
}

class FactureEmiseItem {
  String numFacture = '';
  String montantHTVA = '';
}

class PosteEAItem {
  String designation = '';
  String unite = 'm²';
  String qteTotale = '0';
  String prixUnitaire = '0';
  String qtePrecedente = '0';
  String qteActuelle = '0';
}

// --- ÉTATS ---
abstract class DocumentFormState extends Equatable {
  const DocumentFormState();
  @override
  List<Object?> get props => [];
}

class DocumentFormInitial extends DocumentFormState {}
class DocumentFormLoading extends DocumentFormState {}
class DocumentFormSuccess extends DocumentFormState {
  final String message;
  final String? reference; // Pour générer le PDF si besoin
  const DocumentFormSuccess(this.message, {this.reference});
  @override
  List<Object?> get props => [message, reference];
}
class DocumentFormFailure extends DocumentFormState {
  final String error;
  const DocumentFormFailure(this.error);
  @override
  List<Object?> get props => [error];
}

// --- CUBIT ---
class DocumentFormBloc extends Cubit<DocumentFormState> {
  // Champs généraux
  String type = 'Facture';
  DateTime? date = DateTime.now();
  Client? client;
  String status = 'non payée';
  String notes = '';
  
  // Champs calculés
  double totalTTC = 0.0;
  double totalHT = 0.0;
  
  // Listes
  List<ArticleItem> articles = [];
  
  // ID si modification
  int? factureId;
  
  // Liste des clients disponibles pour le dropdown
  List<Client> availableClients = [];

  // --- CHAMPS EA ---
  String periodeEA = '';
  String numCommande = '';
  String totalCommandeBase = '0';
  String totalSupplements = '0';
  String retenueRetard = '0';
  String avancementCumule = '0'; // (B) Calculé
  
  List<FactureEmiseItem> facturesEmises = [];
  List<PosteEAItem> postesEA = [];

  DocumentFormBloc({
    Facture? initialFacture,
    List<Client> availableClients = const [],
  }) : factureId = initialFacture?.id, super(DocumentFormInitial()) {
    
    this.availableClients = availableClients; // Stockage local
    
    // Init numCommande EA
    numCommande = "EA-${DateTime.now().millisecond}"; 

    if (initialFacture != null) {
      type = initialFacture.reference?.contains("FAC") == true ? "Facture" : "Devis";
      notes = initialFacture.notes ?? "";
      status = initialFacture.status ?? 'non payée';
      
      if (initialFacture.date != null) {
        try { date = DateTime.parse(initialFacture.date!); } catch (_) {}
      }
      
      if (initialFacture.clientId != null) {
         try {
           client = availableClients.firstWhere((c) => c.id == initialFacture.clientId);
         } catch (_) {}
      }
      
      // Init articles
      if (initialFacture.articles != null) {
        articles = initialFacture.articles!.map((a) {
          var item = ArticleItem();
          item.description = a.description ?? '';
          item.quantite = a.quantite?.toString() ?? '1';
          item.prixUnitaire = a.prixUnitaire?.toString() ?? '0';
          return item;
        }).toList();
        recalculateTotals();
      }
    } else {
      // Ajout d'un article vide par défaut pour une nouvelle facture
      addArticle();
    }
  }

  // --- ACTIONS ARTICLES ---
  void addArticle() {
    articles.add(ArticleItem());
    // Pas d'emit ici car géré localement par l'UI via les contrôleurs, 
    // sauf si on veut forcer un rebuild complet.
  }

  void removeArticleAt(int index) {
    if (index >= 0 && index < articles.length) {
      articles.removeAt(index);
      recalculateTotals();
    }
  }
  
  void updateArticle(int index, ArticleItem item) {
    if (index >= 0 && index < articles.length) {
      articles[index] = item;
      recalculateTotals();
    }
  }

  void recalculateTotals() {
    double ht = 0;
    for (var a in articles) {
      int q = int.tryParse(a.quantite) ?? 0;
      int p = int.tryParse(a.prixUnitaire) ?? 0;
      ht += q * p;
    }
    totalHT = ht;
    // TVA 20% par exemple, à adapter si besoin
    // totalTTC = totalHT * 1.20; 
    totalTTC = totalHT; // Selon votre ancien code totalTTC = totalHT (pas de TVA appliquée ?)
  }

  // --- ACTIONS EA ---
  void addFactureEmise() {
    facturesEmises.add(FactureEmiseItem());
  }
  
  void removeFactureEmiseAt(int index) {
    facturesEmises.removeAt(index);
  }

  void addPosteEA() {
    postesEA.add(PosteEAItem());
  }
  
  void removePosteEAAt(int index) {
    postesEA.removeAt(index);
    recalculerTotalB();
  }
  
  void recalculerTotalB() {
    double totalB = 0.0;
    for (var poste in postesEA) {
      double prec = double.tryParse(poste.qtePrecedente.replaceAll(',', '.')) ?? 0.0;
      double actu = double.tryParse(poste.qteActuelle.replaceAll(',', '.')) ?? 0.0;
      double pu = double.tryParse(poste.prixUnitaire.replaceAll(',', '.')) ?? 0.0;
      totalB += (prec + actu) * pu;
    }
    avancementCumule = totalB.toStringAsFixed(2);
  }

  // --- SUBMIT ---
  Future<void> submit() async {
    // Validations de base
    if (client == null) {
      emit(const DocumentFormFailure("Veuillez sélectionner un client"));
      emit(DocumentFormInitial());
      return;
    }
    if (date == null) {
      emit(const DocumentFormFailure("La date est requise"));
      emit(DocumentFormInitial());
      return;
    }

    emit(DocumentFormLoading());

    try {
      if (type != "EA") {
        // Validation articles
        if (articles.isEmpty) {
           emit(const DocumentFormFailure("Veuillez ajouter au moins un article"));
           emit(DocumentFormInitial());
           return;
        }
        
        // Préparation
        final List<Article> finalArticles = articles.map((e) => e.toArticle()).toList();
        var dateD = Utils.convertDateTimeToSqlDateFormat(date!);
        var ref = Utils.genererReference(type.toLowerCase(), date!);
        
        if (factureId != null) {
          // Edit
          var res = await FactureRepository().editFacture(
            id: factureId,
            reference: ref, // Ou garder l'ancienne ref ? L'ancien code régénérait
            date: dateD,
            client_id: client!.id!,
            status: status,
            notes: notes,
            articles: finalArticles,
          );
           if (res != null) {
            emit(DocumentFormSuccess("Document modifié", reference: ref));
          } else {
            emit(const DocumentFormFailure("Erreur modification"));
            emit(DocumentFormInitial());
          }
        } else {
          // Add
          var res = await FactureRepository().addFacture(
            reference: ref,
            date: dateD,
            client_id: client!.id!,
            status: status,
            notes: notes,
            articles: finalArticles,
          );
          if (res != null) {
            emit(DocumentFormSuccess("Document créé", reference: ref));
          } else {
            emit(const DocumentFormFailure("Erreur création"));
            emit(DocumentFormInitial());
          }
        }
      } else {
        // Cas EA (État d'avancement)
        // Ici l'ancien code ne faisait qu'un emitSuccess pour le PDF sans appel API apparemment
        // ou alors c'était incomplet.
        // Je simule un succès pour permettre la génération PDF
        emit(const DocumentFormSuccess("EA Prêt")); 
      }
    } catch (e) {
      emit(DocumentFormFailure("Erreur: $e"));
      emit(DocumentFormInitial());
    }
  }
}
