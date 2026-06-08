class CompanyModel {
  final String id;
  final String name;
  final String? cnpj;
  final String? location;
  final String? description;
  final String? avatarUrl;

  const CompanyModel({
    required this.id,
    required this.name,
    this.cnpj,
    this.location,
    this.description,
    this.avatarUrl,
  });

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      id: map['id'] as String,
      name: map['name'] as String,
      cnpj: map['cnpj'] as String?,
      location: map['location'] as String?,
      description: map['description'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cnpj': cnpj,
      'location': location, 
      'description': description,
      'avatar_url': avatarUrl,
    };
  }

  CompanyModel copyWith({
    String? id,
    String? name,
    String? cnpj,
    String? location,
    String? description,
    String? avatarUrl,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cnpj: cnpj ?? this.cnpj,
      location: location ?? this.location,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}