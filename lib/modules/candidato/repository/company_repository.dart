import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/modules/candidato/model/company_model.dart';

abstract class ICompanyRepository {
  Future<CompanyModel> getCompanyById(String companyId);
}

class CompanyRepositorySupabase implements ICompanyRepository {
  final supabase = Supabase.instance.client;

  @override
  Future<CompanyModel> getCompanyById(String companyId) async {
    try {
      final response = await supabase
          .from('companies')
          .select('id, name, location, description, avatar_url')
          .eq('id', companyId)
          .single(); // Exige que retorne apenas 1 resultado

      return CompanyModel.fromMap(response);
    } catch (e) {
      throw Exception('Não foi possível carregar o perfil da empresa.');
    }
  }
}