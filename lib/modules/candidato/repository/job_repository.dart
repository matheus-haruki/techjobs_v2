import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/model/interaction_model.dart';

abstract class IJobRepository {
  Future<List<JobModel>> getUnseenJobs(String candidateId);

  Future<List<JobModel>> getJobsByCompanyId({
    required String companyId,
    required String candidateId,
  });

  Future<List<JobModel>> searchJobs({
    required String candidateId,
    String? keyword,
    WorkModel? workModelFilter,
  });

  Future<List<JobModel>> getMatches(String candidateId);
}

class JobRepositorySupabase implements IJobRepository {
  final supabase = Supabase.instance.client;

  // Constante estática para abstrair a instrução de JOIN repetitiva (DRY)
  static const _selectQuery = '*, companies(name, avatar_url)';

  @override
  Future<List<JobModel>> getUnseenJobs(String candidateId) async {
    try {
      final interactionsResponse = await supabase
          .from('interactions')
          .select('job_id, status')
          .eq('candidate_id', candidateId);

      final interactedJobIds = interactionsResponse
          .map((interaction) => interaction['job_id'] as String)
          .toList();

      var query = supabase.from('jobs').select(_selectQuery);

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
      // 1. Busca interações trazendo o status
      final interactionsRes = await supabase
          .from('interactions')
          .select('job_id, status') // Adicionamos a coluna status
          .eq('candidate_id', candidateId)
          .inFilter('status', [
            InteractionStatus.like.name,
            InteractionStatus.match.name,
          ]);

      // 2. Mapeia o status exato de cada vaga
      final interactionStatusMap = <String, String>{};
      for (final i in interactionsRes) {
        interactionStatusMap[i['job_id'] as String] = i['status'] as String;
      }

      var query = supabase.from('jobs').select(_selectQuery);

      if (keyword != null && keyword.trim().isNotEmpty) {
        query = query.ilike('title', '%${keyword.trim()}%');
      }

      if (workModelFilter != null) {
        query = query.eq('work_model', workModelFilter.name);
      }

      final response = await query.order('created_at', ascending: false);

      return response.map((map) {
        final jobId = map['id'] as String;
        final status = interactionStatusMap[jobId];

        // 3. Injeta as duas flags separadamente
        map['is_subscribed'] = status != null; // Se tem like ou match, está inscrito
        map['is_match'] = status == InteractionStatus.match.name; // Somente se for match

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
      final interactionsRes = await supabase
          .from('interactions')
          .select('job_id, scheduled_at')
          .eq('candidate_id', candidateId)
          .eq('status', InteractionStatus.match.name);

      if (interactionsRes.isEmpty) {
        return [];
      }

      final matchData = <String, String?>{};
      for (final interaction in interactionsRes) {
        final jobId = interaction['job_id'] as String;
        final scheduledAt = interaction['scheduled_at'] as String?;
        matchData[jobId] = scheduledAt;
      }

      final matchJobIds = matchData.keys.toList();

      final response = await supabase
          .from('jobs')
          .select(_selectQuery)
          .filter('id', 'in', matchJobIds)
          .order('created_at', ascending: false);

      return response.map((map) {
        final jobId = map['id'] as String;

        map['is_subscribed'] = true;
        map['is_match'] = true; // Explicita que é match
        map['scheduled_at'] = matchData[jobId];

        return JobModel.fromMap(map);
      }).toList();
    } catch (e) {
      debugPrint('🔴 ERRO AO BUSCAR MATCHES: $e');
      throw Exception('Não foi possível carregar as suas conexões.');
    }
  }

  @override
  Future<List<JobModel>> getJobsByCompanyId({
    required String companyId,
    required String candidateId,
  }) async {
    try {
      // 1. Busca interações trazendo o status
      final interactionsRes = await supabase
          .from('interactions')
          .select('job_id, status')
          .eq('candidate_id', candidateId)
          .inFilter('status', [
            InteractionStatus.like.name,
            InteractionStatus.match.name,
          ]);

      // 2. Mapeia o status exato de cada vaga
      final interactionStatusMap = <String, String>{};
      for (final i in interactionsRes) {
        interactionStatusMap[i['job_id'] as String] = i['status'] as String;
      }

      // 3. Busca as vagas específicas da empresa
      final response = await supabase
          .from('jobs')
          .select(_selectQuery)
          .eq('company_id', companyId)
          .order('created_at', ascending: false);

      // 4. Injeta as flags de inscrição e match baseadas no cruzamento de dados
      return response.map((map) {
        final jobId = map['id'] as String;
        final status = interactionStatusMap[jobId];

        map['is_subscribed'] = status != null; // Se tem like ou match, está inscrito
        map['is_match'] = status == InteractionStatus.match.name; // Somente se for match

        return JobModel.fromMap(map);
      }).toList();
    } catch (e) {
      debugPrint('🔴 ERRO AO BUSCAR VAGAS DA EMPRESA: $e');
      throw Exception('Não foi possível carregar as vagas desta empresa.');
    }
  }
}