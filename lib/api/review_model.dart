class Review {
  final int id;
  final String name;
  final String email;
  final String body;

  Review({
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'body': body,
    };
  }
}
