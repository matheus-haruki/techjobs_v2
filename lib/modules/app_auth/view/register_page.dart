import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:techjobs/core/components/custom_button.dart';
import 'package:techjobs/core/components/custom_input_field.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/core/style/app_fonts.dart';
import 'package:techjobs/modules/app_auth/controller/auth_controller.dart';
import 'package:techjobs/modules/app_auth/model/user_model.dart';
// Imports necessários para construir o modelo vazio de onboarding
import 'package:techjobs/modules/candidato/model/candidate_model.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart'; // Ajuste o caminho do seu enum WorkModel se estiver em outro arquivo

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _controller = Modular.get<AuthController>();

  final _nameEC = TextEditingController();
  final _emailEC = TextEditingController();
  final _cnpjEC = TextEditingController();
  final _passwordEC = TextEditingController();
  final _confirmPasswordEC = TextEditingController();

  final _passwordFocusNode = FocusNode();

  String _selectedRole = 'candidato';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleStateChange);
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  void _handleStateChange() {
    final state = _controller.value;

    if (state is SuccessState<UserModel>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conta criada! Bem-vindo, ${state.data.name}'),
          backgroundColor: Colors.green,
        ),
      );

      if (state.data.role == 'company') {
        Modular.to.pushNamedAndRemoveUntil('/company/', (route) => false);
      } else {
        final newCandidate = CandidateModel(
          id: state.data.id,
          name: state.data.name,
          bio: null,
          role: null,
          location: null,
          avatarUrl: null,
          skills: [],
          experiences: [],
        );

        // NAVEGAÇÃO NATIVA RESTRITA
        // Remove todo o histórico de navegação ((route) => false) e injeta a edição como raiz.
        Modular.to.pushNamedAndRemoveUntil(
          '/candidate/edit-profile',
          (route) => false,
          arguments: newCandidate,
        );
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
    _nameEC.dispose();
    _emailEC.dispose();
    _cnpjEC.dispose();
    _passwordEC.dispose();
    _confirmPasswordEC.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Widget _buildValidationRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Image.asset('assets/images/logo.png', height: 60)),
              const SizedBox(height: 48),

              RichText(
                text: TextSpan(
                  style: AppTextStyles.title,
                  children: [
                    const TextSpan(text: 'Seja bem-vindo, '),
                    TextSpan(
                      text: _selectedRole == 'empresa' ? 'Empresa' : 'Novato',
                      style: _selectedRole == 'empresa'
                          ? AppTextStyles.titleId
                          : AppTextStyles.titleIdCandidato,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedRole = 'candidato'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedRole == 'candidato'
                                ? const Color(0xFF5A92AA)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Candidato',
                            style: TextStyle(
                              color: _selectedRole == 'candidato'
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'empresa'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedRole == 'empresa'
                                ? AppColors.secondary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Empresa',
                            style: TextStyle(
                              color: _selectedRole == 'empresa'
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              CustomInputField(
                label: _selectedRole == 'empresa'
                    ? 'Nome da empresa:'
                    : 'Nome:',
                hintText: _selectedRole == 'empresa'
                    ? 'Digite o nome da empresa'
                    : 'Seu nome',
                controller: _nameEC,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),

              CustomInputField(
                label: 'E-mail:',
                hintText: 'Digite seu e-mail',
                controller: _emailEC,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              if (_selectedRole == 'empresa') ...[
                CustomInputField(
                  label: 'CNPJ:',
                  hintText: 'Digite o CNPJ',
                  controller: _cnpjEC,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],

              CustomInputField(
                label: 'Senha:',
                hintText: 'Crie uma senha',
                controller: _passwordEC,
                focusNode: _passwordFocusNode,
                isPassword: true,
              ),
              const SizedBox(height: 8),

              if (_passwordFocusNode.hasFocus)
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _passwordEC,
                  builder: (context, value, child) {
                    final text = value.text;
                    final hasMinLength = text.length >= 8;
                    final hasLowercase = RegExp(r'[a-z]').hasMatch(text);
                    final hasUppercase = RegExp(r'[A-Z]').hasMatch(text);
                    final hasNumberOrSpecial = RegExp(
                      r'[^a-zA-Z\s]',
                    ).hasMatch(text);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildValidationRow(
                          'Pelo menos 8 caracteres.',
                          hasMinLength,
                        ),
                        _buildValidationRow('Letra minúscula.', hasLowercase),
                        _buildValidationRow('Letra maiúscula.', hasUppercase),
                        _buildValidationRow(
                          'Número ou caractere especial.',
                          hasNumberOrSpecial,
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 16),
              CustomInputField(
                label: 'Confirmar senha:',
                hintText: 'Confirme a senha',
                controller: _confirmPasswordEC,
                isPassword: true,
              ),
              const SizedBox(height: 32),

              ValueListenableBuilder<AppState<UserModel>>(
                valueListenable: _controller,
                builder: (context, state, child) {
                  final isLoading = state is LoadingState<UserModel>;

                  return CustomButton(
                    title: 'Finalizar cadastro',
                    isLoading: isLoading,
                    color: _selectedRole == 'empresa'
                        ? Colors.orange
                        : const Color(0xFF5A92AA),
                    onPressed: () {
                      final password = _passwordEC.text;

                      final isPasswordValid =
                          password.length >= 8 &&
                          RegExp(r'[a-z]').hasMatch(password) &&
                          RegExp(r'[A-Z]').hasMatch(password) &&
                          RegExp(r'[^a-zA-Z\s]').hasMatch(password);

                      if (!isPasswordValid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Por favor, cumpra todos os requisitos da senha.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (password != _confirmPasswordEC.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('As senhas não coincidem.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (_selectedRole == 'empresa' &&
                          _cnpjEC.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Por favor, informe o CNPJ da empresa.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      _controller.register(
                        name: _nameEC.text,
                        email: _emailEC.text,
                        password: password,
                        role: _selectedRole == 'empresa'
                            ? 'company'
                            : 'candidate',
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
