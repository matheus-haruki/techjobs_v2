import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- IMPORTANTE: Para suportar os formatadores e máscaras
import 'package:google_fonts/google_fonts.dart'; 
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/core/style/app_fonts.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters; // <-- NOVO: Permite injetar máscaras

  const CustomInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.focusNode,
    this.inputFormatters, // <-- NOVO
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  void didUpdateWidget(CustomInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se o Flutter reciclar o widget e mudar a propriedade isPassword, nós atualizamos o estado local
    if (widget.isPassword != oldWidget.isPassword) {
      _obscureText = widget.isPassword;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Aplicando a fonte Montserrat na Label do campo
        Text(widget.label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters, // <-- NOVO: Aplica a máscara no widget nativo
          // 2. Garantindo que o texto digitado pelo usuário também fique na fonte certa
          style: GoogleFonts.montserrat(color: AppColors.textTitle),
          decoration: InputDecoration(
            hintText: widget.hintText,
            // 3. Estilizando o placeholder (Hint)
            hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.secondary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.secondary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}