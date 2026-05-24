import 'package:flutter/material.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/app_auth/model/user_model.dart';
import 'package:techjobs/modules/app_auth/usecases/login_usecase.dart';
import 'package:techjobs/modules/app_auth/usecases/register_usecase.dart';

// O Controller agora estende ValueNotifier passando o nosso AppState tipado com UserModel
class AuthController extends ValueNotifier<AppState<UserModel>> {
  final ILoginUseCase _loginUseCase;
  final IRegisterUseCase _registerUseCase;

  AuthController(this._loginUseCase, this._registerUseCase)
    : super(InitialState<UserModel>()); // Estado inicializado

  Future<void> login(String email, String password) async {
    value = LoadingState<UserModel>();

    try {
      final user = await _loginUseCase.call(email, password);
      value = SuccessState<UserModel>(user); // Passa o user para o data
    } catch (e) {
      value = ErrorState<UserModel>(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    value = LoadingState<UserModel>();

    try {
      final user = await _registerUseCase.call(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      value = SuccessState<UserModel>(user);
    } catch (e) {
      value = ErrorState<UserModel>(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void resetState() {
    value = InitialState<UserModel>();
  }
}
