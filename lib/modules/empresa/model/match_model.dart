class MatchModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String candidateId;
  final String candidateName;
  final String? candidateAvatarUrl;
  final String candidateRole;
  final bool isMatch;
  final DateTime createdAt;

  const MatchModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.candidateId,
    required this.candidateName,
    this.candidateAvatarUrl,
    required this.candidateRole,
    required this.isMatch,
    required this.createdAt,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    final jobData = map['jobs'] ?? {};
    final candidateData = map['candidates'] ?? {};

    return MatchModel(
      id: map['id'] ?? '',
      jobId: map['job_id'] ?? '',
      jobTitle: jobData['title'] ?? 'Vaga',
      candidateId: map['candidate_id'] ?? '',
      candidateName: candidateData['name'] ?? 'Talento Oculto',
      candidateAvatarUrl: candidateData['avatar_url'],
      candidateRole: candidateData['role'] ?? 'Profissional',
      // O Match perfeito acontece quando o status evolui para 'match'
      isMatch: map['status'] == 'match', 
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }
}