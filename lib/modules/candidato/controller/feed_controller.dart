import 'package:flutter/material.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/model/interaction_model.dart';
import 'package:techjobs/modules/candidato/usecase/get_unseen_jobs_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/register_interaction_usecase.dart';

class FeedController extends ValueNotifier<AppState<List<JobModel>>> {
  final IGetUnseenJobsUseCase _getUnseenJobsUseCase;
  final IRegisterInteractionUseCase _registerInteractionUseCase; // <-- NOVA DEPENDÊNCIA

  FeedController(
    this._getUnseenJobsUseCase,
    this._registerInteractionUseCase, // <-- INJETADO PELO MODULAR
  ) : super(InitialState<List<JobModel>>());

  Future<void> loadJobs(String candidateId) async {
    value = LoadingState<List<JobModel>>();

    try {
      final jobs = await _getUnseenJobsUseCase.call(candidateId);
      value = SuccessState<List<JobModel>>(jobs);
    } catch (e) {
      value = ErrorState<List<JobModel>>(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // NOVO MÉTODO: Registra a ação do usuário sem bloquear a tela
  Future<void> registerAction({
    required String candidateId,
    required String jobId,
    required InteractionStatus status,
  }) async {
    try {
      final interaction = InteractionModel(
        id: '', // O banco de dados (UUID) irá gerar o ID automaticamente
        candidateId: candidateId,
        jobId: jobId,
        status: status,
        createdAt: DateTime.now(),
      );

      await _registerInteractionUseCase.call(interaction);
      debugPrint('✅ Ação $status registrada com sucesso para a vaga $jobId!');
    } catch (e) {
      // Como o card já saiu da tela, não mudamos o estado (value) para ErrorState, 
      // pois isso destruiria a lista de vagas atual. Apenas logamos o erro.
      debugPrint('🔴 Erro ao registrar ação: $e');
    }
  }

  void resetState() {
    value = InitialState<List<JobModel>>();
  }
}