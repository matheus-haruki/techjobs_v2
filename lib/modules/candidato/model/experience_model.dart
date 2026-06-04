class ExperienceModel {
  final String id;
  final String candidateId;
  final String companyName;
  final String role;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;

  const ExperienceModel({
    required this.id,
    required this.candidateId,
    required this.companyName,
    required this.role,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
  });

  // Converte o JSON vindo do Supabase em Objeto Dart
  factory ExperienceModel.fromMap(Map<String, dynamic> map) {
    return ExperienceModel(
      id: map['id'] ?? '',
      candidateId: map['candidate_id'] ?? '',
      companyName: map['company_name'] ?? '',
      role: map['role'] ?? '',
      startDate: map['start_date'] != null 
          ? DateTime.parse(map['start_date']) 
          : DateTime.now(),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      isCurrent: map['is_current'] ?? false,
    );
  }

  // Converte o Objeto Dart em JSON para salvar no Supabase
  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'candidate_id': candidateId,
      'company_name': companyName,
      'role': role,
      'start_date': startDate.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T')[0],
      'is_current': isCurrent,
    };
  }
}