import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/candidato/controller/company_details_controller.dart';
import 'package:techjobs/modules/candidato/model/company_model.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';

class CompanyDetailsPage extends StatefulWidget {
  final String companyId;

  const CompanyDetailsPage({
    super.key,
    required this.companyId,
  });

  @override
  State<CompanyDetailsPage> createState() => _CompanyDetailsPageState();
}

class _CompanyDetailsPageState extends State<CompanyDetailsPage> {
  final _controller = Modular.get<CompanyDetailsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadCompanyData(widget.companyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ValueListenableBuilder<AppState<CompanyModel>>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state is LoadingState || state is InitialState) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ErrorState<CompanyModel>) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: GoogleFonts.montserrat(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _controller.loadCompanyData(widget.companyId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Modular.to.pop(),
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
                      child: (company.avatarUrl != null && company.avatarUrl!.isNotEmpty)
                          ? Image.network(
                              company.avatarUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const _ShimmerPlaceholder(
                                  size: avatarRadius * 2,
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.business,
                                  color: Colors.grey,
                                  size: 50,
                                );
                              },
                            )
                          : const Icon(
                              Icons.business,
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
                const SizedBox(height: 20),
                Text(
                  company.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textTitle,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (company.location != null && company.location!.isNotEmpty)
                          ? company.location!
                          : 'Localização não informada',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.grey.shade200, thickness: 1),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: 'SOBRE A EMPRESA',
                  child: Text(
                    (company.description != null && company.description!.isNotEmpty)
                        ? company.description!
                        : 'Esta empresa ainda não adicionou uma descrição.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                      fontStyle: (company.description != null && company.description!.isNotEmpty)
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'VAGAS ANUNCIADAS',
                  child: ValueListenableBuilder<AppState<List<JobModel>>>(
                    valueListenable: _controller.jobsState,
                    builder: (context, state, child) {
                      if (state is LoadingState || state is InitialState) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
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
                            'Esta empresa não possui vagas no momento.',
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
                                _buildCandidateJobListItem(job),
                                if (job != jobs.last)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
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
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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

  Widget _buildCandidateJobListItem(JobModel job) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Modular.to.pushNamed('/candidate/job-details', arguments: job);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 4.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  size: 20,
                  color: AppColors.primary,
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
                        color: AppColors.textTitle,
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
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  final double size;

  const _ShimmerPlaceholder({
    required this.size,
  });

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