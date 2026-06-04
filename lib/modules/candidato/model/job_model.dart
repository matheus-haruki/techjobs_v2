enum WorkModel {
  presencial,
  remoto,
  hibrido,
}

class JobModel {
  final String id;
  final String title;
  final String company;
  final WorkModel workModel; // <-- Novo campo para o Modelo
  final String? location;    // <-- Transformado em String? (pode ser nulo se for remoto)
  final String salary;
  final List<String> tags;
  final String description;
  final bool isSubscribed;
  final DateTime? scheduledAt;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.workModel,
    this.location,
    required this.salary,
    required this.tags,
    required this.description,
    this.isSubscribed = false,
    this.scheduledAt,
  });

  // Converte o JSON do Supabase em Objeto Dart
  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      company: map['company_name'] ?? '',
      workModel: WorkModel.values.firstWhere(
        (e) => e.name == map['work_model'],
        orElse: () => WorkModel.presencial,
      ),
      location: map['location'],
      salary: map['salary_range'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      description: map['description'] ?? '',
      isSubscribed: map['is_subscribed'] ?? false,
      scheduledAt: map['scheduled_at'] != null ? DateTime.parse(map['scheduled_at']) : null, 
    );
  }

  // Converte o Objeto Dart em JSON para o Supabase
  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'company_name': company,
      'work_model': workModel.name,
      'location': location,
      'salary_range': salary,
      'tags': tags,
      'description': description,
    };
  }
}