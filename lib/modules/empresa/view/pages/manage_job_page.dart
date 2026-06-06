import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/components/custom_app_bar.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/empresa/model/job_model.dart';
import 'package:techjobs/modules/empresa/model/match_model.dart';
import 'package:techjobs/modules/empresa/controller/manage_job_controller.dart';

class ManageJobPage extends StatefulWidget {
  final JobModel job;

  const ManageJobPage({super.key, required this.job});

  @override
  State<ManageJobPage> createState() => _ManageJobPageState();
}

class _ManageJobPageState extends State<ManageJobPage> {
  final _controller = Modular.get<ManageJobController>();

  @override
  void initState() {
    super.initState();
    // Assim que a tela desenhar, pedimos ao Controller para buscar os inscritos desta vaga
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadApplicants(widget.job.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: const CustomAppBar2(
        title: 'Gerenciar Vaga',
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
        child: ValueListenableBuilder<AppState<List<MatchModel>>>(
          valueListenable: _controller.applicantsState,
          builder: (context, state, child) {
            // Variáveis de controle para a UI reagir ao estado
            int applicantsCount = 0;
            List<MatchModel> applicants = [];
            bool isLoading = state is LoadingState || state is InitialState;

            if (state is SuccessState<List<MatchModel>>) {
              applicants = state.data;
              applicantsCount = applicants.length;
            }

            return Column(
              children: [
                // O Header agora recebe a contagem real de inscritos
                _buildJobHeader(applicantsCount),

                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                          ),
                        )
                      : state is ErrorState<List<MatchModel>>
                      ? Center(
                          child: Text(
                            state.message,
                            style: GoogleFonts.montserrat(
                              color: Colors.redAccent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : applicants.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: applicants.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildApplicantCard(applicants[index]);
                          },
                        ),
                ),

                // Botão de Excluir Vaga (Mantido no final)
                _buildDeleteJobButton(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildJobHeader(int applicantsCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.job.title,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textTitle,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                widget.job.location ?? 'Remoto',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$applicantsCount Inscritos',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(MatchModel applicant) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        // Aguarda o retorno da tela de perfil (true se a empresa deu Match)
        final matched = await Modular.to.pushNamed<bool>(
          './candidate-details',
          arguments: {
            'candidateId': applicant.candidateId,
            'jobId': widget.job.id,
            // Se já for match, oculta o botão para não dar match duas vezes
            'isReadOnly': applicant.isMatch,
          },
        );

        // Se o Match aconteceu, recarrega a lista para o selinho verde aparecer na hora!
        if (matched == true && mounted) {
          _controller.loadApplicants(widget.job.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
              backgroundImage: applicant.candidateAvatarUrl != null
                  ? NetworkImage(applicant.candidateAvatarUrl!)
                  : null,
              child: applicant.candidateAvatarUrl == null
                  ? Text(
                      _initials(applicant.candidateName),
                      style: GoogleFonts.montserrat(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          applicant.candidateName,
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textTitle,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Badge de Match só aparece se a flag isMatch for true
                      if (applicant.isMatch) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite_rounded,
                                size: 10,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Match',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    applicant.candidateRole,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteJobButton(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmDeleteJob(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: BorderSide(color: Colors.redAccent.shade100),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            label: Text(
              'Excluir vaga',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Nenhum candidato ainda',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteJob(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Excluir Vaga?',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: AppColors.textTitle,
            ),
          ),
          content: Text(
            'Tem certeza que deseja excluir a vaga "${widget.job.title}"? Esta ação não poderá ser desfeita.',
            style: GoogleFonts.montserrat(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.montserrat(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o dialog
                Modular.to.pop(
                  true,
                ); // Retorna true para dar trigger no SnackBar de exclusão
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Sim, Excluir',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '??';
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first.toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
