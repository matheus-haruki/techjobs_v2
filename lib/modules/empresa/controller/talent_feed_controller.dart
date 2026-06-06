import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/empresa/model/job_model.dart';
import 'package:techjobs/modules/empresa/model/talent_model.dart';
import 'package:techjobs/modules/empresa/model/interaction_model.dart';
import 'package:techjobs/modules/empresa/usecase/get_my_jobs_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/get_talents_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/register_interaction_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/get_job_interactions_usecase.dart';

class TalentFeedController {
  final IGetTalentsUseCase _getTalentsUseCase;
  final IGetMyJobsUseCase _getMyJobsUseCase;
  final IRegisterInteractionUseCase _registerInteractionUseCase;
  final IGetJobInteractionsUseCase _getJobInteractionsUseCase; // NOVO

  final talentsState = ValueNotifier<AppState<List<TalentModel>>>(InitialState());
  final activeJobs = ValueNotifier<List<JobModel>>([]);
  final selectedJob = ValueNotifier<JobModel?>(null);

  // CACHE: Guarda todos os talentos para não precisar baixar da internet toda hora
  List<TalentModel> _allTalentsCache = [];

  TalentFeedController(
    this._getTalentsUseCase,
    this._getMyJobsUseCase,
    this._registerInteractionUseCase,
    this._getJobInteractionsUseCase,
  );

  Future<void> loadFeedData() async {
    talentsState.value = LoadingState();

    try {
      final companyId = Supabase.instance.client.auth.currentUser?.id;
      if (companyId == null) throw Exception('Sessão expirada. Faça login novamente.');

      final results = await Future.wait([
        _getMyJobsUseCase.call(companyId),
        _getTalentsUseCase.call(),
      ]);

      final myJobs = results[0] as List<JobModel>;
      _allTalentsCache = results[1] as List<TalentModel>;

      final availableJobs = myJobs.where((job) => job.isActive).toList();
      activeJobs.value = availableJobs;

      if (availableJobs.isNotEmpty) {
        // Ao invés de só setar o valor, chamamos o selectJob para disparar o filtro!
        await selectJob(availableJobs.first);
      } else {
        talentsState.value = SuccessState<List<TalentModel>>([]);
      }
    } catch (e) {
      talentsState.value = ErrorState(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // A INTELIGÊNCIA DO FILTRO ESTÁ AQUI!
  Future<void> selectJob(JobModel job) async {
    selectedJob.value = job;
    talentsState.value = LoadingState();

    try {
      final interactions = await _getJobInteractionsUseCase.call(job.id);
      
      // 🚨 MUDANÇA AQUI: Só filtramos os status que vieram da ação da EMPRESA
      final companyActions = [
        InteractionStatus.match, 
        InteractionStatus.company_like, 
        InteractionStatus.company_dislike
      ];

      final swipedCandidateIds = interactions
          .where((i) => companyActions.contains(i.status)) // Filtra pelas ações da empresa
          .map((i) => i.candidateId)
          .toSet();

      final unseenTalents = _allTalentsCache.where(
        (talent) => !swipedCandidateIds.contains(talent.id)
      ).toList();

      talentsState.value = SuccessState<List<TalentModel>>(unseenTalents);
    } catch (e) {
      talentsState.value = ErrorState('Erro ao filtrar talentos: $e');
    }
  }

  Future<void> registerSwipe({
    required TalentModel talent,
    required InteractionStatus status,
  }) async {
    final currentJob = selectedJob.value;
    if (currentJob == null) return;

    try {
      await _registerInteractionUseCase.call(
        candidateId: talent.id,
        jobId: currentJob.id,
        status: status,
      );
    } catch (e) {
      debugPrint('Erro ao registrar swipe: $e');
    }
  }

  void markFeedAsEmpty() {
    talentsState.value = SuccessState<List<TalentModel>>([]);
  }
}