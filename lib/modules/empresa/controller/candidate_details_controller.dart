import 'package:flutter/material.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/candidato/model/candidate_model.dart';
import 'package:techjobs/modules/empresa/model/interaction_model.dart';
import 'package:techjobs/modules/empresa/repository/talent_repository.dart';
import 'package:techjobs/modules/empresa/usecase/register_interaction_usecase.dart';

class CandidateDetailsController {
  final ITalentRepository _talentRepository;
  final IRegisterInteractionUseCase _registerInteractionUseCase;

  // Estado que controla a exibição do perfil na tela
  final detailsState = ValueNotifier<AppState<CandidateModel>>(InitialState());
  
  // Estado que controla o botão de Like (para mostrar um loading só no botão)
  final likeActionState = ValueNotifier<AppState<void>>(InitialState());

  CandidateDetailsController(
    this._talentRepository,
    this._registerInteractionUseCase,
  );

  Future<void> loadCandidate(String candidateId) async {
    detailsState.value = LoadingState();

    try {
      final candidate = await _talentRepository.getTalentDetails(candidateId);
      detailsState.value = SuccessState(candidate);
    } catch (e) {
      detailsState.value = ErrorState(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> likeCandidate({
    required String candidateId,
    required String jobId,
  }) async {
    likeActionState.value = LoadingState();

    try {
      // Passamos InteractionStatus.like. A nossa "Máquina de Estados" no UseCase 
      // vai ver que o candidato já curtiu e vai transformar isso num "match" automaticamente!
      await _registerInteractionUseCase.call(
        candidateId: candidateId,
        jobId: jobId,
        status: InteractionStatus.like,
      );
      
      likeActionState.value = SuccessState(null);
      return true; // Retornamos true para a View saber que deu certo e voltar pra tela anterior
    } catch (e) {
      likeActionState.value = ErrorState(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }
}