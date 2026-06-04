import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/modules/app_auth/model/user_model.dart';

// Interface que dita as regras do repositório
abstract class IAuthRepository {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  });
}

// ==============================================================
// 1. A IMPLEMENTAÇÃO REAL (CONECTADA AO SUPABASE)
// ==============================================================
class AuthRepositorySupabase implements IAuthRepository {
  final supabase = Supabase.instance.client;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      // Faz o login nativo do Supabase
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) throw Exception('Usuário não encontrado.');

      // Busca o tipo de conta (role) na NOSSA tabela de perfis
      final profile = await supabase
          .from('profiles')
          .select('account_type')
          .eq('id', user.id)
          .single();

      return UserModel(
        id: user.id,
        name: 'Usuário', // Caso decida adicionar 'name' no Supabase futuramente
        email: user.email!,
        role: profile['account_type'],
      );
    } catch (e) {
      throw Exception(
        'E-mail ou senha incorretos. Verifique suas credenciais.',
      );
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Cria a conta no sistema de Autenticação
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null)
        throw Exception('Falha ao criar o usuário no servidor.');

      // Registra a "role" na nossa tabela 'profiles' para não perdermos essa info
      await supabase.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'account_type': role,
      });

      return UserModel(id: user.id, name: name, email: user.email!, role: role);
    } catch (e) {
      debugPrint('🔴 ERRO SUPABASE: $e');
      throw Exception('Ocorreu um erro ao tentar registrar a conta.');
    }
  }
}

// ==============================================================
// 2. A IMPLEMENTAÇÃO MOCKADA (PARA TESTES OFFLINE)
// ==============================================================
class AuthRepositoryMock implements IAuthRepository {
  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'erro@teste.com') {
      throw Exception('Credenciais inválidas. Tente novamente.');
    }

    return UserModel(
      id: 'mock-123',
      name: 'Usuário Teste',
      email: email,
      role: 'candidato',
    );
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email.isEmpty || password.isEmpty) {
      throw Exception('Falha ao registrar no servidor.');
    }

    return UserModel(id: 'mock-999', name: name, email: email, role: role);
  }
}
