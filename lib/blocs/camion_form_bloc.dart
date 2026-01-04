import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chantier/repository/chantier_repository.dart';

// --- ÉTATS ---
abstract class CamionFormState extends Equatable {
  const CamionFormState();
  @override
  List<Object?> get props => [];
}

class CamionFormInitial extends CamionFormState {}

class CamionFormLoading extends CamionFormState {}

class CamionFormSuccess extends CamionFormState {
  final String message;
  const CamionFormSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class CamionFormFailure extends CamionFormState {
  final String error;
  const CamionFormFailure(this.error);
  @override
  List<Object?> get props => [error];
}

// --- CUBIT ---
class CamionFormBloc extends Cubit<CamionFormState> {
  CamionFormBloc() : super(CamionFormInitial());

  String nom = '';
  String immatriculation = '';
  String capaciteCharge = '0';

  void updateNom(String value) => nom = value;
  void updateImmatriculation(String value) => immatriculation = value;
  void updateCapacite(String value) => capaciteCharge = value;

  Future<void> submit() async {
    if (nom.isEmpty || immatriculation.isEmpty) {
      emit(const CamionFormFailure("Veuillez remplir tous les champs obligatoires (Nom, Matricule)"));
      emit(CamionFormInitial()); // Reset status to allow retry
      return;
    }
    
    // Validation simple pour la capacité (doit être un nombre)
    if (double.tryParse(capaciteCharge) == null) {
       emit(const CamionFormFailure("La capacité doit être un nombre valide"));
       emit(CamionFormInitial());
       return;
    }

    emit(CamionFormLoading());

    try {
      var res = await ChantierRepository().addCamion(
        nom: nom,
        capacite: capaciteCharge,
        matricule: immatriculation,
      );

      if (res != null) {
        emit(const CamionFormSuccess('Camion créé avec succès.'));
      } else {
        emit(const CamionFormFailure('Erreur lors de la création du camion'));
        emit(CamionFormInitial());
      }
    } catch (e) {
      emit(const CamionFormFailure('Erreur lors de la création du camion'));
      emit(CamionFormInitial());
    }
  }
}
