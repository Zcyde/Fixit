import 'user_model.dart';

class UsersDatabase {
  static final List<User> _users = [
    User(
      id: 'client_1',
      name: 'Test Client',
      email: '1',
      phone: '000-0000',
      password: '1',
      userType: 'client',
    ),
    User(
      id: 'worker_1',
      name: 'Test Worker',
      email: '2',
      phone: '000-0000',
      password: '2',
      userType: 'worker',
    ),
  ];

  static List<User> getAllUsers() {
    return _users;
  }

  static bool signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String userType,
  }) {
    final existingUser = _users.where((user) => 
      user.email == email && user.userType == userType
    ).firstOrNull;

    if (existingUser != null) {
      return false;
    }

    final newUser = User(
      id: '${userType}_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      password: password,
      userType: userType,
    );

    _users.add(newUser);
    return true;
  }
  
  static User? signIn({
    required String email,
    required String password,
    required String userType,
  }) {
    try {
      return _users.firstWhere((user) =>
        user.email == email &&
        user.password == password &&
        user.userType == userType
      );
    } catch (e) {
      return null;
    }
  }

  static bool emailExists({
    required String email,
    required String userType,
  }) {
    return _users.any((user) => 
      user.email == email && user.userType == userType
    );
  }

  static bool updateUser(User updatedUser) {
    try {
      final index = _users.indexWhere((user) => user.id == updatedUser.id);
      if (index != -1) {
        _users[index] = updatedUser;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }
}
