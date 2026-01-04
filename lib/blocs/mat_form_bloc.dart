import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chantier/repository/chantier_repository.dart';

// --- ÉTATS ---
abstract class MaterielFormState extends Equatable {
  const MaterielFormState();
  @override
  List<Object?> get props => [];
}

class MaterielFormInitial extends MaterielFormState {}

class MaterielFormLoading extends MaterielFormState {}

class MaterielFormSuccess extends MaterielFormState {
  final String message;
  const MaterielFormSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class MaterielFormFailure extends MaterielFormState {
  final String error;
  const MaterielFormFailure(this.error);
  @override
  List<Object?> get props => [error];
}

// --- CUBIT ---
class MaterielFormBloc extends Cubit<MaterielFormState> {
  MaterielFormBloc() : super(MaterielFormInitial());

  String nom = '';
  String numeroSerie = '';
  String type = 'petit';
  String coutLocationJournalier = '0';

  final List<String> typesDisponibles = ['petit', 'moyen', 'grand'];

  void updateNom(String value) => nom = value;
  void updateNumeroSerie(String value) => numeroSerie = value;
  void updateType(String? value) {
    if (value != null) type = value;
  }
  void updateCout(String value) => coutLocationJournalier = value;

  Future<void> submit() async {
    // Validations
    if (nom.isEmpty) {
      emit(const MaterielFormFailure("Le nom du matériel est obligatoire"));
      emit(MaterielFormInitial());
      return;
    }
    
    if (type.isEmpty) {
       emit(const MaterielFormFailure("Le type est obligatoire"));
       emit(MaterielFormInitial());
       return;
    }

    if (double.tryParse(coutLocationJournalier) == null) {
      emit(const MaterielFormFailure("Le coût journalier doit être un nombre valide"));
      emit(MaterielFormInitial());
      return;
    }

    emit(MaterielFormLoading());

    try {
      var res = await ChantierRepository().addMatr(
        nom: nom,
        type: type,
        matricule: numeroSerie,
        cout_journalier: int.tryParse(coutLocationJournalier) ?? 0,
      );
      
      if (res != null) {
        emit(const MaterielFormSuccess('Machine créé avec succès.'));
      } else {
        emit(const MaterielFormFailure('Erreur lors de la création du Machine'));
        emit(MaterielFormInitial());
      }
    } catch (e) {
      emit(const MaterielFormFailure('Erreur lors de la création du Machine'));
      emit(MaterielFormInitial());
    }
  }
}
