class Request {
  final String id;
  final String title;
  final String type;
  final String budget;
  final String description;
  final String priority;
  final List<String> imagePaths; // Store image paths
  final DateTime createdAt;
  
  // User information
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String? userGender;
  final String? userBirthdate;
  final String? userCity;
  final String? userBarangay;
  final String? userAddress;
  
  // Request status
  String status; // 'pending', 'in_progress', 'completed', 'cancelled'

  Request({
    required this.id,
    required this.title,
    required this.type,
    required this.budget,
    required this.description,
    required this.priority,
    required this.imagePaths,
    required this.createdAt,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    this.userGender,
    this.userBirthdate,
    this.userCity,
    this.userBarangay,
    this.userAddress,
    this.status = 'pending',
  });

  Request copyWith({
    String? id,
    String? title,
    String? type,
    String? budget,
    String? description,
    String? priority,
    List<String>? imagePaths,
    DateTime? createdAt,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userGender,
    String? userBirthdate,
    String? userCity,
    String? userBarangay,
    String? userAddress,
    String? status,
  }) {
    return Request(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      budget: budget ?? this.budget,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      userGender: userGender ?? this.userGender,
      userBirthdate: userBirthdate ?? this.userBirthdate,
      userCity: userCity ?? this.userCity,
      userBarangay: userBarangay ?? this.userBarangay,
      userAddress: userAddress ?? this.userAddress,
      status: status ?? this.status,
    );
  }

  // Get priority color
  String get priorityColor {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 'red';
      case 'high':
        return 'orange';
      case 'medium':
        return 'yellow';
      case 'low':
        return 'green';
      default:
        return 'grey';
    }
  }

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}