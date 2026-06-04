import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/modules/candidato/model/interaction_model.dart';

abstract class IInteractionRepository {
  Future<void> registerInteraction(InteractionModel interaction);
  
  Future<InteractionModel?> getInteraction(String candidateId, String jobId);
  Future<void> scheduleInterview(String candidateId, String jobId, DateTime date);
}

class InteractionRepositorySupabase implements IInteractionRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<void> registerInteraction(InteractionModel interaction) async {
    try {
      await supabase.from('interactions').insert(interaction.toMap());
    } catch (e) {
      debugPrint('🔴 ERRO AO REGISTRAR INTERAÇÃO: $e');
      throw Exception('Não foi possível registrar a sua ação.');
    }
  }

  @override
  Future<InteractionModel?> getInteraction(String candidateId, String jobId) async {
    try {
      final response = await supabase
          .from('interactions')
          .select()
          .eq('candidate_id', candidateId)
          .eq('job_id', jobId)
          .maybeSingle(); // Retorna 1 registo ou null

      if (response == null) return null;
      
      return InteractionModel.fromMap(response);
    } catch (e) {
      debugPrint('🔴 ERRO AO BUSCAR INTERAÇÃO: $e');
      throw Exception('Não foi possível carregar os dados da conexão.');
    }
  }

  @override
  Future<void> scheduleInterview(String candidateId, String jobId, DateTime date) async {
    try {
      await supabase
          .from('interactions')
          .update({'scheduled_at': date.toIso8601String()})
          .eq('candidate_id', candidateId)
          .eq('job_id', jobId);
    } catch (e) {
      debugPrint('🔴 ERRO AO AGENDAR ENTREVISTA: $e');
      throw Exception('Não foi possível agendar a entrevista.');
    }
  }
}