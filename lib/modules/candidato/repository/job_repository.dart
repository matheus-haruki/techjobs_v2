import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/model/interaction_model.dart';

abstract class IJobRepository {
  Future<List<JobModel>> getUnseenJobs(String candidateId);

  Future<List<JobModel>> searchJobs({
    required String candidateId,
    String? keyword,
    WorkModel? workModelFilter,
  });

  // Nova assinatura para buscar conexões
  Future<List<JobModel>> getMatches(String candidateId);
}

class JobRepositorySupabase implements IJobRepository {
  final supabase = Supabase.instance.client;

  @override
  Future<List<JobModel>> getUnseenJobs(String candidateId) async {
    try {
      final interactionsResponse = await supabase
          .from('interactions')
          .select('job_id')
          .eq('candidate_id', candidateId);

      final interactedJobIds = interactionsResponse
          .map((interaction) => interaction['job_id'] as String)
          .toList();

      var query = supabase.from('jobs').select();

      if (interactedJobIds.isNotEmpty) {
        final formattedIds = '(${interactedJobIds.join(',')})';
        query = query.filter('id', 'not.in', formattedIds);
      }

      final response = await query;
      return response.map((map) => JobModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('🔴 ERRO AO BUSCAR VAGAS INÉDITAS: $e');
      throw Exception('Não foi possível carregar o feed de vagas.');
    }
  }

  @override
  Future<List<JobModel>> searchJobs({
    required String candidateId,
    String? keyword,
    WorkModel? workModelFilter,
  }) async {
    try {
      final interactionsRes = await supabase
          .from('interactions')
          .select('job_id')
          .eq('candidate_id', candidateId)
          .inFilter('status', [
            InteractionStatus.like.name,
            InteractionStatus.match.name,
          ]);

      final subscribedJobIds = interactionsRes
          .map((i) => i['job_id'] as String)
          .toSet();

      var query = supabase.from('jobs').select();

      if (keyword != null && keyword.trim().isNotEmpty) {
        query = query.or(
          'title.ilike.%${keyword.trim()}%,company_name.ilike.%${keyword.trim()}%',
        );
      }

      if (workModelFilter != null) {
        query = query.eq('work_model', workModelFilter.name);
      }

      final response = await query.order('created_at', ascending: false);

      return response.map((map) {
        final jobId = map['id'] as String;
        map['is_subscribed'] = subscribedJobIds.contains(jobId);

        return JobModel.fromMap(map);
      }).toList();
    } catch (e) {
      debugPrint('🔴 ERRO AO BUSCAR VAGAS: $e');
      throw Exception('Não foi possível realizar a busca de vagas.');
    }
  }

  @override
  Future<List<JobModel>> getMatches(String candidateId) async {
    try {
      // 1. Busca os IDs das interações que resultaram em match e a data de agendamento (se existir)
      final interactionsRes = await supabase
          .from('interactions')
          .select('job_id, scheduled_at')
          .eq('candidate_id', candidateId)
          .eq('status', InteractionStatus.match.name);

      // Early return pattern: interrompe a execução se não houver matches
      if (interactionsRes.isEmpty) {
        return [];
      }

      // 2. Cria um mapa (Hash Map) vinculando o ID da vaga à data agendada para busca O(1)
      final matchData = <String, String?>{};
      for (final interaction in interactionsRes) {
        final jobId = interaction['job_id'] as String;
        final scheduledAt = interaction['scheduled_at'] as String?;
        matchData[jobId] = scheduledAt;
      }

      final matchJobIds = matchData.keys.toList();

      // 3. Busca as vagas correspondentes filtrando pela lista de IDs
      final response = await supabase
          .from('jobs')
          .select()
          .filter('id', 'in', matchJobIds)
          .order('created_at', ascending: false);

      // 4. Data Mapper: Injeta os dados da interação no mapa da vaga antes de serializar
      return response.map((map) {
        final jobId = map['id'] as String;

        map['is_subscribed'] = true;
        map['scheduled_at'] = matchData[jobId]; // <-- Injeção dinâmica da data

        return JobModel.fromMap(map);
      }).toList();
    } catch (e) {
      debugPrint('🔴 ERRO AO BUSCAR MATCHES: $e');
      throw Exception('Não foi possível carregar as suas conexões.');
    }
  }
}
