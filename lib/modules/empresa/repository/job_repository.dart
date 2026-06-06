import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/modules/empresa/model/job_model.dart';

abstract class IJobRepository {
  Future<void> createJob(JobModel job);
  Future<List<JobModel>> getJobsByCompanyId(String companyId);
}

class JobRepositorySupabase implements IJobRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<void> createJob(JobModel job) async {
    try {
      await _client.from('jobs').insert(job.toMap());
    } catch (e) {
      throw Exception('ERRO DO BANCO: $e');
    }
  }

  @override
  Future<List<JobModel>> getJobsByCompanyId(String companyId) async {
    try {
      // Traz as vagas e a lista de status de interações associadas a ela
      final response = await _client
          .from('jobs')
          .select('*, interactions(status)')
          .eq('company_id', companyId)
          .order('created_at', ascending: false);

      return (response as List).map((map) {
        final interactions = map['interactions'] as List? ?? [];
        
        // Conta quantas interações são "like" (inscrito) ou "match"
        final count = interactions.where((i) {
          final status = i['status'];
          return status == 'like' || status == 'match';
        }).length;
        
        // Injeta a contagem no mapa para a factory do JobModel conseguir ler
        map['applicant_count'] = count;
        
        return JobModel.fromMap(map);
      }).toList();
    } catch (e) {
      throw Exception('Falha ao buscar as vagas.');
    }
  }
}