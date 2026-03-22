class ReviewLocalStore {
  static final List<Review> _reviews = [];
  static List<Review> get all => List.from(_reviews);
  static void add(Review r) => _reviews.add(r);
  static void update(Review updated) {
    final i = _reviews.indexWhere((r) => r.id == updated.id);
    if (i != -1) _reviews[i] = updated;
  }
  static void delete(int id) => _reviews.removeWhere((r) => r.id == id);
}

class Review {
  final int id;
  final String name;
  final String username;
  final String body;
  final int likes;
  final String? ownerId;
  final int? manualRating;
  final DateTime? manualDate;

  Review({
    required this.id,
    required this.name,
    required this.username,
    required this.body,
    required this.likes,
    this.ownerId,
    this.manualRating,
    this.manualDate,
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

  int get rating => manualRating ?? ((id * 7) % 3) + 3;
  DateTime get reviewDate => manualDate ?? DateTime.now().subtract(Duration(days: (id * 13) % 365));

  Review copyWith({String? body, int? manualRating}) => Review(
    id: id,
    name: name,
    username: username,
    body: body ?? this.body,
    likes: likes,
    ownerId: ownerId,
    manualRating: manualRating ?? this.manualRating,
    manualDate: manualDate,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'body': body,
    'likes': likes,
  };
}