import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chantier/repository/chantier_repository.dart';

import '../model/chantier.dart';
import '../model/client.dart';
import '../model/homme.dart';
import '../model/simple_entity.dart'; // Pour Materiel, Camion
import '../utils/utils.dart';

// --- ÉTATS ---
abstract class ChantierFormState extends Equatable {
  const ChantierFormState();
  @override
  List<Object?> get props => [];
}

class ChantierFormInitial extends ChantierFormState {}

class ChantierFormLoading extends ChantierFormState {}

class ChantierFormSuccess extends ChantierFormState {
  final String message;
  const ChantierFormSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ChantierFormFailure extends ChantierFormState {
  final String error;
  const ChantierFormFailure(this.error);
  @override
  List<Object?> get props => [error];
}

// --- CUBIT ---
class ChantierFormBloc extends Cubit<ChantierFormState> {
  // Champs
  String nomChantier = '';
  String description = '';
  String budget = '';
  Client? client;
  String status = 'en attente';
  DateTime? dateDebut;
  DateTime? dateFin;
  Homme? chefProjet;
  
  List<RessourceBase> ressourcesAssigned = [];
  
  final int? chantierId;
  final List<String> statusItems = ['en cours', 'terminé', 'en attente'];
  
  // Pour la gestion de l'UI si besoin de listes (sera géré dans la vue principalement)
  List<Client> availableClients = [];
  List<Homme> tousLesHommes = [];

  ChantierFormBloc({
    Chantier? initialChantier,
    this.availableClients = const [],
    this.tousLesHommes = const [],
  }) : chantierId = initialChantier?.id, super(ChantierFormInitial()) {
    
    if (initialChantier != null) {
      nomChantier = initialChantier.nom ?? '';
      description = initialChantier.description ?? '';
      budget = initialChantier.total.toString();
      status = initialChantier.status ?? 'en attente';
      
      if (initialChantier.clientId != null) {
        try {
          client = availableClients.firstWhere(
            (c) => c.id == initialChantier.clientId,
          );
        } catch (_) {}
      }
      
      if (initialChantier.dateEmission != null) {
        try {
           dateDebut = DateTime.parse(initialChantier.dateEmission!);
        } catch (_) {}
      }
      
      if (initialChantier.dateEcheance != null) {
        try {
           dateFin = DateTime.parse(initialChantier.dateEcheance!);
        } catch (_) {}
      }
      
      // Note: Le chef de projet n'était pas récupéré dans l'ancien bloc depuis initialChantier explicitement
      // sauf si 'owner' correspond au nom du chef. 
      // Je laisse vide ou à adapter selon le modèle.
    }
  }

  // Setters
  void updateNomChantier(String value) => nomChantier = value;
  void updateDescription(String value) => description = value;
  void updateBudget(String value) => budget = value;
  void updateStatus(String? value) { if(value != null) status = value; }
  void updateClient(Client? value) => client = value;
  void updateDateDebut(DateTime? value) => dateDebut = value;
  void updateDateFin(DateTime? value) => dateFin = value;
  void updateChefProjet(Homme? value) => chefProjet = value;
  void updateRessources(List<RessourceBase> value) => ressourcesAssigned = value;

  Future<void> submit() async {
    // Validations
    if (nomChantier.isEmpty) {
      emit(const ChantierFormFailure("Nom du chantier requis"));
      emit(ChantierFormInitial());
      return;
    }
    if (client == null) {
      emit(const ChantierFormFailure("Client requis"));
      emit(ChantierFormInitial());
      return;
    }
    if (budget.isEmpty || int.tryParse(budget.replaceAll(RegExp(r'[^\d]'), '')) == null) {
       emit(const ChantierFormFailure("Budget invalide"));
       emit(ChantierFormInitial());
       return;
    }
    if (status.isEmpty) {
       emit(const ChantierFormFailure("Statut requis"));
       emit(ChantierFormInitial());
       return;
    }
    if (chefProjet == null) {
       emit(const ChantierFormFailure("Chef de projet requis"));
       emit(ChantierFormInitial());
       return;
    }
    if (dateDebut == null || dateFin == null) {
       emit(const ChantierFormFailure("Dates de début et fin requises"));
       emit(ChantierFormInitial());
       return;
    }

    emit(ChantierFormLoading());
    
    // Préparation des données
    var dateD = Utils.convertDateTimeToSqlDateFormat(dateDebut!);
    var dateF = Utils.convertDateTimeToSqlDateFormat(dateFin!); // Attention: ancien code utilisait dateDebut pour dateF aussi (bug?), je corrige pour dateFin
    
    final listHomme = ressourcesAssigned.whereType<Homme>().toList();
    final listCamion = ressourcesAssigned.whereType<Camion>().toList();
    final listMateriel = ressourcesAssigned.whereType<Materiel>().toList();
    
    final List<int> hommesIds = listHomme.map((h) => h.id!).toList();
    final List<int> camionsIds = listCamion.map((c) => c.id!).toList();
    final List<int> materielsIds = listMateriel.map((m) => m.id!).toList();
    
    final int parsedBudget = int.parse(budget.replaceAll(RegExp(r'[^\d]'), ''));

    try {
      if (chantierId != null) {
        var res = await ChantierRepository().editChantiers(
          id: chantierId,
          nom: nomChantier,
          owner: chefProjet?.nom ?? "", // Nom ou ID ? L'ancien code utilisait le nom
          description: description,
          adresse: nomChantier, // Adresse = nom dans l'ancien code
          date_emission: dateD,
          dateecheeance: dateF,
          total: parsedBudget,
          status: status,
          ouvrier_ids: hommesIds,
          camion_ids: camionsIds,
          machine_ids: materielsIds,
        );
        
        if (res != null) {
          emit(ChantierFormSuccess('Chantier $nomChantier modifié avec succès.'));
        } else {
          emit(const ChantierFormFailure("Erreur lors de la modification"));
          emit(ChantierFormInitial());
        }
      } else {
        var res = await ChantierRepository().addChantiers(
          nom: nomChantier,
          owner: chefProjet?.nom ?? "",
          adresse: nomChantier,
          description: description,
          date_emission: dateD,
          dateecheeance: dateF,
          total: parsedBudget,
          status: status,
          ouvrier_ids: hommesIds,
          camion_ids: camionsIds,
          machine_ids: materielsIds,
        );
        
        if (res != null) {
          emit(ChantierFormSuccess('Chantier $nomChantier créé avec succès.'));
        } else {
          emit(const ChantierFormFailure("Erreur lors de la création"));
          emit(ChantierFormInitial());
        }
      }
    } catch (e) {
      emit(const ChantierFormFailure("Une erreur s'est produite"));
      emit(ChantierFormInitial());
    }
  }
}
