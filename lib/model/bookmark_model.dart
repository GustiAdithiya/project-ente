class Bookmark {
  final int id;
  final String warungmakanId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bookmark({
    required this.id,
    required this.warungmakanId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      warungmakanId: json['warungmakan_id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
