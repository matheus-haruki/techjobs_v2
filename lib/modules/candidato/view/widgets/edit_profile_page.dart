import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/candidato/controller/candidate_profile_controller.dart';
import 'package:techjobs/modules/candidato/model/candidate_model.dart';
import 'package:techjobs/modules/candidato/model/experience_model.dart';
import 'package:techjobs/modules/candidato/view/widgets/add_experience_sheet.dart';

class EditProfilePage extends StatefulWidget {
  // Alteração Arquitetural: Recebemos o Modelo tipado no lugar do Map genérico
  final CandidateModel candidate;

  const EditProfilePage({super.key, required this.candidate});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _profileController = Modular.get<CandidateProfileController>();

  late final TextEditingController _nameController;
  late final TextEditingController _roleController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;
  final TextEditingController _skillController = TextEditingController();
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Estado local para gerenciar a reatividade das tags de habilidades
  late List<String> _skills;

  late List<ExperienceModel> _experiences;

  @override
  void initState() {
    super.initState();
    // Inicialização segura e tipada utilizando os dados do Model
    _nameController = TextEditingController(text: widget.candidate.name);
    _roleController = TextEditingController(text: widget.candidate.role ?? '');
    _locationController = TextEditingController(
      text: widget.candidate.location ?? '',
    );
    _bioController = TextEditingController(text: widget.candidate.bio ?? '');

    // Clonamos a lista para não mutar a instância original acidentalmente
    _skills = List<String>.from(widget.candidate.skills);
    _experiences = List<ExperienceModel>.from(widget.candidate.experiences);

    _profileController.addListener(_handleStateChange);
  }

  void _handleStateChange() {
    final state = _profileController.value;

    if (state is SuccessState<CandidateModel>) {
      // Remove o listener para evitar duplo disparo e leak de memória
      _profileController.removeListener(_handleStateChange);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // LÓGICA DE ROTEAMENTO ADAPTATIVA
      // Se canPop() for true, há histórico. Significa que viemos da tela de Perfil (modo edição).
      if (Modular.to.canPop()) {
        Modular.to.pop(state.data);
      }
      // Se canPop() for false, NÃO há histórico. Significa que viemos do Registro (modo onboarding).
      else {
        // Direciona o utilizador diretamente para o painel principal do candidato
        Modular.to.navigate('/candidate/');
      }
    } else if (state is ErrorState<CandidateModel>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    }
  }

  void _addSkill() {
    final newSkill = _skillController.text.trim();
    if (newSkill.isNotEmpty && !_skills.contains(newSkill)) {
      setState(() {
        _skills.add(newSkill);
        _skillController.clear();
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality:
            70, // Mantemos a compressão para evitar OOM e economizar banda
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao capturar imagem.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 32,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Foto de Perfil',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Tirar foto',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Modular.to.pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Escolher da galeria',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Modular.to.pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  @override
  void dispose() {
    _profileController.removeListener(_handleStateChange);
    _nameController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(
          'Editar Perfil',
          style: GoogleFonts.montserrat(
            color: AppColors.textTitle,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEÇÃO: AVATAR ---
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: AppColors.white,
                        backgroundImage: _selectedImage != null
                            ? FileImage(File(_selectedImage!.path))
                            : widget.candidate.avatarUrl != null
                            ? NetworkImage(widget.candidate.avatarUrl!)
                            : null,
                        child:
                            _selectedImage == null &&
                                widget.candidate.avatarUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 54,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    ),
                    InkWell(
                      onTap: _showImageSourceSheet,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- SEÇÃO: DADOS BÁSICOS ---
              _buildSectionTitle('DADOS PESSOAIS'),
              const SizedBox(height: 16),
              ProfileInputField(
                label: 'Nome completo',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              ProfileInputField(
                label: 'Cargo / Especialidade',
                controller: _roleController,
              ),
              const SizedBox(height: 16),
              ProfileInputField(
                label: 'Localização',
                controller: _locationController,
              ),
              const SizedBox(height: 32),

              // --- SEÇÃO: BIOGRAFIA ---
              _buildSectionTitle('SOBRE MIM'),
              const SizedBox(height: 16),
              ProfileInputField(
                label: 'Biografia profissional',
                controller: _bioController,
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // --- SEÇÃO: HABILIDADES (SKILLS) ---
              _buildSectionTitle('HABILIDADES'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ProfileInputField(
                      label: 'Adicionar nova',
                      controller: _skillController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 24.0,
                    ), // Alinha o botão com o field
                    child: IconButton(
                      onPressed: _addSkill,
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills.map((skill) {
                  return Chip(
                    label: Text(
                      skill,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5A6A85),
                      ),
                    ),
                    backgroundColor: const Color(0xFFF1F3F5),
                    deleteIcon: const Icon(Icons.cancel, size: 18),
                    onDeleted: () => _removeSkill(skill),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.transparent),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // --- SEÇÃO: EXPERIÊNCIAS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('EXPERIÊNCIAS'),
                  TextButton.icon(
                    onPressed:
                        _showAddExperienceSheet, // Liga o botão ao método recém-criado
                    icon: const Icon(
                      Icons.add,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    label: Text(
                      'Adicionar',
                      style: GoogleFonts.montserrat(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _experiences
                      .isEmpty // Aponta para o estado local _experiences em vez de widget.candidate
                  ? Text(
                      'Nenhuma experiência cadastrada.',
                      style: GoogleFonts.montserrat(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          _experiences.length, // Usa o tamanho da lista local
                      separatorBuilder: (_, __) =>
                          Divider(color: Colors.grey.shade200),
                      itemBuilder: (context, index) {
                        final exp = _experiences[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            exp.role,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${exp.companyName}\n'
                            '${exp.startDate.year} - ${exp.isCurrent ? 'Atual' : exp.endDate?.year ?? ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _experiences.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ValueListenableBuilder<AppState<CandidateModel>>(
            valueListenable: _profileController,
            builder: (context, state, child) {
              final isLoading = state is LoadingState<CandidateModel>;

              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        final userId =
                            Supabase.instance.client.auth.currentUser?.id;

                        if (userId != null) {
                          _profileController.saveProfile(
                            id: userId,
                            name: _nameController.text,
                            bio: _bioController.text,
                            role: _roleController.text,
                            location: _locationController.text,
                            skills: _skills,
                            experiences: _experiences,
                            // 1. Mantém a URL antiga caso o usuário não altere a foto
                            currentAvatarUrl: widget.candidate.avatarUrl,
                            // 2. Converte o XFile do ImagePicker para o File do dart:io, se houver seleção
                            newAvatarFile: _selectedImage != null
                                ? File(_selectedImage!.path)
                                : null,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                        'Salvar Alterações',
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
      ),
    );
  }

  // Componente extraído (DRY) para os títulos de seção
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
        letterSpacing: 0.5,
      ),
    );
  }

  // Adicione este método dentro de _EditProfilePageState
  Future<void> _showAddExperienceSheet() async {
    // Chamamos o BottomSheet esperando receber um ExperienceModel como retorno
    final newExperience = await showModalBottomSheet<ExperienceModel>(
      context: context,
      isScrollControlled:
          true, // Permite que o sheet ocupe mais espaço ao abrir o teclado
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddExperienceSheet(candidateId: widget.candidate.id),
    );

    // Se o usuário preencheu e adicionou, atualizamos o estado local
    if (newExperience != null) {
      setState(() {
        _experiences.add(newExperience);
      });
    }
  }
}

// Widget extraído mantido (DRY)
class ProfileInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            color: AppColors.textTitle,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
