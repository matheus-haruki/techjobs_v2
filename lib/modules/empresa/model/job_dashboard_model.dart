class JobDashboardModel {
  final String id;
  final String title;
  final String location;
  final int candidatesCount;
  final String status;
  final String postedDate;

  JobDashboardModel({
    required this.id,
    required this.title,
    required this.location,
    required this.candidatesCount,
    required this.status,
    required this.postedDate,
  });
}