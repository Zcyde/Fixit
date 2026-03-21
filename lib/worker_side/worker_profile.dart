import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../users_data/users_database.dart';
import '../users_data/user_model.dart';
import '../requests_data/messages_database.dart';
import '../sign_in_page.dart';
import 'worker_inbox_page.dart';
import 'worker_requests_page.dart';

class _PortfolioStore {
  static final Map<String, List<XFile>> _photos = {};
  static List<XFile> get(String userId) => _photos[userId] ?? [];
  static void add(String userId, XFile photo) {
    _photos.putIfAbsent(userId, () => []);
    _photos[userId]!.add(photo);
  }
  static void remove(String userId, int index) {
    if (_photos.containsKey(userId) && index < _photos[userId]!.length) {
      _photos[userId]!.removeAt(index);
    }
  }
}

class _WorkerProfilePictureStore {
  static final Map<String, XFile?> _pictures = {};
  static XFile? get(String userId) => _pictures[userId];
  static void set(String userId, XFile photo) => _pictures[userId] = photo;
}

class WorkerProfilePage extends StatefulWidget {
  final User user;

  const WorkerProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<WorkerProfilePage> createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) setState(() => _WorkerProfilePictureStore.set(widget.user.id, image));
  }

  Future<void> _addPortfolioPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) setState(() => _PortfolioStore.add(widget.user.id, image));
  }

  ImageProvider? _getProfileImage() {
    final pic = _WorkerProfilePictureStore.get(widget.user.id);
    if (pic == null) return null;
    if (kIsWeb) return NetworkImage(pic.path);
    return FileImage(File(pic.path));
  }

  void _deletePhoto(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Remove Photo', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to remove this photo from your portfolio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text('Cancel')
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _PortfolioStore.remove(widget.user.id, index));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            child: const Text('Remove')
          )
        ]
      )
    );
  }

  void _handleEditTap() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text('Cancel')
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text.trim() == widget.user.password) {
                Navigator.pop(dialogContext);
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => _WorkerEditProfilePage(user: widget.user))
                ).then((_) => setState(() {}));
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
      )
    );
  }

  void _openPhotoViewer(BuildContext context, int startIndex) {
    final photos = _PortfolioStore.get(widget.user.id);
    Navigator.push(context,
      MaterialPageRoute(builder: (_) => _PortfolioViewer(photos: photos, initialIndex: startIndex)));
  }

  Widget _buildAvatar() {
    final profileImage = _getProfileImage();
    return GestureDetector(
      onTap: _pickProfilePicture,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: const Color(0xFFE8F5F1),
            backgroundImage: profileImage,
            child: profileImage == null
              ? const Icon(Icons.person, size: 45, color: Color(0xFF2D7A5E))
              : null
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Color(0xFF2D7A5E), shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 14)
            )
          )
        ]
      )
    );
  }

  Widget _buildPortfolioSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Portfolio (${_PortfolioStore.get(widget.user.id).length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: _addPortfolioPhoto,
              icon: const Icon(Icons.add, size: 18, color: Colors.black),
              label: const Text('Add', style: TextStyle(color: Colors.black))
            )
          ]
        ),
        const SizedBox(height: 12),
        if (_PortfolioStore.get(widget.user.id).isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text('No portfolio photos yet.\nTap "Add" to upload your work.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13))
              ]
            )
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.0
            ),
            itemCount: _PortfolioStore.get(widget.user.id).length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => _openPhotoViewer(context, index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                        ? Image.network(_PortfolioStore.get(widget.user.id)[index].path,
                            width: double.infinity, height: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey[300],
                              child: Icon(Icons.broken_image, color: Colors.grey[500], size: 40)))
                        : Image.file(File(_PortfolioStore.get(widget.user.id)[index].path),
                            width: double.infinity, height: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey[300],
                              child: Icon(Icons.broken_image, color: Colors.grey[500], size: 40)))
                    )
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _deletePhoto(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16)
                      )
                    )
                  )
                ]
              );
            }
          )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UsersDatabase.getUserById(widget.user.id) ?? widget.user;
    final int unread = MessagesDatabase.totalUnreadFor(widget.user.id);

    return Scaffold(
      backgroundColor: const Color(0xFFD9F2E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5F1),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF2D7A5E)))),
                  TextButton(
                    onPressed: () { Navigator.pop(ctx); Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignInPage()), (route) => false); },
                    child: const Text('Logout', style: TextStyle(color: Colors.red))
                  )
                ]
              )
            ),
            child: const Text('Log out', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500))
          )
        ]
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black),
                      onPressed: _handleEditTap
                    )
                  ),
                  _buildAvatar(),
                  const SizedBox(height: 12),
                  Text(currentUser.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text('Fixit Worker', style: TextStyle(color: Colors.grey))
                ]
              )
            ),
            const SizedBox(height: 24),
            _buildPortfolioSection(),
            const SizedBox(height: 100)
          ]
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF2D7A5E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 3,
        onTap: (index) async {
          if (index == 3) return;
          if (index == 0) { Navigator.popUntil(context, (route) => route.isFirst); return; }
          if (index == 1) {
            await Navigator.push(context,
              MaterialPageRoute(builder: (_) => WorkerRequestsPage(worker: widget.user)));
            if (mounted) setState(() {});
            return;
          }
          if (index == 2) {
            await Navigator.push(context,
              MaterialPageRoute(builder: (_) => WorkerInboxPage(worker: widget.user)));
            if (mounted) setState(() {});
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Requests'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$unread'),
              isLabelVisible: unread > 0,
              backgroundColor: Colors.red,
              child: const Icon(Icons.inbox)
            ),
            label: 'Inbox'
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
        ]
      )
    );
  }
}

class _WorkerEditProfilePage extends StatefulWidget {
  final User user;
  const _WorkerEditProfilePage({required this.user});

  @override
  State<_WorkerEditProfilePage> createState() => _WorkerEditProfilePageState();
}

class _WorkerEditProfilePageState extends State<_WorkerEditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _contactController = TextEditingController(text: widget.user.phone);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isNotEmpty || confirmPassword.isNotEmpty) {
      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red
        ));
        return;
      }
    }

    final updatedUser = widget.user.copyWith(
      name: _nameController.text.trim(),
      phone: _contactController.text.trim(),
      email: _emailController.text.trim(),
      password: newPassword.isNotEmpty ? newPassword : widget.user.password
    );

    final success = UsersDatabase.updateUser(updatedUser);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profile updated!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1)
      ));
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to update profile'),
        backgroundColor: Colors.red
      ));
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
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
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Leave blank to keep current password',
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2D7A5E), width: 1.5)
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey[500], size: 20),
              onPressed: onToggle
            )
          )
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F2E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context)
        ),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: Column(
                children: [
                  _buildTextField('Name', _nameController),
                  const SizedBox(height: 16),
                  _buildTextField('Contact Number', _contactController),
                  const SizedBox(height: 16),
                  _buildTextField('Email', _emailController),
                  const SizedBox(height: 16),
                  _buildPasswordField('New Password', _passwordController, _obscurePassword,
                    () => setState(() => _obscurePassword = !_obscurePassword)),
                  const SizedBox(height: 16),
                  _buildPasswordField('Confirm Password', _confirmPasswordController, _obscureConfirm,
                    () => setState(() => _obscureConfirm = !_obscureConfirm)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
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
                          onPressed: _handleSave,
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
              )
            ),
            const SizedBox(height: 40)
          ]
        )
      )
    );
  }
}

class _PortfolioViewer extends StatefulWidget {
  final List<XFile> photos;
  final int initialIndex;

  const _PortfolioViewer({required this.photos, required this.initialIndex});

  @override
  State<_PortfolioViewer> createState() => _PortfolioViewerState();
}

class _PortfolioViewerState extends State<_PortfolioViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPhoto(XFile photo) {
    if (kIsWeb) {
      return Image.network(photo.path, fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 60)));
    }
    return Image.file(File(photo.path), fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 60)));
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.photos.length;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: total,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (_, i) => InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(child: _buildPhoto(widget.photos[i]))
              )
            ),
            Positioned(
              top: 0, left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 22)
                      ),
                      onPressed: () => Navigator.pop(context)
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text('${_currentIndex + 1} / $total',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))
                    ),
                    const SizedBox(width: 48)
                  ]
                )
              )
            ),
            if (total > 1 && _currentIndex > 0)
              Positioned(
                left: 8, top: 0, bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 250), curve: Curves.easeInOut),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
                      child: const Icon(Icons.chevron_left, color: Colors.white, size: 30)
                    )
                  )
                )
              ),
            if (total > 1 && _currentIndex < total - 1)
              Positioned(
                right: 8, top: 0, bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 250), curve: Curves.easeInOut),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
                      child: const Icon(Icons.chevron_right, color: Colors.white, size: 30)
                    )
                  )
                )
              ),
            if (total > 1)
              Positioned(
                bottom: 24, left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(total, (i) {
                    final active = i == _currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(4)
                      )
                    );
                  })
                )
              )
          ]
        )
      )
    );
  }
}