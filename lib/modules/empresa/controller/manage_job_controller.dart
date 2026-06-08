import 'package:flutter/material.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/empresa/model/match_model.dart';
import 'package:techjobs/modules/empresa/repository/match_repository.dart';
import 'package:techjobs/modules/empresa/usecase/delete_job_usecase.dart'; // <-- NOVO IMPORT

class ManageJobController {
  final IMatchRepository _repository;
  final IDeleteJobUseCase _deleteJobUseCase; // <-- NOVA DEPENDÊNCIA

  // Gerencia o estado da lista de inscritos (Loading, Sucesso, Erro)
  final applicantsState = ValueNotifier<AppState<List<MatchModel>>>(InitialState());

  // Construtor atualizado para receber o caso de uso
  ManageJobController(this._repository, this._deleteJobUseCase);

  Future<void> loadApplicants(String jobId) async {
    applicantsState.value = LoadingState();

    try {
      final applicants = await _repository.getApplicantsByJob(jobId);
      applicantsState.value = SuccessState(applicants);
    } catch (e) {
      applicantsState.value = ErrorState(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // --- NOVO MÉTODO DE DELEÇÃO ---
  Future<void> deleteJob(String jobId) async {
    // Como a tela exibe um loading nativo ou trava no await, 
    // não precisamos criar um ValueNotifier separado para a deleção.
    // Apenas repassamos a chamada para o UseCase.
    await _deleteJobUseCase.call(jobId);
  }
}