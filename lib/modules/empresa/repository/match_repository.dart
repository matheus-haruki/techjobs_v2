import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/modules/empresa/model/match_model.dart';

abstract class IMatchRepository {
  Future<List<MatchModel>> getMatchesByCompany(String companyId);
  Future<List<MatchModel>> getApplicantsByJob(String jobId);
}

class MatchRepositorySupabase implements IMatchRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<MatchModel>> getMatchesByCompany(String companyId) async {
    try {
      final response = await _client
          .from('interactions') // Trocamos de 'matches' para 'interactions'
          .select('*, jobs!inner(title, company_id), candidates(*)')
          .eq('jobs.company_id', companyId)
          .eq('status', 'match') // Só traz quem já deu match!
          .order('created_at', ascending: false);

      return (response as List).map((map) => MatchModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar as conexões: $e');
    }
  }

  @override
  Future<List<MatchModel>> getApplicantsByJob(String jobId) async {
    try {
      final response = await _client
          .from('interactions') // Trocamos de 'matches' para 'interactions'
          .select('*, jobs!inner(title, company_id), candidates(*)')
          .eq('job_id', jobId)
          // Traz todo mundo que o candidato deu "like" ou que já virou "match"
          .or('status.eq.like,status.eq.match') 
          .order('created_at', ascending: false);

      return (response as List).map((map) => MatchModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar inscritos da vaga: $e');
    }
  }
}