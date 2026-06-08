// ignore_for_file: constant_identifier_names
enum InteractionStatus { 
  unseen, 
  like, 
  dislike, 
  match, 
  company_like, 
  company_dislike 
}

class InteractionModel {
  final String id;
  final String candidateId;
  final String jobId;
  final InteractionStatus status;
  final DateTime createdAt;
  final DateTime? scheduledAt; 

  InteractionModel({
    required this.id,
    required this.candidateId,
    required this.jobId,
    required this.status,
    required this.createdAt,
    this.scheduledAt,
  });

  factory InteractionModel.fromMap(Map<String, dynamic> map) {
    return InteractionModel(
      id: map['id'] ?? '',
      candidateId: map['candidate_id'] ?? '',
      jobId: map['job_id'] ?? '',
      status: InteractionStatus.values.firstWhere(
        // O .name no Dart converte perfeitamente o enum para String (ex: "company_like")
        (e) => e.name == map['status'],
        orElse: () => InteractionStatus.unseen,
      ),
      // Adicionado um fallback seguro com DateTime.now() caso venha nulo na criação em memória
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      scheduledAt: map['scheduled_at'] != null ? DateTime.parse(map['scheduled_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'candidate_id': candidateId,
      'job_id': jobId,
      'status': status.name,
      // Não enviamos o created_at no toMap geralmente, o banco gera sozinho
      if (scheduledAt != null) 'scheduled_at': scheduledAt!.toIso8601String(),
    };
  }
}