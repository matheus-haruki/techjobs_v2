import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/candidato/model/company_model.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/usecase/get_company_jobs_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/get_company_profile_usecase.dart';

class CompanyDetailsController extends ValueNotifier<AppState<CompanyModel>> {
  final IGetCompanyProfileUseCase _getCompanyProfileUseCase;
  final IGetCompanyJobsUseCase _getCompanyJobsUseCase;

  // Estado paralelo para gerenciar as vagas de forma independente
  final jobsState = ValueNotifier<AppState<List<JobModel>>>(InitialState());

  CompanyDetailsController(
    this._getCompanyProfileUseCase,
    this._getCompanyJobsUseCase,
  ) : super(InitialState());

  Future<void> loadCompanyData(String companyId) async {
    value = LoadingState<CompanyModel>();
    jobsState.value = LoadingState<List<JobModel>>();

    // 1. Busca os dados do Perfil
    try {
      final company = await _getCompanyProfileUseCase.call(companyId);
      value = SuccessState<CompanyModel>(company);
    } catch (e) {
      value = ErrorState<CompanyModel>(e.toString().replaceAll('Exception: ', ''));
    }

    // 2. Busca as Vagas
    try {
      final candidateId = Supabase.instance.client.auth.currentUser?.id;
      if (candidateId == null) {
        throw Exception('Sessão expirada ou usuário não autenticado.');
      }

      final jobs = await _getCompanyJobsUseCase.call(
        companyId: companyId,
        candidateId: candidateId,
      );
      
      jobsState.value = SuccessState<List<JobModel>>(jobs);
    } catch (e) {
      jobsState.value = ErrorState<List<JobModel>>(e.toString().replaceAll('Exception: ', ''));
    }
  }
}