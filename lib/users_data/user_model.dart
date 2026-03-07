class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String userType; // 'client' or 'worker'
  final String? gender;
  final String? birthdate;
  final String? city;
  final String? barangay;
  final String? address;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.userType,
    this.gender,
    this.birthdate,
    this.city,
    this.barangay,
    this.address,
  });

  // Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? userType,
    String? gender,
    String? birthdate,
    String? city,
    String? barangay,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
      city: city ?? this.city,
      barangay: barangay ?? this.barangay,
      address: address ?? this.address,
    );
  }

  // Check if profile is complete
  bool get isProfileComplete {
    return gender != null && gender!.isNotEmpty &&
           birthdate != null && birthdate!.isNotEmpty &&
           city != null && city!.isNotEmpty &&
           barangay != null && barangay!.isNotEmpty &&
           address != null && address!.isNotEmpty;
  }
}