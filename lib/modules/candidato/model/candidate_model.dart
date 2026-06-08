import 'package:techjobs/modules/candidato/model/experience_model.dart';

class CandidateModel {
  final String id;
  final String name;
  final String? bio;
  final String? avatarUrl;
  final String? role;
  final String? location;
  final List<String> skills;
  final List<ExperienceModel> experiences;

  const CandidateModel({
    required this.id,
    required this.name,
    this.bio,
    this.avatarUrl,
    this.role,
    this.location,
    this.skills = const [],
    this.experiences = const [],
  });

  factory CandidateModel.fromMap(Map<String, dynamic> map) {
    return CandidateModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      bio: map['bio'],
      avatarUrl: map['avatar_url'],
      role: map['role'],
      location: map['location'],
      skills: List<String>.from(map['skills'] ?? []),
      experiences: map['candidate_experiences'] != null
          ? (map['candidate_experiences'] as List)
              .map((e) => ExperienceModel.fromMap(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'avatar_url': avatarUrl,
      'role': role,
      'location': location,
      'skills': skills,
      // Não enviamos as experiências no toMap raiz porque 
      // inserções em tabelas relacionais são tratadas separadamente no Repositório.
    };
  }
}