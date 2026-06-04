import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/candidato/controller/candidate_profile_controller.dart';
import 'package:techjobs/modules/candidato/model/candidate_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileController = Modular.get<CandidateProfileController>();

  @override
  void initState() {
    super.initState();

    // Envolvemos a chamada para garantir que a tela termine de ser desenhada primeiro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        _profileController.loadProfile(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ValueListenableBuilder<AppState<CandidateModel>>(
        valueListenable: _profileController,
        builder: (context, state, child) {
          if (state is LoadingState) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text((state as ErrorState).message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final userId =
                          Supabase.instance.client.auth.currentUser?.id;
                      if (userId != null) {
                        _profileController.loadProfile(userId);
                      }
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is SuccessState<CandidateModel>) {
            final candidate = state.data;
            return _buildProfileBody(candidate);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProfileBody(CandidateModel candidate) {
    final double appBarHeight = MediaQuery.of(context).size.height * 0.18;
    const double avatarRadius = 54.0;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: appBarHeight,
                    width: double.infinity,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 70),
                ],
              ),
              Positioned(
                right: 20,
                bottom: 0,
                child: OutlinedButton(
                  onPressed: () async {
                    await Modular.to.pushNamed(
                      './edit-profile',
                      arguments: candidate,
                    );
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
              Positioned(
                left: 30,
                bottom: 70 - avatarRadius,
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
                  // Substituímos o CircleAvatar pelo ClipOval + Image.network
                  child: ClipOval(
                    child: Container(
                      width: avatarRadius * 2,
                      height: avatarRadius * 2,
                      color: Colors.grey.shade100, // Fundo do fallback
                      child:
                          (candidate.avatarUrl != null &&
                              candidate.avatarUrl!.isNotEmpty)
                          ? Image.network(
                              candidate.avatarUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                // Se o progresso for nulo, a imagem terminou de baixar
                                if (loadingProgress == null) return child;

                                // Enquanto baixa, mostra a animação de Shimmer
                                return _ShimmerPlaceholder(
                                  size: avatarRadius * 2,
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                // Se a URL falhar ou estiver quebrada, exibe o fallback
                                return Icon(
                                  Icons.person,
                                  color: Colors.grey.shade400,
                                  size: 50,
                                );
                              },
                            )
                          // Se a URL for nula, já renderiza direto o fallback
                          : Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 50,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  candidate.name.isEmpty ? 'Novo Candidato' : candidate.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textTitle,
                  ),
                ),
                const SizedBox(height: 4),
                if (candidate.role != null || candidate.location != null)
                  Text(
                    '${candidate.role ?? ''} ${candidate.role != null && candidate.location != null ? '•' : ''} ${candidate.location ?? ''}',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                const SizedBox(height: 20),
                Divider(color: Colors.grey.shade200, thickness: 1),
                const SizedBox(height: 20),

                _buildSectionCard(
                  title: 'HABILIDADES',
                  child: candidate.skills.isEmpty
                      ? const Text('Nenhuma habilidade informada.')
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: candidate.skills
                              .map((skill) => _buildSkillTag(skill))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  title: 'SOBRE MIM',
                  child: Text(
                    candidate.bio ??
                        'Biografia não informada. Clique em editar para preencher.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  title: 'EXPERIÊNCIAS',
                  child: candidate.experiences.isEmpty
                      ? const Text('Nenhuma experiência informada.')
                      : Column(
                          children: candidate.experiences.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final exp = entry.value;
                            final isLast =
                                index == candidate.experiences.length - 1;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildExperienceItem(
                                  role: exp.role,
                                  company: exp.companyName,
                                  period:
                                      '${exp.startDate.year} – ${exp.isCurrent ? 'Atual' : exp.endDate?.year ?? ''}',
                                ),
                                if (!isLast)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Divider(
                                      color: Color(0xFFEEEEEE),
                                      height: 1,
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 40),

                _buildLogoutButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildSkillTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.chatAppBar,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

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
                  color: const Color(0xFF5A92AA),
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

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Supabase.instance.client.auth.signOut();
            Modular.to.navigate('/');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Sair da Conta',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 36, // mesmo espaço visual do ícone
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Componente que gera um efeito de Shimmer nativo e leve
class _ShimmerPlaceholder extends StatefulWidget {
  final double size;

  const _ShimmerPlaceholder({required this.size});

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 0.8).animate(_controller),
      child: Container(
        width: widget.size,
        height: widget.size,
        color: Colors.grey.shade300,
      ),
    );
  }
}
