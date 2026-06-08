enum WorkModel {
  presencial,
  remoto,
  hibrido,
}

class JobModel {
  final String id;
  final String? companyId;
  final String title;
  final String? companyName; // Modificado para receber do JOIN
  final String? companyAvatarUrl; // Adicionado para manter simetria com a View
  final WorkModel workModel;
  final String? location;    
  final String salary;
  final List<String> tags;
  final String description;
  final bool isSubscribed;
  final bool isMatch;
  final DateTime? scheduledAt;

  // Transformado em construtor constante (Performance)
  const JobModel({
    required this.id,
    this.companyId,
    required this.title,
    this.companyName,
    this.companyAvatarUrl,
    required this.workModel,
    this.location,
    required this.salary,
    required this.tags,
    required this.description,
    this.isSubscribed = false,
    this.isMatch = false,
    this.scheduledAt,
  });

  factory JobModel.fromMap(Map<String, dynamic> map) {
    // Fail-safe para o JOIN relacional
    final companyData = map['companies'] as Map<String, dynamic>?;

    return JobModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      companyId: map['company_id'] as String?,
      companyName: companyData?['name'] as String?,
      companyAvatarUrl: companyData?['avatar_url'] as String?,
      workModel: WorkModel.values.firstWhere(
        (e) => e.name == map['work_model'],
        orElse: () => WorkModel.presencial,
      ),
      location: map['location'],
      salary: map['salary_range'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      description: map['description'] ?? '',
      isSubscribed: map['is_subscribed'] ?? false,
      isMatch: map['is_match'] ?? false, 
      scheduledAt: map['scheduled_at'] != null ? DateTime.parse(map['scheduled_at']) : null, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      // 'company_name' removido estritamente para não quebrar inserts caso o model seja reaproveitado.
      'work_model': workModel.name,
      'location': location,
      'salary_range': salary,
      'tags': tags,
      'description': description,
    };
  }
}