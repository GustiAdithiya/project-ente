class Review {
  final int id;
  final String userId;
  final String name;
  final String review;
  final int rating;
  final String createdAt;
  final String updatedAt;
  final String warungmakanId;

  Review({
    required this.id,
    required this.userId,
    required this.name,
    required this.review,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.warungmakanId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      review: json['review'],
      rating: int.parse(json['rating']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      warungmakanId: json['warungmakan_id'],
    );
  }
}
