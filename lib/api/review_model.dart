class Review {
  final int id;
  final String name;
  final String username;
  final String body;
  final int likes;

  Review({
    required this.id,
    required this.name,
    required this.username,
    required this.body,
    required this.likes,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return Review(
      id: json['id'] as int,
      name: user['fullName'] as String,
      username: user['username'] as String,
      body: json['body'] as String,
      likes: json['likes'] as int,
    );
  }

  int get rating => ((id * 7) % 3) + 3;

  DateTime get reviewDate {
    final daysAgo = (id * 13) % 365;
    return DateTime.now().subtract(Duration(days: daysAgo));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'body': body,
      'likes': likes,
    };
  }
}
