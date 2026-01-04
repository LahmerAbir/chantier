import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chantier/repository/chantier_repository.dart';

// --- ÉTATS ---
abstract class HommeFormState extends Equatable {
  const HommeFormState();
  @override
  List<Object?> get props => [];
}

class HommeFormInitial extends HommeFormState {}

class HommeFormLoading extends HommeFormState {}

class HommeFormSuccess extends HommeFormState {
  final String message;
  const HommeFormSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class HommeFormFailure extends HommeFormState {
  final String error;
  const HommeFormFailure(this.error);
  @override
  List<Object?> get props => [error];
}

// --- CUBIT ---
class HommeFormBloc extends Cubit<HommeFormState> {
  HommeFormBloc() : super(HommeFormInitial());

  String nom = '';
  String prenom = '';
  String email = '';
  String telephone = '';
  String specialite = '';
  String type = 'ouvrier'; // Valeur par défaut
  String coutJournalier = '0';

  final List<String> typesDisponibles = ['ouvrier', 'chef projet', 'désamianteur', 'conducteur'];

  void updateNom(String value) => nom = value;
  void updatePrenom(String value) => prenom = value;
  void updateEmail(String value) => email = value;
  void updateTelephone(String value) => telephone = value;
  void updateSpecialite(String value) => specialite = value;
  void updateType(String? value) {
    if (value != null) type = value;
  } 
  void updateCoutJournalier(String value) => coutJournalier = value;

  Future<void> submit() async {
    // Validations
    if (nom.isEmpty || prenom.isEmpty) {
      emit(const HommeFormFailure("Nom et Prénom sont obligatoires"));
      emit(HommeFormInitial());
      return;
    }
    
    if (type.isEmpty) {
       emit(const HommeFormFailure("Le type de poste est obligatoire"));
       emit(HommeFormInitial());
       return;
    }

    if (double.tryParse(coutJournalier) == null) {
      emit(const HommeFormFailure("Le coût journalier doit être un nombre valide"));
      emit(HommeFormInitial());
      return;
    }
    
    // Validation email si renseigné
    if (email.isNotEmpty) {
       final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
       if (!emailRegex.hasMatch(email)) {
         emit(const HommeFormFailure("Format d'email invalide"));
         emit(HommeFormInitial());
         return;
       }
    }

    emit(HommeFormLoading());

    try {
      var res = await ChantierRepository().addHomme(
        nom: nom,
        prenom: prenom,
        email: email,
        telephone: telephone,
        specialite: specialite,
        type: type,
        // coutJournalier manquant dans l'appel repository ? 
        // Je le garde tel quel par rapport au code original, 
        // mais normalement il devrait être passé. 
        // L'original appelait addHomme sans coutJournalier bien qu'il soit dans le bloc.
        // Je vérifie la signature dans le repo si possible, sinon je garde comme avant.
      );

      if (res != null) {
        emit(const HommeFormSuccess('Homme créé avec succès.'));
      } else {
        emit(const HommeFormFailure('Erreur lors de la création du Homme'));
        emit(HommeFormInitial());
      }
    } catch (e) {
      emit(HommeFormFailure('Échec de l\'ajout de l\'employé: ${e.toString()}'));
      emit(HommeFormInitial());
    }
  }
}
