import 'package:flutter/material.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/usecase/get_matches_usecase.dart';

class ConnectionsController extends ValueNotifier<AppState<List<JobModel>>> {
  final IGetMatchesUseCase _getMatchesUseCase;

  ConnectionsController(this._getMatchesUseCase) : super(InitialState<List<JobModel>>());

  Future<void> loadConnections(String candidateId, {bool isSilent = false}) async {
    // Só emite estado de Loading se não for um refresh silencioso (evita flicker na UI)
    if (!isSilent) {
      value = LoadingState<List<JobModel>>();
    }

    try {
      final jobs = await _getMatchesUseCase.call(candidateId);
      value = SuccessState<List<JobModel>>(jobs);
    } catch (e) {
      value = ErrorState<List<JobModel>>(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void resetState() {
    value = InitialState<List<JobModel>>();
  }
}