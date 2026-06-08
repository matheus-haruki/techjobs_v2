import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/modules/empresa/model/talent_model.dart';
import 'package:techjobs/modules/candidato/model/candidate_model.dart';

abstract class ITalentRepository {
  Future<List<TalentModel>> getAllTalents();
  Future<CandidateModel> getTalentDetails(String candidateId);
}

class TalentRepositorySupabase implements ITalentRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<TalentModel>> getAllTalents() async {
    try {
      final response = await _client
          .from('candidates')
          .select('*, candidate_experiences(*)');
          
      return (response as List).map((map) => TalentModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar talentos: $e');
    }
  }

  @override
  Future<CandidateModel> getTalentDetails(String candidateId) async {
    try {
      final response = await _client
          .from('candidates')
          .select('*, candidate_experiences(*)')
          .eq('id', candidateId)
          .single();

      return CandidateModel.fromMap(response);
    } catch (e) {
      throw Exception('Falha ao buscar os detalhes do candidato: $e');
    }
  }
}