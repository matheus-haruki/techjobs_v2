import 'package:flutter/material.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/usecase/get_matches_usecase.dart';

class ConnectionsController extends ValueNotifier<AppState<List<JobModel>>> {
  final IGetMatchesUseCase _getMatchesUseCase;

  ConnectionsController(this._getMatchesUseCase) : super(InitialState<List<JobModel>>());

  Future<void> loadConnections(String candidateId) async {
    // Transita para o estado de carregamento
    value = LoadingState<List<JobModel>>();

    try {
      // Executa o caso de uso e recupera a lista de Matches
      final jobs = await _getMatchesUseCase.call(candidateId);
      
      // Transita para o estado de sucesso
      value = SuccessState<List<JobModel>>(jobs);
    } catch (e) {
      // Intercepta a falha e atualiza o estado com a mensagem de erro
      value = ErrorState<List<JobModel>>(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void resetState() {
    value = InitialState<List<JobModel>>();
  }
}