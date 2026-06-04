import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/candidato/model/experience_model.dart';

class AddExperienceSheet extends StatefulWidget {
  final String candidateId;

  const AddExperienceSheet({
    super.key,
    required this.candidateId,
  });

  @override
  State<AddExperienceSheet> createState() => _AddExperienceSheetState();
}

class _AddExperienceSheetState extends State<AddExperienceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _roleController = TextEditingController();
  final _companyController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;

  @override
  void dispose() {
    _roleController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A data de início é obrigatória.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
        return;
      }
      
      if (!_isCurrent && _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe a data de término ou marque como trabalho atual.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
        return;
      }

      final newExperience = ExperienceModel(
        id: '', // Será gerado pelo Supabase
        candidateId: widget.candidateId,
        companyName: _companyController.text.trim(),
        role: _roleController.text.trim(),
        startDate: _startDate!,
        endDate: _isCurrent ? null : _endDate,
        isCurrent: _isCurrent,
      );

      // Devolve o modelo preenchido para a tela que chamou o BottomSheet
      Navigator.pop(context, newExperience);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Padding dinâmico para evitar que o teclado cubra o formulário
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar Experiência',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Cargo', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Empresa', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isStart: true),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_startDate == null ? 'Início' : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isCurrent ? null : () => _pickDate(isStart: false),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_endDate == null ? 'Término' : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Trabalho atual'),
                value: _isCurrent,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _isCurrent = value;
                    if (value) _endDate = null;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Adicionar', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}