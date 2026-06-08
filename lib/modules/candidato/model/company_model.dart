class CompanyModel {
  final String id;
  final String name;
  final String? location;
  final String? description;
  final String? avatarUrl;

  const CompanyModel({
    required this.id,
    required this.name,
    this.location,
    this.description,
    this.avatarUrl,
  });

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      id: map['id'] as String,
      name: map['name'] as String,
      location: map['location'] as String?,
      description: map['description'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}