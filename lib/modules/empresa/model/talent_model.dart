class TalentExperienceModel {
  final String id;
  final String companyName;
  final String role;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;

  const TalentExperienceModel({
    required this.id,
    required this.companyName,
    required this.role,
    required this.startDate,
    this.endDate,
    required this.isCurrent,
  });

  factory TalentExperienceModel.fromMap(Map<String, dynamic> map) {
    return TalentExperienceModel(
      id: map['id'] ?? '',
      companyName: map['company_name'] ?? '',
      role: map['role'] ?? '',
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      isCurrent: map['is_current'] ?? false,
    );
  }
}

class TalentModel {
  final String id;
  final String name;
  final String? bio;
  final String? avatarUrl;
  final String? role;
  final String? location;
  final List<String> skills;
  final List<TalentExperienceModel> experiences;

  const TalentModel({
    required this.id,
    required this.name,
    this.bio,
    this.avatarUrl,
    this.role,
    this.location,
    this.skills = const [],
    this.experiences = const [],
  });

  factory TalentModel.fromMap(Map<String, dynamic> map) {
    return TalentModel(
      id: map['id'] ?? '',
      // Se o name/avatar estiverem vindo de um JOIN com a tabela profiles, 
      // o Supabase aninha os dados. Vamos cobrir as duas possibilidades!
      name: map['name'] ?? map['profiles']?['name'] ?? 'Talento Oculto',
      bio: map['bio'],
      avatarUrl: map['avatar_url'] ?? map['profiles']?['avatar_url'],
      role: map['role'],
      location: map['location'],
      skills: List<String>.from(map['skills'] ?? []),
      experiences: map['candidate_experiences'] != null
          ? (map['candidate_experiences'] as List)
              .map((e) => TalentExperienceModel.fromMap(e))
              .toList()
          : [],
    );
  }
}