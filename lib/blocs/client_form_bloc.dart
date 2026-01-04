import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chantier/repository/chantier_repository.dart';

// --- ÉTATS ---
abstract class ClientFormState extends Equatable {
  const ClientFormState();
  @override
  List<Object?> get props => [];
}

class ClientFormInitial extends ClientFormState {}

class ClientFormLoading extends ClientFormState {}

class ClientFormSuccess extends ClientFormState {
  final String message;
  const ClientFormSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ClientFormFailure extends ClientFormState {
  final String error;
  const ClientFormFailure(this.error);
  @override
  List<Object?> get props => [error];
}

// --- CUBIT ---
class ClientFormBloc extends Cubit<ClientFormState> {
  ClientFormBloc() : super(ClientFormInitial());

  String nom = '';
  String email = '';
  String telephone = '';
  String adresse = '';
  String ville = '';
  String pays = '';

  void updateNom(String value) => nom = value;
  void updateEmail(String value) => email = value;
  void updateTelephone(String value) => telephone = value;
  void updateAdresse(String value) => adresse = value;
  void updateVille(String value) => ville = value;
  void updatePays(String value) => pays = value;

  Future<void> submit() async {
    // Validation
    if (nom.isEmpty) {
      emit(const ClientFormFailure("Le nom est obligatoire"));
      emit(ClientFormInitial());
      return;
    }
    
    if (email.isEmpty) {
       emit(const ClientFormFailure("L'email est obligatoire"));
       emit(ClientFormInitial());
       return;
    }

    // Validation email simple
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      emit(const ClientFormFailure("Format d'email invalide"));
      emit(ClientFormInitial());
      return;
    }

    emit(ClientFormLoading());

    try {
      var res = await ChantierRepository().addClient(
        nom: nom,
        email: email,
        telephone: telephone,
        adresse: adresse,
        ville: ville,
        pays: pays,
      );
      
      if (res != null) {
        emit(const ClientFormSuccess('Client créé avec succès.'));
      } else {
        emit(const ClientFormFailure('Erreur lors de la création du client'));
        emit(ClientFormInitial());
      }
    } catch (e) {
      emit(ClientFormFailure('Erreur: ${e.toString()}'));
      emit(ClientFormInitial());
    }
  }
}
