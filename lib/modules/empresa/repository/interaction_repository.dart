import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/modules/empresa/model/interaction_model.dart';

abstract class IInteractionRepository {
  Future<void> registerInteraction(InteractionModel interaction);
  Future<List<InteractionModel>> getInteractionsByJob(String jobId);
  Future<InteractionModel?> getInteraction(String candidateId, String jobId); // NOVO
}

class InteractionRepositorySupabase implements IInteractionRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<void> registerInteraction(InteractionModel interaction) async {
    try {
      await _client.from('interactions').upsert(
        interaction.toMap(),
        onConflict: 'candidate_id,job_id',
      );
    } catch (e) {
      throw Exception('ERRO REAL DO BANCO: $e');
    }
  }

  @override
  Future<List<InteractionModel>> getInteractionsByJob(String jobId) async {
    try {
      final response = await _client.from('interactions').select().eq('job_id', jobId);
      return (response as List).map((map) => InteractionModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar interações da vaga: $e');
    }
  }

  // NOVO: Busca uma interação específica
  @override
  Future<InteractionModel?> getInteraction(String candidateId, String jobId) async {
    try {
      final response = await _client
          .from('interactions')
          .select()
          .eq('candidate_id', candidateId)
          .eq('job_id', jobId)
          .maybeSingle();

      if (response == null) return null;
      return InteractionModel.fromMap(response);
    } catch (e) {
      return null; // Falha silenciosa para não travar o swipe
    }
  }
}