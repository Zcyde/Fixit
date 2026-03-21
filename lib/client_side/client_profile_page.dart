import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../users_data/users_database.dart';
import '../users_data/user_model.dart';
import 'client_home_page.dart';
import 'client_requests_page.dart';
import 'inbox_page.dart';
import '../sign_in_page.dart';

class _ProfilePictureStore {
  static final Map<String, XFile?> _pictures = {};
  static XFile? get(String userId) => _pictures[userId];
  static void set(String userId, XFile photo) => _pictures[userId] = photo;
}

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _selectedTab = 'profile';
  bool _isEditing = false;
  late bool _wasProfileIncompleteOnLoad;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  late TextEditingController _genderController;
  late TextEditingController _birthdateController;
  late TextEditingController _cityController;
  late TextEditingController _barangayController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _wasProfileIncompleteOnLoad = !widget.user.isProfileComplete;
    _nameController = TextEditingController(text: widget.user.name);
    _contactController = TextEditingController(text: widget.user.phone);
    _emailController = TextEditingController(text: widget.user.email);
    _genderController = TextEditingController(text: widget.user.gender ?? '');
    _birthdateController = TextEditingController(text: widget.user.birthdate ?? '');
    _cityController = TextEditingController(text: widget.user.city ?? '');
    _barangayController = TextEditingController(text: widget.user.barangay ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    if (_wasProfileIncompleteOnLoad) _isEditing = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _birthdateController.dispose();
    _cityController.dispose();
    _barangayController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) setState(() => _ProfilePictureStore.set(widget.user.id, image));
  }

  ImageProvider? _getProfileImage() {
    final pic = _ProfilePictureStore.get(widget.user.id);
    if (pic == null) return null;
    if (kIsWeb) return NetworkImage(pic.path);
    return FileImage(File(pic.path));
  }

  void _handleEditProfile() {
    if (_isEditing) {
      if (_genderController.text.trim().isEmpty ||
          _birthdateController.text.trim().isEmpty ||
          _cityController.text.trim().isEmpty ||
          _barangayController.text.trim().isEmpty ||
          _addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill in all fields to complete your profile'),
          backgroundColor: Colors.red
        ));
        return;
      }

      final updatedUser = widget.user.copyWith(
        name: _nameController.text.trim(),
        phone: _contactController.text.trim(),
        email: _emailController.text.trim(),
        gender: _genderController.text.trim(),
        birthdate: _birthdateController.text.trim(),
        city: _cityController.text.trim(),
        barangay: _barangayController.text.trim(),
        address: _addressController.text.trim()
      );

      final success = UsersDatabase.updateUser(updatedUser);

      if (success) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1)
        ));
        if (_wasProfileIncompleteOnLoad) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red
        ));
      }
    } else {
      final currentUser = UsersDatabase.getUserById(widget.user.id);
      if (currentUser != null && currentUser.isProfileComplete) {
        _showPasswordVerificationDialog();
      } else {
        setState(() => _isEditing = true);
      }
    }
  }

  void _showPasswordVerificationDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Verify Password', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter your password to edit your profile:',
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2D7A5E), width: 1.5)
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
                )
              )
            ]
          ),
          actions: [
            TextButton(
              onPressed: () { passwordController.dispose(); Navigator.pop(context); },
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: const Text('Cancel')
            ),
            ElevatedButton(
              onPressed: () {
                final enteredPassword = passwordController.text.trim();
                if (enteredPassword == widget.user.password) {
                  passwordController.dispose();
                  Navigator.pop(context);
                  setState(() => _isEditing = true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Incorrect password'),
                    backgroundColor: Colors.red
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6DBD8E),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: const Text('Verify', style: TextStyle(fontWeight: FontWeight.w700))
            )
          ]
        );
      }
    );
  }

  void _cancelEdit() {
    if (_wasProfileIncompleteOnLoad) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please complete your profile before continuing'),
        backgroundColor: Colors.red
      ));
      return;
    }
    setState(() {
      _isEditing = false;
      _nameController.text = widget.user.name;
      _contactController.text = widget.user.phone;
      _emailController.text = widget.user.email;
      _genderController.text = widget.user.gender ?? '';
      _birthdateController.text = widget.user.birthdate ?? '';
      _cityController.text = widget.user.city ?? '';
      _barangayController.text = widget.user.barangay ?? '';
      _addressController.text = widget.user.address ?? '';
    });
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isRequired = false}) {
    final isEmpty = controller.text.trim().isEmpty;
    final showRedTint = isRequired && _wasProfileIncompleteOnLoad && _isEditing && isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: _isEditing,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: showRedTint ? '*' : null,
            hintStyle: const TextStyle(color: Colors.red, fontSize: 14),
            filled: true,
            fillColor: showRedTint
              ? Colors.red.withValues(alpha: 0.08)
              : _isEditing ? Colors.grey[200] : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2D7A5E), width: 1.5)
            ),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
          )
        )
      ]
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _genderController.text.isEmpty ? null : _genderController.text,
          items: ['Male', 'Female'].map((gender) => DropdownMenuItem(value: gender, child: Text(gender))).toList(),
          onChanged: _isEditing ? (value) => setState(() => _genderController.text = value ?? '') : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: _isEditing ? Colors.grey[200] : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2D7A5E), width: 1.5)
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
          )
        )
      ]
    );
  }

  Widget _buildBirthdatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Birthdate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: _birthdateController,
          readOnly: true,
          enabled: _isEditing,
          onTap: _isEditing
            ? () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(_birthdateController.text) ?? DateTime(2000, 1, 1),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now()
                );
                if (pickedDate != null) {
                  setState(() {
                    _birthdateController.text =
                      '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                  });
                }
              }
            : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: _isEditing ? Colors.grey[200] : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2D7A5E), width: 1.5)
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: const Icon(Icons.calendar_today)
          )
        )
      ]
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600]))
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const SignInPage()), (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            child: const Text('Logout')
          )
        ]
      )
    );
  }

  Widget _buildAvatar() {
    final profileImage = _getProfileImage();
    return GestureDetector(
      onTap: _pickProfilePicture,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: profileImage,
            child: profileImage == null
              ? Icon(Icons.person, size: 50, color: Colors.grey[600])
              : null
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Color(0xFF2D7A5E), shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16)
            )
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5F1),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(children: [
          const Text('Fixit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(width: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!)
            ),
            child: const Text('Profile', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500))
          )
        ]),
        actions: [
          TextButton(
            onPressed: _showLogoutDialog,
            child: const Text('Log out', style: TextStyle(color: Colors.black, fontSize: 14))
          )
        ]
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildAvatar(),
              const SizedBox(height: 16),
              Text(widget.user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 'profile'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 'profile' ? const Color(0xFF2D7A5E) : Colors.white,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: _selectedTab == 'profile' ? const Color(0xFF2D7A5E) : Colors.grey[300]!)
                        ),
                        child: Center(
                          child: Text('Profile',
                            style: TextStyle(
                              color: _selectedTab == 'profile' ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 14))
                        )
                      )
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 'history'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 'history' ? const Color(0xFF2D7A5E) : Colors.white,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: _selectedTab == 'history' ? const Color(0xFF2D7A5E) : Colors.grey[300]!)
                        ),
                        child: Center(
                          child: Text('History',
                            style: TextStyle(
                              color: _selectedTab == 'history' ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 14))
                        )
                      )
                    )
                  )
                ]
              ),
              const SizedBox(height: 24),
              if (_selectedTab == 'profile') ...[
                _buildTextField('Name', _nameController),
                const SizedBox(height: 16),
                _buildTextField('Contact Number', _contactController),
                const SizedBox(height: 16),
                _buildTextField('Email', _emailController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildGenderDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildBirthdatePicker())
                  ]
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField('City', _cityController, isRequired: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('Barangay', _barangayController, isRequired: true))
                  ]
                ),
                const SizedBox(height: 16),
                _buildTextField('Address', _addressController, isRequired: true),
                const SizedBox(height: 28),
                if (_isEditing) ...[
                  if (_wasProfileIncompleteOnLoad) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleEditProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6DBD8E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                        ),
                        child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))
                      )
                    )
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _cancelEdit,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                            ),
                            child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))
                          )
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handleEditProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6DBD8E),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                            ),
                            child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))
                          )
                        )
                      ]
                    )
                  ]
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleEditProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6DBD8E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                      ),
                      child: const Text('Edit Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))
                    )
                  )
                ]
              ] else ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      const Icon(Icons.history, size: 48, color: Color(0xFF2D7A5E)),
                      const SizedBox(height: 12),
                      const Text('View Request History',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('See all your past and completed requests.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ClientRequestsPage(user: widget.user, isHistory: true))),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D7A5E),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                          ),
                          child: const Text('View History', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))
                        )
                      )
                    ]
                  )
                )
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showLogoutDialog,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Logout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  )
                )
              ),
              const SizedBox(height: 80)
            ]
          )
        )
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D7A5E),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))]
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF2D7A5E),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          currentIndex: 3,
          onTap: (index) async {
            if (index == 3) return;
            if (index == 1) {
              await Navigator.push(context,
                MaterialPageRoute(builder: (_) => ClientRequestsPage(user: widget.user)));
              return;
            }
            if (index == 2) {
              await Navigator.push(context,
                MaterialPageRoute(builder: (_) => InboxPage(user: widget.user)));
              return;
            }
            Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => ClientHomePage(user: widget.user)),
              (route) => false);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Requests'),
            BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
          ]
        )
      )
    );
  }
}
