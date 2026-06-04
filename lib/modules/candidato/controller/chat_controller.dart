import 'package:flutter/material.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/candidato/usecase/get_interaction_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/schedule_interview_usecase.dart';

class ChatController extends ValueNotifier<AppState<DateTime?>> {
  final IGetInteractionUseCase _getInteractionUseCase;
  final IScheduleInterviewUseCase _scheduleInterviewUseCase;

  // Iniciamos com nulo (sem data agendada)
  ChatController(
    this._getInteractionUseCase,
    this._scheduleInterviewUseCase,
  ) : super(InitialState<DateTime?>());

  // 1. Verifica no banco se já existe uma data agendada
  Future<void> loadChatStatus(String candidateId, String jobId) async {
    value = LoadingState<DateTime?>();

    try {
      final interaction = await _getInteractionUseCase.call(candidateId, jobId);
      
      // O estado de sucesso recebe a data (que pode ser nula, caso ainda não tenha sido agendada)
      value = SuccessState<DateTime?>(interaction?.scheduledAt);
    } catch (e) {
      value = ErrorState<DateTime?>(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 2. Salva a nova data no banco de dados
  Future<void> scheduleInterview(String candidateId, String jobId, DateTime date) async {
    value = LoadingState<DateTime?>();

    try {
      await _scheduleInterviewUseCase.call(candidateId, jobId, date);
      
      // Se deu certo, atualizamos a tela diretamente para a data escolhida!
      value = SuccessState<DateTime?>(date);
    } catch (e) {
      value = ErrorState<DateTime?>(e.toString().replaceAll('Exception: ', ''));
    }
  }
}