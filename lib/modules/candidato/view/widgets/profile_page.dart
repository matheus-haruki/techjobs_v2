import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/style/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Dados simulados do perfil (Mock)
  String _name = 'João Silva';
  String _role = 'Dev Full Stack';
  String _location = 'São Paulo, SP';
  int _candidaturas = 12;
  int _emAndamento = 3;
  int _anosExp = 5;
  String _bio =
      'Dev Full Stack com 5 anos de exp. Apaixonado por código limpo e boas práticas.';

  final List<String> _skills = [
    'React',
    'Node.js',
    'TypeScript',
    'PostgreSQL',
    'Docker',
    'AWS',
  ];

  @override
  Widget build(BuildContext context) {
    // Pegamos a largura total da tela para fazer o banner responsivo
    final double appBarHeight = MediaQuery.of(context).size.height * 0.18;
    // O raio do avatar redondo
    const double avatarRadius = 54.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),

        child: Column(
          children: [
            // 1. Cabeçalho corrigido para permitir o clique
            Stack(
              children: [
                // Esta Coluna dita o tamanho total do Stack (Banner + Área Branca de escape)
                Column(
                  children: [
                    Container(
                      height: appBarHeight,
                      width: double.infinity,
                      color: AppColors.primary,
                    ),
                    // O espaçamento de 70 que ficava fora, agora fica dentro!
                    const SizedBox(height: 70),
                  ],
                ),

                // Botão de Editar
                Positioned(
                  right: 20,
                  bottom: 0, // Agora o bottom é positivo (Fica dentro do Stack)
                  child: OutlinedButton(
                    onPressed: () async {
                      // 1. Prepara o mapa com os dados atuais
                      final currentData = {
                        'name': _name,
                        'role': _role,
                        'location': _location,
                        'bio': _bio,
                      };

                      // 2. Navega para a tela de edição e aguarda o retorno
                      final updatedData = await Modular.to
                          .pushNamed<Map<String, dynamic>>(
                            './edit-profile', // ou o caminho da sua rota
                            arguments: currentData,
                          );

                      // 3. Se o usuário salvou e retornou dados novos, atualiza a tela
                      if (updatedData != null && mounted) {
                        setState(() {
                          _name = updatedData['name'];
                          _role = updatedData['role'];
                          _location = updatedData['location'];
                          _bio = updatedData['bio'];
                        });
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'Editar',
                      style: GoogleFonts.montserrat(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                // O CircleAvatar com o botão de câmera integrado
                Positioned(
                  left: 30,
                  bottom:
                      70 -
                      avatarRadius, // Ajuste matemático para ficar na linha exata
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: const Color(0xFFF0A342),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Espaçamento para compensar a flutuação do avatar
            // const SizedBox(height: 0),

            // 2. Informações Principais do Usuário
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_role • $_location',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Linha dos Contadores (Métricas)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricItem('$_candidaturas', 'Candidaturas'),
                      _buildMetricItem('$_emAndamento', 'Andamento'),
                      _buildMetricItem('$_anosExp', 'Anos exp.'),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  const SizedBox(height: 20),

                  // 3. Seção de Habilidades (Tags com Wrap)
                  _buildSectionCard(
                    title: 'HABILIDADES',
                    // Passamos uma borda azul sutil simulando o destaque do seu mockup
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills
                          .map((skill) => _buildSkillTag(skill))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Seção Sobre Mim
                  _buildSectionCard(
                    title: 'SOBRE MIM',
                    child: Text(
                      _bio,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Seção de Experiências profissionais
                  _buildSectionCard(
                    title: 'EXPERIÊNCIAS',
                    child: Column(
                      children: [
                        _buildExperienceItem(
                          role: 'Dev Senior',
                          company: 'Empresa XYZ',
                          period: 'Jan 2022 – Atual',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Color(0xFFEEEEEE), height: 1),
                        ),
                        _buildExperienceItem(
                          role: 'Dev Pleno',
                          company: 'Startup ABC',
                          period: 'Mar 2020 – Dez 2021',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. Seção de Contato
                  _buildSectionCard(
                    title: 'CONTATO',
                    child: Column(
                      children: [
                        _buildContactItem(
                          Icons.mail_outline_rounded,
                          'joao@email.com',
                        ),
                        const SizedBox(height: 12),
                        _buildContactItem(
                          Icons.code_rounded,
                          'github.com/joao',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40), // Respiro no final do scroll
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Componente auxiliar para os itens de métricas superiores
  Widget _buildMetricItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // Molde de Card padrão para todas as seções, mantendo o visual arredondado do mockup
  Widget _buildSectionCard({
    required String title,
    required Widget child,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? Colors.grey.shade200,
          width: borderColor != null ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // As tags cinzas e limpas do seu modelo
  Widget _buildSkillTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5), // Cinza bem clarinho idêntico ao modelo
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(
            0xFF5A6A85,
          ), // Tom de azul acinzentado para o texto da tag
        ),
      ),
    );
  }

  // Componente para a listagem das experiências de trabalho
  Widget _buildExperienceItem({
    required String role,
    required String company,
    required String period,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                company,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(
                    0xFF5A92AA,
                  ), // Cor de destaque para a empresa
                ),
              ),
              const SizedBox(height: 4),
              Text(
                period,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Linhas com ícones para a seção de contato final
  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
