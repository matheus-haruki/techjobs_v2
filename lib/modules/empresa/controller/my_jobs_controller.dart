import 'package:flutter/material.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/empresa/model/job_model.dart';
import 'package:techjobs/modules/empresa/usecase/create_job_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/get_my_jobs_usecase.dart';

class MyJobsController extends ValueNotifier<AppState<List<JobModel>>> {
  final ICreateJobUseCase _createJobUseCase;
  final IGetMyJobsUseCase _getMyJobsUseCase;

  MyJobsController(
    this._createJobUseCase,
    this._getMyJobsUseCase,
  ) : super(InitialState<List<JobModel>>());

  // 1. Busca todas as vagas da empresa e atualiza a tela
  Future<void> loadJobs(String companyId) async {
    value = LoadingState<List<JobModel>>();
    
    try {
      final jobs = await _getMyJobsUseCase.call(companyId);
      value = SuccessState<List<JobModel>>(jobs);
    } catch (e) {
      value = ErrorState<List<JobModel>>(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 2. Salva uma vaga nova e já recarrega a lista para mostrar na hora
  Future<bool> createJob(JobModel job) async {
    value = LoadingState<List<JobModel>>();
    
    try {
      await _createJobUseCase.call(job);
      
      // Assim que salvar no Supabase, recarregamos a lista atualizada
      await loadJobs(job.companyId);
      
      return true; // Avisa a tela (UI) que deu certo e pode fechar o formulário
    } catch (e) {
      value = ErrorState<List<JobModel>>(e.toString().replaceAll('Exception: ', ''));
      return false; // Avisa a tela que deu erro
    }
  }
}