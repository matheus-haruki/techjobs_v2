class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final List<String> tags;
  final String description; // <-- Propriedade nova adicionada

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.tags,
    required this.description, // <-- Requisito adicionado no construtor
  });
}