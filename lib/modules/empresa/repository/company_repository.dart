import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/modules/empresa/model/company_model.dart';

abstract class ICompanyRepository {
  Future<void> saveProfile(CompanyModel company);
  Future<CompanyModel?> getProfile(String userId);
}

class CompanyRepositorySupabase implements ICompanyRepository {
  final supabase = Supabase.instance.client;

  @override
  Future<void> saveProfile(CompanyModel company) async {
    try {
      await supabase.from('companies').upsert(company.toMap());
    } catch (e) {
      debugPrint('🔴 ERRO AO SALVAR PERFIL DA EMPRESA: $e');
      throw Exception('Não foi possível salvar os dados da empresa.');
    }
  }

  @override
  Future<CompanyModel?> getProfile(String userId) async {
    try {
      final response = await supabase
          .from('companies')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return CompanyModel.fromMap(response);
    } catch (e) {
      debugPrint('🔴 ERRO AO BUSCAR PERFIL DA EMPRESA: $e');
      return null;
    }
  }
}