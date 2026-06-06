import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/empresa/controller/company_profile_controller.dart';
import 'package:techjobs/modules/empresa/model/company_model.dart';

class EditCompanyProfilePage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const EditCompanyProfilePage({
    super.key,
    this.initialData,
  });

  @override
  State<EditCompanyProfilePage> createState() => _EditCompanyProfilePageState();
}

class _EditCompanyProfilePageState extends State<EditCompanyProfilePage> {
  final _controller = Modular.get<CompanyProfileController>();

  final _nameController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _locationController = TextEditingController();
  final _aboutController = TextEditingController();

  bool _hasCnpjRegistered = false;
  String? _currentAvatarUrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleStateChange);

    // Prioriza os dados recebidos pelo onboarding (via Map)
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _cnpjController.text = widget.initialData!['cnpj'] ?? '';
      
      if (_cnpjController.text.isNotEmpty) {
        _hasCnpjRegistered = true;
      }
    } else {
      // Fallback para o fluxo normal: tenta buscar do controller caso o usuário
      // esteja abrindo a tela de edição através do próprio perfil já logado.
      final currentState = _controller.value;
      if (currentState is SuccessState<CompanyModel>) {
        final company = currentState.data;

        _nameController.text = company.name;
        _cnpjController.text = company.cnpj ?? '';
        _locationController.text = company.location ?? '';
        _aboutController.text = company.description ?? '';
        _currentAvatarUrl = company.avatarUrl;

        if (_cnpjController.text.isNotEmpty) {
          _hasCnpjRegistered = true;
        }
      }
    }
  }

  // --- NOVO: Menu para escolher entre Câmera e Galeria ---
  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  title: Text(
                    'Tirar Foto',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () {
                    Modular.to.pop(); // Fecha o menu
                    _pickImage(ImageSource.camera); // Abre a câmera
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  title: Text(
                    'Escolher da Galeria',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () {
                    Modular.to.pop();
                    _pickImage(ImageSource.gallery); // Abre a galeria
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- ATUALIZADO: Agora recebe a fonte (Câmera ou Galeria) dinamicamente ---
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _handleStateChange() {
    final state = _controller.value;
    if (state is SuccessState<CompanyModel>) {
      // 1. Remove o listener para evitar múltiplos disparos indesejados caso a tela demore a fechar
      _controller.removeListener(_handleStateChange);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // 2. Navegação Defensiva
      if (Modular.to.canPop()) {
        // Fluxo normal: O usuário veio do menu de Perfil, então podemos apenas "desempilhar" a tela.
        Modular.to.pop();
      } else {
        // Fluxo de onboarding: O histórico está vazio. Forçamos a navegação para a base do módulo da Empresa.
        Modular.to.navigate('/company/'); 
      }
    } else if (state is ErrorState<CompanyModel>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message), 
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStateChange);
    _nameController.dispose();
    _cnpjController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondary),
        title: Text(
          'Editar Perfil',
          style: GoogleFonts.montserrat(
            color: AppColors.textTitle,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                      border: Border.all(color: AppColors.secondary, width: 2),
                    ),
                    child: ClipOval(child: _buildAvatarImage()),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      // --- ATUALIZADO: Agora chama o Menu em vez de abrir a galeria direto ---
                      onTap: _showPickerOptions,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            _buildSectionTitle('Dados Principais'),
            const SizedBox(height: 16),
            _buildInputField(
              'Nome da Empresa',
              _nameController,
              icon: Icons.business,
            ),
            const SizedBox(height: 16),

            _buildInputField(
              'CNPJ',
              _cnpjController,
              icon: Icons.badge_outlined,
              readOnly: _hasCnpjRegistered,
              hintText: _hasCnpjRegistered ? null : 'Apenas números',
            ),
            if (_hasCnpjRegistered)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  'O CNPJ não pode ser alterado após o registro.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),

            const SizedBox(height: 16),
            _buildInputField(
              'Localização (Ex: São Paulo, SP)',
              _locationController,
              icon: Icons.location_on_outlined,
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Apresentação'),
            const SizedBox(height: 16),
            _buildInputField(
              'Sobre a Empresa',
              _aboutController,
              maxLines: 5,
              hintText:
                  'Conte um pouco sobre a história e cultura da empresa...',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ValueListenableBuilder<AppState<CompanyModel>>(
            valueListenable: _controller,
            builder: (context, state, child) {
              final isLoading = state is LoadingState<CompanyModel>;
              return ElevatedButton(
                onPressed: isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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

  Widget _buildAvatarImage() {
    if (_selectedImage != null) {
      return Image.file(_selectedImage!, fit: BoxFit.cover);
    } else if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
      return Image.network(
        _currentAvatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) =>
            const Icon(Icons.domain_rounded, color: Colors.grey, size: 50),
      );
    } else {
      return const Icon(
        Icons.domain_rounded,
        color: AppColors.secondary,
        size: 50,
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    IconData? icon,
    String? hintText,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          style: TextStyle(
            color: readOnly ? Colors.grey.shade600 : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: icon != null && maxLines == 1
                ? Icon(icon, color: Colors.grey.shade400, size: 20)
                : null,
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.secondary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveProfile() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final company = CompanyModel(
      id: userId,
      name: _nameController.text.trim(),
      cnpj: _cnpjController.text.trim(),
      location: _locationController.text.trim(),
      description: _aboutController.text.trim(),
      avatarUrl: _currentAvatarUrl,
    );

    _controller.saveProfile(company, newAvatarImage: _selectedImage);
  }
}
