import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:techjobs/core/components/custom_button.dart';
import 'package:techjobs/core/components/custom_input_field.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/core/style/app_fonts.dart';
import 'package:techjobs/modules/app_auth/controller/auth_controller.dart';
import 'package:techjobs/modules/app_auth/model/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = Modular.get<AuthController>();

  final _emailEC = TextEditingController();
  final _passwordEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Escuta as mudanças de estado para disparar ações de UI (Navegação/Snackbars)
    _controller.addListener(_handleStateChange);
  }

  void _handleStateChange() {
    final state = _controller.value;

    if (state is SuccessState<UserModel>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bem-vindo(a) de volta!'),
          backgroundColor: Colors.green,
        ),
      );

      // MÁGICA AQUI: Navegação dinâmica baseada na role!
      if (state.data.role == 'company') {
        Modular.to.navigate('/company/');
      } else {
        Modular.to.navigate('/candidate/');
      }
      
    } else if (state is ErrorState<UserModel>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStateChange);
    _emailEC.dispose();
    _passwordEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Cor de fundo levemente acinzentada
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo
              Center(child: Image.asset('assets/images/logo.png', height: 60)),
              const SizedBox(height: 48),

              Text('Faça seu login aqui :)', style: AppTextStyles.title),
              const SizedBox(height: 4),
              Text('Bem-vindo de volta!', style: AppTextStyles.subtitle),
              const SizedBox(height: 32),

              // Formulário
              CustomInputField(
                label: 'E-mail:',
                hintText: 'Digite seu e-mail',
                controller: _emailEC,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              CustomInputField(
                label: 'Senha:',
                hintText: 'Digite sua senha',
                controller: _passwordEC,
                isPassword: true, // Isso automaticamente liga o "olhinho" de ocultar/mostrar
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Esqueci minha senha',
                    style: TextStyle(color: Color(0xFF5A92AA)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botão Entrar reagindo ao Estado
              ValueListenableBuilder<AppState<UserModel>>(
                valueListenable: _controller,
                builder: (context, state, child) {
                  final isLoading = state is LoadingState<UserModel>;

                  return CustomButton(
                    title: 'Entrar',
                    isLoading: isLoading,
                    onPressed: () => _controller.login(_emailEC.text, _passwordEC.text),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Link para Cadastro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Não possui conta? '),
                  GestureDetector(
                    onTap: () {
                      _controller.resetState();
                      Modular.to.pushNamed('/register'); // Navega para cadastro
                    },
                    child: const Text(
                      'Cadastre-se',
                      style: TextStyle(
                        color: Color(0xFF5A92AA),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}