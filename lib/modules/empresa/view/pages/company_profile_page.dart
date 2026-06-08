import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/empresa/controller/company_profile_controller.dart';
import 'package:techjobs/modules/empresa/controller/my_jobs_controller.dart';
import 'package:techjobs/modules/empresa/model/company_model.dart';
import 'package:techjobs/modules/empresa/model/job_model.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  final _profileController = Modular.get<CompanyProfileController>();
  final _jobsController =
      Modular.get<MyJobsController>(); // Injetamos o controlador de vagas

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        // Carrega o perfil e as vagas simultaneamente
        _profileController.loadProfile(userId);
        _jobsController.loadJobs(userId);
      }
    });
  }

  void _loadData() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _profileController.loadProfile(userId);
      _jobsController.loadJobs(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ValueListenableBuilder<AppState<CompanyModel>>(
        valueListenable: _profileController,
        builder: (context, state, child) {
          if (state is LoadingState || state is InitialState) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          if (state is ErrorState<CompanyModel>) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final userId =
                          Supabase.instance.client.auth.currentUser?.id;
                      if (userId != null) {
                        _profileController.loadProfile(userId);
                        _jobsController.loadJobs(userId);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is SuccessState<CompanyModel>) {
            return _buildProfileBody(state.data);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProfileBody(CompanyModel company) {
    final double appBarHeight = MediaQuery.of(context).size.height * 0.18;
    const double avatarRadius = 54.0;

    return RefreshIndicator(
      color: AppColors.secondary,
      onRefresh: () async => _loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: appBarHeight,
                      width: double.infinity,
                      color: AppColors.secondaryDark,
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
                Positioned(
                  right: 20,
                  bottom: 0,
                  child: OutlinedButton(
                    onPressed: () {
                      Modular.to.pushNamed('/company/edit-profile');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.secondary),
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
                        color: AppColors.secondary,
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
                    child: ClipOval(
                      child: Container(
                        width: avatarRadius * 2,
                        height: avatarRadius * 2,
                        color: Colors.grey.shade100,
                        child:
                            (company.avatarUrl != null &&
                                company.avatarUrl!.isNotEmpty)
                            ? Image.network(
                                company.avatarUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const _ShimmerPlaceholder(
                                        size: avatarRadius * 2,
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.domain_rounded,
                                    color: Colors.grey,
                                    size: 50,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.domain_rounded,
                                color: AppColors.secondary,
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
                  const SizedBox(height: 20),
                  Text(
                    company.name.isEmpty ? 'Nova Empresa' : company.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (company.cnpj != null && company.cnpj!.isNotEmpty)
                        ? 'CNPJ: ${company.cnpj}'
                        : 'CNPJ não informado',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  const SizedBox(height: 20),

                  // SEÇÃO: SOBRE A EMPRESA
                  _buildSectionCard(
                    title: 'SOBRE A EMPRESA',
                    child: Text(
                      (company.description != null &&
                              company.description!.isNotEmpty)
                          ? company.description!
                          : 'Descrição não informada. Clique em editar para contar a história da sua empresa.',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // SEÇÃO: VAGAS ANUNCIADAS (Reativo com o MyJobsController)
                  _buildSectionCard(
                    title: 'VAGAS ANUNCIADAS',
                    child: ValueListenableBuilder<AppState<List<JobModel>>>(
                      valueListenable: _jobsController,
                      builder: (context, state, child) {
                        if (state is LoadingState || state is InitialState) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: AppColors.secondary,
                              ),
                            ),
                          );
                        }

                        if (state is ErrorState) {
                          return Text(
                            'Falha ao carregar as vagas.',
                            style: GoogleFonts.montserrat(
                              color: Colors.redAccent,
                            ),
                          );
                        }

                        if (state is SuccessState<List<JobModel>>) {
                          final jobs = state.data;

                          if (jobs.isEmpty) {
                            return Text(
                              'Nenhuma vaga anunciada no momento.',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            );
                          }

                          return Column(
                            children: jobs.map((job) {
                              return Column(
                                children: [
                                  _buildJobListItem(job: job),
                                  // Adiciona o divisor se não for o último item da lista
                                  if (job != jobs.last)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Divider(
                                        color: Color(0xFFEEEEEE),
                                        height: 1,
                                      ),
                                    ),
                                ],
                              );
                            }).toList(),
                          );
                        }

                        return const SizedBox.shrink();
                      },
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

  Widget _buildJobListItem({required JobModel job}) {
    return InkWell(
      onTap: () {
        Modular.to.pushNamed('./manage-job', arguments: job);
      },
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: job.isActive
                  ? AppColors.secondary.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.business_center_rounded,
              size: 20,
              color: job.isActive ? AppColors.secondary : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: job.isActive
                        ? AppColors.textTitle
                        : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  job.location ?? job.workModel.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: job.isActive
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              job.isActive ? 'Ativa' : 'Pausada',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: job.isActive
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
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
                const SizedBox(width: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
