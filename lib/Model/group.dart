class Group {
  int id;
  String userEmail;
  int groupId;
  String groupName;
  String status;
  String role;
  DateTime createdAt;
  DateTime updatedAt;

  Group({
    required this.id,
    required this.userEmail,
    required this.groupId,
    required this.groupName,
    required this.status,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      userEmail: json['user_email'],
      groupId: json['group_id'],
      groupName: json['group_name'],
      status: json['status'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}