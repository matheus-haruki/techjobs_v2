import 'dart:io'; // Necessário para o tipo File
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/modules/empresa/model/company_model.dart';

// 1. O Contrato: Agora declaramos o uploadAvatar aqui
abstract class ICompanyRepository {
  Future<void> saveProfile(CompanyModel company);
  Future<CompanyModel?> getProfile(String id);
  Future<String> uploadAvatar(String companyId, File image); 
}

// 2. A Implementação
class CompanyRepositorySupabase implements ICompanyRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<void> saveProfile(CompanyModel company) async {
    try {
      await _client.from('companies').upsert(company.toMap());
    } catch (e) {
      throw Exception('Falha ao salvar o perfil no banco de dados. Tente novamente.');
    }
  }

  @override
  Future<CompanyModel?> getProfile(String id) async {
    try {
      final response = await _client
          .from('companies')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return CompanyModel.fromMap(response);
    } catch (e) {
      throw Exception('Falha ao buscar os dados da empresa.');
    }
  }

  @override
  Future<String> uploadAvatar(String companyId, File image) async {
    try {
      // Gera um nome único para o arquivo baseado na data/hora atual
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      // Cria o caminho organizando por pastas com o ID da empresa
      final filePath = '$companyId/$fileName';

      // Faz o upload para o bucket chamado 'avatars' no Supabase
      await _client.storage.from('avatars').upload(
        filePath,
        image,
        fileOptions: const FileOptions(upsert: true),
      );

      // Retorna a URL pública gerada para podermos salvar na tabela 'companies'
      return _client.storage.from('avatars').getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem. Verifique sua conexão.');
    }
  }
}