import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/modules/candidato/model/candidate_model.dart';

abstract class ICandidateRepository {
  Future<void> saveProfile(CandidateModel candidate);
  Future<CandidateModel> getProfile(String userId);
  // Nova assinatura para manipulação de arquivos
  Future<String> uploadAvatar({
    required String candidateId,
    required File imageFile,
  });
}

class CandidateRepositorySupabase implements ICandidateRepository {
  final supabase = Supabase.instance.client;

  @override
  Future<void> saveProfile(CandidateModel candidate) async {
    try {
      await supabase.from('candidates').upsert(candidate.toMap());

      await supabase
          .from('candidate_experiences')
          .delete()
          .eq('candidate_id', candidate.id);

      if (candidate.experiences.isNotEmpty) {
        final experiencesMap = candidate.experiences.map((exp) {
          final map = exp.toMap();
          map['candidate_id'] = candidate.id;

          if (map['id'] == null || map['id'] == '') {
            map.remove('id');
          }
          return map;
        }).toList();

        await supabase.from('candidate_experiences').insert(experiencesMap);
      }
    } catch (e) {
      debugPrint('🔴 ERRO AO SALVAR PERFIL DO CANDIDATO: $e');
      throw Exception('Não foi possível salvar os dados do seu perfil.');
    }
  }

  @override
  Future<CandidateModel> getProfile(String userId) async {
    try {
      final response = await supabase
          .from('candidates')
          .select('*, candidate_experiences(*)')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return CandidateModel(id: userId, name: '');
      }

      return CandidateModel.fromMap(response);
    } catch (e) {
      debugPrint('🔴 ERRO AO BUSCAR PERFIL DO CANDIDATO: $e');
      throw Exception('Não foi possível carregar os dados do perfil.');
    }
  }

  @override
  Future<String> uploadAvatar({
    required String candidateId,
    required File imageFile,
  }) async {
    try {
      // 1. Caminho estático para evitar lixo no Storage
      final path = '$candidateId/avatar.jpg';

      // 2. Upload com upsert para sobrescrever imagens antigas
      await supabase.storage
          .from('avatars')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // 3. Recupera o link público gerado
      final baseUrl = supabase.storage.from('avatars').getPublicUrl(path);

      // 4. Estratégia de "Cache Busting"
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '$baseUrl?t=$timestamp';
    } catch (e) {
      debugPrint('🔴 ERRO AO FAZER UPLOAD DO AVATAR: $e');
      throw Exception('Não foi possível enviar a foto de perfil.');
    }
  }
}
