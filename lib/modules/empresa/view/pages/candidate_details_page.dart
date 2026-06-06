import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/components/custom_app_bar.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/candidato/model/candidate_model.dart';
import 'package:techjobs/modules/empresa/controller/candidate_details_controller.dart';

class CandidateDetailsPage extends StatefulWidget {
  final String candidateId;
  final String jobId;
  final bool isReadOnly;

  const CandidateDetailsPage({
    super.key,
    required this.candidateId,
    required this.jobId,
    this.isReadOnly = false,
  });

  @override
  State<CandidateDetailsPage> createState() => _CandidateDetailsPageState();
}

class _CandidateDetailsPageState extends State<CandidateDetailsPage> {
  final _controller = Modular.get<CandidateDetailsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadCandidate(widget.candidateId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: const CustomAppBar2(
        title: 'Perfil do Candidato',
        showProfileAvatar: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ValueListenableBuilder<AppState<CandidateModel>>(
          valueListenable: _controller.detailsState,
          builder: (context, state, child) {
            if (state is LoadingState || state is InitialState) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              );
            }

            if (state is ErrorState<CandidateModel>) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    state.message,
                    style: GoogleFonts.montserrat(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is SuccessState<CandidateModel>) {
              return _buildProfileContent(state.data);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: widget.isReadOnly ? null : _buildBottomAction(),
    );
  }

  Widget _buildProfileContent(CandidateModel candidate) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABEÇALHO (Foto, Nome, Cargo e Local)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                backgroundImage: candidate.avatarUrl != null
                    ? NetworkImage(candidate.avatarUrl!)
                    : null,
                child: candidate.avatarUrl == null
                    ? Text(
                        _getInitials(candidate.name),
                        style: GoogleFonts.montserrat(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textTitle,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Cargo e localização na mesma linha estilo: "dev ios • Mauá, SP"
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (candidate.role != null &&
                            candidate.role!.isNotEmpty)
                          Text(
                            candidate.role!,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (candidate.role != null &&
                            candidate.location != null)
                          Text(
                            ' • ',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        if (candidate.location != null &&
                            candidate.location!.isNotEmpty)
                          Text(
                            candidate.location!,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // SESSÃO: HABILIDADES
          if (candidate.skills.isNotEmpty)
            _buildSectionCard(
              title: 'HABILIDADES',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: candidate.skills
                    .map((skill) => _buildTag(skill))
                    .toList(),
              ),
            ),

          // SESSÃO: SOBRE MIM
          if (candidate.bio != null && candidate.bio!.isNotEmpty)
            _buildSectionCard(
              title: 'SOBRE MIM',
              child: Text(
                candidate.bio!,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

          // SESSÃO: EXPERIÊNCIAS
          if (candidate.experiences.isNotEmpty)
            _buildSectionCard(
              title: 'EXPERIÊNCIAS',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: candidate.experiences.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exp = entry.value;

                  // Lógica de Datas
                  final startYear = exp.startDate.year;
                  String endString = '';

                  if (exp.isCurrent) {
                    endString = 'Atual';
                  } else if (exp.endDate != null) {
                    endString = exp.endDate!.year.toString();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Adiciona um divisor discreto entre as experiências (igual ao print)
                      if (index > 0) ...[
                        const SizedBox(height: 16),
                        Divider(color: Colors.grey.shade100, height: 1),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        exp.role,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textTitle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exp.companyName.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color:
                              AppColors.primary, // Cor azulzinha igual ao print
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$startYear – $endString',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // MÉTODO AUXILIAR PARA CRIAR O "CARD" COM TÍTULO
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
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

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: ValueListenableBuilder<AppState<void>>(
          valueListenable: _controller.likeActionState,
          builder: (context, state, child) {
            final isLoading = state is LoadingState;

            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final success = await _controller.likeCandidate(
                        candidateId: widget.candidateId,
                        jobId: widget.jobId,
                      );

                      if (success && context.mounted) {
                        Modular.to.pop(true);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryDark,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Dar Match',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  String _getInitials(String name) {
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
