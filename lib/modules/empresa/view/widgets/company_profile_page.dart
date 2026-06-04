import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/components/custom_app_bar.dart';
import 'package:techjobs/core/style/app_colors.dart';

class CompanyProfilePage extends StatelessWidget {
  const CompanyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: const CustomAppBar2(
        title: 'Perfil da Empresa',
        showProfileAvatar: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho centralizado (Logo, Nome, Setor)
              Center(child: _buildProfileHeader()),
              const SizedBox(height: 40),

              // Seção: Sobre a Empresa
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SOBRE A EMPRESA',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                      letterSpacing: 1.0,
                    ),
                  ),

                  // Apenas o ícone de editar
                  IconButton(
                    onPressed: () {
                      // Futura navegação para a tela de editar descrição
                      // Modular.to.pushNamed('/company/edit-about');
                    },
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(), // Remove o espaçamento extra padrão do botão
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildAboutCard(),

              const SizedBox(height: 32),

              // Seção: Vagas Anunciadas
              Text(
                'VAGAS ANUNCIADAS',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              _buildJobsCard(),

              const SizedBox(height: 40),

              // Botão de Sair da Conta (mantendo o visual anterior)
              _buildLogoutButton(),

              const SizedBox(height: 40), // Respiro final para o scroll
            ],
          ),
        ),
      ),
    );
  }

  // 1. Cabeçalho da Empresa
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.secondary.withOpacity(0.1),
                child: const Icon(
                  Icons.domain_rounded,
                  size: 40,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'TechNova Solutions',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textTitle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tecnologia da Informação',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 2. Card de Descrição (Sobre a Empresa)
  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nossa História',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Somos uma empresa focada em inovação digital, criando soluções escaláveis para o mercado financeiro e varejo. Buscamos profissionais apaixonados por tecnologia e que queiram crescer junto com o nosso time.',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Card Listando as Vagas Anunciadas
  Widget _buildJobsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildJobListItem(
            title: 'Desenvolvedor(a) Flutter Pleno',
            location: 'Remoto',
            isActive: true,
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildJobListItem(
            title: 'Tech Lead Mobile',
            location: 'São Paulo, SP',
            isActive: true,
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildJobListItem(
            title: 'Desenvolvedor(a) iOS Júnior',
            location: 'Remoto',
            isActive: false,
          ),
        ],
      ),
    );
  }

  // Item individual da vaga para ser usado dentro do Card de Vagas
  Widget _buildJobListItem({
    required String title,
    required String location,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.secondary.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.business_center_rounded,
              size: 20,
              color: isActive ? AppColors.secondary : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? AppColors.textTitle
                        : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isActive ? 'Ativa' : 'Pausada',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Botão de Sair da Conta
  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Lógica de logout
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Sair da Conta',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
