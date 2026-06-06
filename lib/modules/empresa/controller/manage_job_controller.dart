import 'package:flutter/material.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/empresa/model/match_model.dart';
import 'package:techjobs/modules/empresa/repository/match_repository.dart';

class ManageJobController {
  final IMatchRepository _repository;

  // Gerencia o estado da lista de inscritos (Loading, Sucesso, Erro)
  final applicantsState = ValueNotifier<AppState<List<MatchModel>>>(InitialState());

  ManageJobController(this._repository);

  Future<void> loadApplicants(String jobId) async {
    applicantsState.value = LoadingState();

    try {
      final applicants = await _repository.getApplicantsByJob(jobId);
      applicantsState.value = SuccessState(applicants);
    } catch (e) {
      applicantsState.value = ErrorState(e.toString().replaceAll('Exception: ', ''));
    }
  }
}