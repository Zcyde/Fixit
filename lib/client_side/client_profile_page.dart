import 'package:flutter/material.dart';
import '../users_data/users_database.dart';
import '../users_data/user_model.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  
  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _selectedTab = 'profile'; // 'profile' or 'history'
  bool _isEditing = false;
  late bool _wasProfileIncompleteOnLoad;
  
  // Form controllers
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
    
    // Store the original profile completion state
    _wasProfileIncompleteOnLoad = !widget.user.isProfileComplete;
    
    // Initialize controllers with user data
    _nameController = TextEditingController(text: widget.user.name);
    _contactController = TextEditingController(text: widget.user.phone);
    _emailController = TextEditingController(text: widget.user.email);
    _genderController = TextEditingController(text: widget.user.gender ?? '');
    _birthdateController = TextEditingController(text: widget.user.birthdate ?? '');
    _cityController = TextEditingController(text: widget.user.city ?? '');
    _barangayController = TextEditingController(text: widget.user.barangay ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    
    // If profile is incomplete, automatically enable editing mode
    if (_wasProfileIncompleteOnLoad) {
      _isEditing = true;
    }
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

  void _handleEditProfile() {
    if (_isEditing) {
      // Check if all required fields are filled
      if (_genderController.text.trim().isEmpty ||
          _birthdateController.text.trim().isEmpty ||
          _cityController.text.trim().isEmpty ||
          _barangayController.text.trim().isEmpty ||
          _addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all fields to complete your profile'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Save changes
      final updatedUser = widget.user.copyWith(
        name: _nameController.text.trim(),
        phone: _contactController.text.trim(),
        email: _emailController.text.trim(),
        gender: _genderController.text.trim(),
        birthdate: _birthdateController.text.trim(),
        city: _cityController.text.trim(),
        barangay: _barangayController.text.trim(),
        address: _addressController.text.trim(),
      );

      final success = UsersDatabase.updateUser(updatedUser);

      if (success) {
        setState(() {
          _isEditing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // If this was first time completing profile, go back to home
        if (_wasProfileIncompleteOnLoad) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Check if profile is complete - if yes, require password
      // Get fresh user data from database to check current state
      final currentUser = UsersDatabase.getUserById(widget.user.id);
      if (currentUser != null && currentUser.isProfileComplete) {
        _showPasswordVerificationDialog();
      } else {
        // Profile incomplete, allow editing without password
        setState(() {
          _isEditing = true;
        });
      }
    }
  }

  void _showPasswordVerificationDialog() {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          title: const Text(
            'Verify Password',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter your password to edit your profile:'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                passwordController.dispose();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final enteredPassword = passwordController.text.trim();
                
                if (enteredPassword == widget.user.password) {
                  // Password correct
                  passwordController.dispose();
                  Navigator.pop(context);
                  setState(() {
                    _isEditing = true;
                  });
                } else {
                  // Password incorrect
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect password'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  void _cancelEdit() {
    // Don't allow canceling if profile is still incomplete
    if (_wasProfileIncompleteOnLoad) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your profile before continuing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isEditing = false;
      // Reset controllers to original user data
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

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: _isEditing || enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: _isEditing ? Colors.white : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: _isEditing ? Colors.black : Colors.grey[400]!, width: _isEditing ? 2 : 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Get fresh user data to check current state
        final currentUser = UsersDatabase.getUserById(widget.user.id);
        
        // Prevent back navigation if profile is incomplete
        if (currentUser != null && !currentUser.isProfileComplete) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete your profile before continuing'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // Get fresh user data to check current state
              final currentUser = UsersDatabase.getUserById(widget.user.id);
              
              if (currentUser != null && !currentUser.isProfileComplete) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please complete your profile before continuing'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
        title: const Text(
          'Profile Page',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Hello, ${widget.user.name}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[300],
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Picture
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.grey[400]!, width: 2),
                ),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              
              // Username
              Text(
                widget.user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Profile / History Tabs
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 'profile';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 'profile' ? const Color(0xFF2D7A5E) : Colors.white,
                          border: Border.all(
                            color: _selectedTab == 'profile' ? const Color(0xFF2D7A5E) : Colors.grey[300]!,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Profile',
                            style: TextStyle(
                              color: _selectedTab == 'profile' ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 'history';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 'history' ? const Color(0xFF2D7A5E) : Colors.white,
                          border: Border.all(
                            color: _selectedTab == 'history' ? const Color(0xFF2D7A5E) : Colors.grey[300]!,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'History',
                            style: TextStyle(
                              color: _selectedTab == 'history' ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Show content based on selected tab
              if (_selectedTab == 'profile') ...[
                // Profile Form
                _buildTextField('Name', _nameController),
                const SizedBox(height: 16),
                _buildTextField('Contact Number', _contactController),
                const SizedBox(height: 16),
                _buildTextField('Email', _emailController),
                const SizedBox(height: 16),
                
                // Gender and Birthdate Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField('Gender', _genderController),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField('Birthdate', _birthdateController),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // City and Barangay Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField('City', _cityController),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField('Barangay', _barangayController),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildTextField('Address', _addressController),
                const SizedBox(height: 24),
                
                // Edit Profile / Save Buttons
                if (_isEditing) ...[
                  // Show cancel button only if profile was already complete
                  if (_wasProfileIncompleteOnLoad) ...[
                    // Just show save button for incomplete profiles
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleEditProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D7A5E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'SAVE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Show both cancel and save for complete profiles
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _cancelEdit,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: BorderSide(color: Colors.grey[300]!, width: 1),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handleEditProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D7A5E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'SAVE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleEditProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D7A5E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'EDIT PROFILE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ] else ...[
                // History Tab - Empty for now
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'History coming soon!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D7A5E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF2D7A5E),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          currentIndex: 3,
          onTap: (index) {
            if (index != 3) {
              Navigator.pop(context);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inbox),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      ),
    );
  }
}