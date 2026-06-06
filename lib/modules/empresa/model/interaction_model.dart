enum InteractionStatus { like, dislike, company_like, company_dislike, match, unseen }

extension InteractionStatusExtension on InteractionStatus {
  String get toValue => toString().split('.').last;
  
  static InteractionStatus fromValue(String value) {
    return InteractionStatus.values.firstWhere(
      (e) => e.toValue == value,
      orElse: () => InteractionStatus.unseen,
    );
  }
}

class InteractionModel {
  final String? id;
  final String candidateId;
  final String jobId;
  final InteractionStatus status;

  InteractionModel({
    this.id,
    required this.candidateId,
    required this.jobId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'candidate_id': candidateId,
      'job_id': jobId,
      'status': status.toValue,
    };
  }

  factory InteractionModel.fromMap(Map<String, dynamic> map) {
    return InteractionModel(
      id: map['id'],
      candidateId: map['candidate_id'] ?? '',
      jobId: map['job_id'] ?? '',
      status: InteractionStatusExtension.fromValue(map['status'] ?? ''),
    );
  }
}