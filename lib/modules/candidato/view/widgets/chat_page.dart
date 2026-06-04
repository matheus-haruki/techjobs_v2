import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/controller/chat_controller.dart';

// O modelo permanece para ajudar a construir a interface
class ChatMessage {
  final String text;
  final bool isFromCompany;

  ChatMessage({required this.text, required this.isFromCompany});
}

class ChatPage extends StatefulWidget {
  final JobModel job;

  const ChatPage({super.key, required this.job});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController _controller;
  String? _candidateId;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<ChatController>();
    _candidateId = Supabase.instance.client.auth.currentUser?.id;

    // Assim que a página abre, pergunta ao banco: "Já temos data?"
    if (_candidateId != null) {
      _controller.loadChatStatus(_candidateId!, widget.job.id);
    }
  }

  // Gera a lista de mensagens dinamicamente com base no estado do agendamento
  List<ChatMessage> _buildChatHistory(DateTime? scheduledDate) {
    final messages = [
      ChatMessage(
        text: 'Olá! Gostamos muito do seu perfil para a vaga de ${widget.job.title}. Vamos agendar um bate-papo inicial?',
        isFromCompany: true,
      ),
    ];

    // Se houver uma data agendada na base de dados, adicionamos as mensagens de confirmação
    if (scheduledDate != null) {
      final formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(scheduledDate);
      
      messages.add(
        ChatMessage(
          text: 'Podemos conversar no dia $formattedDate. Fico no aguardo do link!',
          isFromCompany: false,
        ),
      );
      
      messages.add(
        ChatMessage(
          text: 'Perfeito! O convite foi enviado para o seu e-mail e adicionado às suas Notificações. Até lá!',
          isFromCompany: true,
        ),
      );
    }

    return messages;
  }

  Future<void> _scheduleInterview() async {
    if (_candidateId == null) return;

    DateTime tempPickedDate = DateTime.now().add(const Duration(days: 1));

    final DateTime? finalDate = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 320,
          padding: const EdgeInsets.only(top: 6.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text('Cancelar', style: GoogleFonts.montserrat(color: Colors.redAccent)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: Text('Concluir', style: GoogleFonts.montserrat(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      onPressed: () => Navigator.of(context).pop(tempPickedDate),
                    ),
                  ],
                ),
                const Divider(height: 1, color: Colors.black12),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: tempPickedDate,
                    minimumDate: DateTime.now(),
                    maximumDate: DateTime.now().add(const Duration(days: 30)),
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime newDateTime) {
                      tempPickedDate = newDateTime;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Se o candidato concluiu e escolheu uma data, enviamos para o Supabase!
    if (finalDate != null && mounted) {
      _controller.scheduleInterview(_candidateId!, widget.job.id, finalDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.business, color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.job.company,
                    style: GoogleFonts.montserrat(color: AppColors.textTitle, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Recrutador(a)',
                    style: GoogleFonts.montserrat(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // O corpo inteiro é reativo ao Controller
      body: ValueListenableBuilder<AppState<DateTime?>>(
        valueListenable: _controller,
        builder: (context, state, child) {
          // ESTADO 1: Carregando os dados da base de dados
          if (state is InitialState || state is LoadingState) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          // ESTADO 2: Erro de conexão
          if (state is ErrorState) {
            return Center(
              child: Text(
                'Falha ao carregar a conversa.',
                style: GoogleFonts.montserrat(color: Colors.red),
              ),
            );
          }

          // ESTADO 3: Sucesso! Temos ou não uma data marcada?
          if (state is SuccessState<DateTime?>) {
            final scheduledDate = state.data;
            final messages = _buildChatHistory(scheduledDate);
            final isSchedulingCompleted = scheduledDate != null;

            return Column(
              children: [
                // Histórico de mensagens construído dinamicamente
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildChatBubble(messages[index]);
                    },
                  ),
                ),

                // Barra Inferior (Botão de Calendário ou Confirmação Verde)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: !isSchedulingCompleted
                        ? ElevatedButton.icon(
                            onPressed: _scheduleInterview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.calendar_month, color: Colors.white),
                            label: Text(
                              'Escolher Data e Hora',
                              style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'Entrevista Agendada',
                                  style: GoogleFonts.montserrat(color: Colors.green.shade700, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isFromCompany ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isFromCompany ? Colors.white : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isFromCompany ? 0 : 16),
            bottomRight: Radius.circular(message.isFromCompany ? 16 : 0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: GoogleFonts.montserrat(
            color: message.isFromCompany ? AppColors.textTitle : Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}