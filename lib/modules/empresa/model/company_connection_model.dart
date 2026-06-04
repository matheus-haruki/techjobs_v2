class CompanyConnectionModel {
  final String candidateId;
  final String candidateName;
  final String role;
  final String matchedJobTitle;
  final String matchDate;
  final bool hasUnreadMessages;

  const CompanyConnectionModel({
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.matchedJobTitle,
    required this.matchDate,
    this.hasUnreadMessages = false,
  });
}