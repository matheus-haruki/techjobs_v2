import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/core/components/custom_app_bar.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/controller/connections_controller.dart';
import 'package:intl/intl.dart';

// Importe o controller da BasePage para escutar a mudança de abas
import 'package:techjobs/modules/candidato/controller/candidate_controller.dart'; 

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  late final ConnectionsController _controller;
  late final CandidateController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<ConnectionsController>();
    _tabController = Modular.get<CandidateController>();

    // Registra o ouvinte para a troca de abas
    _tabController.addListener(_onTabChanged);
    
    // Carregamento inicial (com loading visual)
    _loadMatches();
  }

  @override
  void dispose() {
    // Prevenção de memory leak: remove o ouvinte ao destruir o widget
    _tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    // O índice 2 corresponde à aba de "Conexões" na sua BaseCandidatePage
    if (_tabController.value == 2) {
      _loadMatches(isSilent: true); // Recarrega os dados sem piscar a tela
    }
  }

  void _loadMatches({bool isSilent = false}) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _controller.loadConnections(userId, isSilent: isSilent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: const CustomAppBar(title: 'Minhas Conexões'),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ValueListenableBuilder<AppState<List<JobModel>>>(
          valueListenable: _controller,
          builder: (context, state, child) {
            if (state is InitialState<List<JobModel>> ||
                state is LoadingState<List<JobModel>>) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is ErrorState<List<JobModel>>) {
              return _buildErrorState(state.message);
            }

            if (state is SuccessState<List<JobModel>>) {
              final jobs = state.data;

              if (jobs.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                // Refresh manual via "pull to refresh" não é silencioso
                onRefresh: () async => _loadMatches(isSilent: false),
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: jobs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _MatchCard(job: jobs[index], onRefreshNeeded: () => _loadMatches(isSilent: true));
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.handshake_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Ainda não há conexões',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Continue arrastando cards no Feed para encontrar a sua vaga ideal.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Falha ao carregar conexões',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textTitle,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadMatches(isSilent: false),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onRefreshNeeded;

  const _MatchCard({required this.job, required this.onRefreshNeeded});

  @override
  Widget build(BuildContext context) {
    final bool isScheduled = job.scheduledAt != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.business,
                  color: AppColors.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BadgeStatus(
                      isScheduled: isScheduled,
                      scheduledDate: job.scheduledAt,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      job.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textTitle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.companyName ?? 'Empresa Confidencial',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Modular.to.pushNamed(
                      '/candidate/job-details',
                      arguments: job,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.description_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    'Ver Vaga',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Modular.to.pushNamed('/candidate/chat', arguments: job).then((_) {
                      // Ao voltar do chat, delega a atualização para a página principal
                      onRefreshNeeded();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    isScheduled ? 'Ver Agenda' : 'Mensagem',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeStatus extends StatelessWidget {
  final bool isScheduled;
  final DateTime? scheduledDate;

  const _BadgeStatus({required this.isScheduled, this.scheduledDate});

  @override
  Widget build(BuildContext context) {
    final bgColor = isScheduled ? Colors.blue.shade50 : Colors.green.shade50;
    final textColor = isScheduled
        ? Colors.blue.shade700
        : Colors.green.shade700;

    String label = 'Novo Match! 🎉';
    if (isScheduled && scheduledDate != null) {
      final formattedDate = DateFormat(
        "dd/MM/yyyy 'às' HH:mm",
      ).format(scheduledDate!);
      label = 'Agendada: $formattedDate';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}