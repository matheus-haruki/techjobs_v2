import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/core/components/custom_app_bar.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/empresa/controller/my_jobs_controller.dart';
import 'package:techjobs/modules/empresa/model/job_model.dart';

class MyJobsPage extends StatefulWidget {
  const MyJobsPage({super.key});

  @override
  State<MyJobsPage> createState() => _MyJobsPageState();
}

class _MyJobsPageState extends State<MyJobsPage> {
  final _controller = Modular.get<MyJobsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final companyId = Supabase.instance.client.auth.currentUser?.id;
    if (companyId != null) {
      _controller.loadJobs(companyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: CustomAppBar2(
        title: 'Minhas Vagas',
        showProfileAvatar: false,
        actions: [
          IconButton(
            onPressed: () async {
              final currentContext = context;
              final jobCreated = await Modular.to.pushNamed<bool>(
                './create-job',
              );
              if (!mounted) return;

              if (jobCreated == true) {
                ScaffoldMessenger.of(currentContext).showSnackBar(
                  const SnackBar(
                    content: Text('Vaga publicada com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadData(); // Recarrega a lista real do banco
              }
            },
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ValueListenableBuilder<AppState<List<JobModel>>>(
          valueListenable: _controller,
          builder: (context, state, child) {
            if (state is LoadingState) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              );
            }

            if (state is ErrorState<List<JobModel>>) {
              return Center(
                child: Text(
                  state.message,
                  style: GoogleFonts.montserrat(color: Colors.redAccent),
                ),
              );
            }

            if (state is SuccessState<List<JobModel>>) {
              final jobs = state.data;

              if (jobs.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: AppColors.secondary,
                onRefresh: () async => _loadData(),
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    top: 24,
                    left: 20,
                    right: 20,
                    bottom: 100,
                  ),
                  itemCount: jobs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildJobDashboardCard(jobs[index]);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildJobDashboardCard(JobModel job) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: job.isActive
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.isActive ? 'Ativa' : 'Pausada',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: job.isActive
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ),
              Text(
                'Criada recentemente', // Será ajustado via extension de DateTime no futuro
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            job.title,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textTitle,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                job.location ?? 'Remoto',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.people_outline_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.applicantCount.toString(),
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Candidatos',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () async {
                  final currentContext = context;
                  final deleted = await Modular.to.pushNamed<bool>(
                    './manage-job',
                    arguments: job,
                  );

                  if (!mounted) return;
                  if (deleted == true) {
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      const SnackBar(
                        content: Text('Vaga excluída com sucesso!'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    _loadData(); // Atualiza a lista caso a vaga seja apagada
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  'Gerenciar',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textTitle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma vaga publicada',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie sua primeira vaga para começar a receber currículos e encontrar talentos.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
