import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Importação para o DatePicker do iOS
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';

// Modelo simples de mensagem para controlarmos o chat
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
  final List<ChatMessage> _messages = [];
  bool _isScheduling = false; // Controla se o botão de calendário aparece

  @override
  void initState() {
    super.initState();
    // Simula a mensagem automática chegando assim que abre o chat
    _messages.add(
      ChatMessage(
        text:
            'Olá! Gostamos muito do seu perfil para a vaga de ${widget.job.title}. Vamos agendar um bate-papo inicial?',
        isFromCompany: true,
      ),
    );
    _isScheduling = true; // Libera o botão de agendar
  }

  // Função que abre o calendário no padrão iOS (Cupertino)
  Future<void> _scheduleInterview() async {
    DateTime tempPickedDate = DateTime.now().add(
      const Duration(days: 1),
    ); // Sugere amanhã

    // Abre o menu inferior no estilo iOS
    final DateTime? finalDate = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 320, // Altura do menu
          padding: const EdgeInsets.only(top: 6.0),
          // Fundo branco com as bordas arredondadas no topo
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Barra superior com botão de Concluir e Cancelar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.montserrat(color: Colors.redAccent),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pop(), // Fecha sem salvar
                    ),
                    CupertinoButton(
                      child: Text(
                        'Concluir',
                        style: GoogleFonts.montserrat(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(tempPickedDate), // Fecha enviando a data
                    ),
                  ],
                ),
                const Divider(height: 1, color: Colors.black12),

                // A "Roleta" do iOS que escolhe Data e Hora de uma vez só!
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode
                        .dateAndTime, // Data e Hora juntas
                    initialDateTime: tempPickedDate,
                    minimumDate: DateTime.now(),
                    maximumDate: DateTime.now().add(const Duration(days: 30)),
                    use24hFormat: true, // Formato brasileiro 24h
                    onDateTimeChanged: (DateTime newDateTime) {
                      tempPickedDate =
                          newDateTime; // Atualiza a variável enquanto a roleta gira
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Se o usuário clicou em "Concluir" e escolheu uma data
    if (finalDate != null && mounted) {
      final formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(finalDate);

      setState(() {
        _messages.add(
          ChatMessage(
            text:
                'Podemos conversar no dia $formattedDate. Fico no aguardo do link!',
            isFromCompany: false,
          ),
        );
        _isScheduling = false; // Esconde o botão após enviar a mensagem
      });

      // Simula uma resposta automática do recrutador 1 segundo depois
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add(
            ChatMessage(
              text:
                  'Perfeito! O convite foi enviado para o seu e-mail e adicionado às suas Notificações. Até lá!',
              isFromCompany: true,
            ),
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: AppColors.white,
        // 1. Aumente a elevação para espalhar mais a sombra (ex: 8 ou 10)
        elevation: 4,
        // 2. Aumente a opacidade para deixar a sombra mais escura (ex: 0.2 ou 0.3)
        shadowColor: Colors.black.withValues(alpha:0.2),
        // 3. Garante que o Material 3 não ofusque a sua sombra
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Row(
          children: [
            Container(
              height: 42,
              width: 42,

              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.business,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.job.company,
                    style: GoogleFonts.montserrat(
                      color: AppColors.textTitle,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Recrutador(a)',
                    style: GoogleFonts.montserrat(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Área das mensagens
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),

          // Barra de Ação Contextual (Substitui o falso campo de texto)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5), // Sombra invertida para cima
                ),
              ],
            ),
            child: SafeArea(
              child: _isScheduling
                  // Estado 1: Botão de Ação (Aguardando agendamento)
                  ? ElevatedButton.icon(
                      onPressed: _scheduleInterview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Mais quadrado para combinar com a barra
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Escolher Data e Hora',
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  // Estado 2: Status de Sucesso (Após agendar)
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
                            style: GoogleFonts.montserrat(
                              color: Colors.green.shade700,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Componente que constrói os "balões" do chat isolado
  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isFromCompany
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
              0.75, // Limita o balão a 75% da tela
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
