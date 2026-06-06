enum WorkModel {
  presencial,
  remoto,
  hibrido,
}

class JobModel {
  final String id;
  final String companyId; 
  final String title;
  final String description;
  final WorkModel workModel;
  final String? location;
  final String salary;
  final List<String> tags;
  final bool isActive; 
  final DateTime? createdAt; 
  final int applicantCount; // <-- NOVO: Armazena o número de candidatos

  const JobModel({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.workModel,
    this.location,
    required this.salary,
    required this.tags,
    this.isActive = true,
    this.createdAt,
    this.applicantCount = 0, // <-- Valor inicial padrão
  });

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] as String,
      companyId: map['company_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      workModel: WorkModel.values.firstWhere(
        (e) => e.name == map['work_model'],
        orElse: () => WorkModel.presencial,
      ),
      location: map['location'] as String?,
      salary: map['salary_range'] as String,
      tags: List<String>.from(map['tags'] ?? []),
      isActive: map['is_active'] ?? true,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      applicantCount: map['applicant_count'] ?? 0, // <-- Recebe do Repositório
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'company_id': companyId,
      'title': title,
      'description': description,
      'work_model': workModel.name,
      'location': location,
      'salary_range': salary,
      'tags': tags,
      'is_active': isActive,
      // applicantCount não vai pro toMap porque não inserimos isso direto no banco
    };
  }

  JobModel copyWith({
    String? id,
    String? companyId,
    String? title,
    String? description,
    WorkModel? workModel,
    String? location,
    String? salary,
    List<String>? tags,
    bool? isActive,
    DateTime? createdAt,
    int? applicantCount,
  }) {
    return JobModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      title: title ?? this.title,
      description: description ?? this.description,
      workModel: workModel ?? this.workModel,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      applicantCount: applicantCount ?? this.applicantCount,
    );
  }
}