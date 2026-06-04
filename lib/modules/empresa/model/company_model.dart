class CompanyModel {
  final String id;
  final String name;
  final String? cnpj;
  final String? description;
  final String? avatarUrl;

  const CompanyModel({
    required this.id,
    required this.name,
    this.cnpj,
    this.description,
    this.avatarUrl,
  });

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      cnpj: map['cnpj'],
      description: map['description'],
      avatarUrl: map['avatar_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cnpj': cnpj,
      'description': description,
      'avatar_url': avatarUrl,
    };
  }
}