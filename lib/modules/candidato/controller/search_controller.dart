import 'package:flutter/material.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/usecase/search_jobs_usecase.dart';

class SearchController extends ValueNotifier<AppState<List<JobModel>>> {
  final ISearchJobsUseCase _searchJobsUseCase;

  SearchController(this._searchJobsUseCase) : super(InitialState<List<JobModel>>());

  Future<void> searchJobs({
    required String candidateId,
    String? keyword,
    WorkModel? workModelFilter,
  }) async {
    // 1. Avisa a UI que a busca começou (mostra o loading)
    value = LoadingState<List<JobModel>>();

    try {
      // 2. Chama o Caso de Uso passando os filtros (se houverem)
      final jobs = await _searchJobsUseCase.call(
        candidateId: candidateId,
        keyword: keyword,
        workModelFilter: workModelFilter,
      );
      
      // 3. Devolve a lista preenchida para a tela
      value = SuccessState<List<JobModel>>(jobs);
    } catch (e) {
      // 4. Trata possíveis falhas de conexão
      value = ErrorState<List<JobModel>>(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void resetState() {
    value = InitialState<List<JobModel>>();
  }
}