import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../users_data/user_model.dart';
import '../requests_data/request_model.dart';
import '../requests_data/requests_database.dart';

class ClientRequestEditPage extends StatefulWidget {
  final String? serviceType;
  final User user;
  final Request? existingRequest; 
  const ClientRequestEditPage({
    Key? key,
    this.serviceType,
    required this.user,
    this.existingRequest,
  }) : super(key: key);

  @override
  State<ClientRequestEditPage> createState() => _ClientRequestEditPageState();
}

class _ClientRequestEditPageState extends State<ClientRequestEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'Plumbing';
  String _selectedPriority = 'Medium';

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.existingRequest != null;

  final List<String> _serviceTypes = [
    'Plumbing', 'Carpentry', 'Welding', 'Electrical', 'Painting', 'Masonry', 'Other',
  ];

  final List<String> _priorities = [
    'Low', 'Medium', 'High', 'Urgent',
  ];

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final r = widget.existingRequest!;
      _titleController.text = r.title;
      _budgetController.text = r.budget;
      _descriptionController.text = r.description;
      _selectedType = _serviceTypes.contains(r.type) ? r.type : 'Plumbing';
      _selectedPriority = _priorities.contains(r.priority) ? r.priority : 'Medium';
    } else {
      if (widget.serviceType != null && _serviceTypes.contains(widget.serviceType)) {
        _selectedType = widget.serviceType!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() => _selectedImages.addAll(images));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() => _selectedImages.add(photo));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Widget _displayImage(XFile file, {BoxFit fit = BoxFit.cover}) {
    if (kIsWeb) {
      return Image.network(file.path, fit: fit,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)));
    } else {
      return Image.file(File(file.path), fit: fit);
    }
  }

  Widget _displayImageFromPath(String path, {BoxFit fit = BoxFit.cover}) {
    if (kIsWeb) {
      return Image.network(path, fit: fit,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)));
    } else {
      return Image.file(File(path), fit: fit,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)));
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () { Navigator.pop(context); _pickImages(); },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () { Navigator.pop(context); _takePhoto(); },
              ),
              if (_selectedImages.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('View new images'),
                  onTap: () { Navigator.pop(context); _showImagePreview(); },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showImagePreview() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text('New Images (${_selectedImages.length})'),
                  backgroundColor: const Color(0xFF2D7A5E),
                  foregroundColor: Colors.white,
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8,
                    ),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _displayImage(_selectedImages[index]),
                          ),
                          Positioned(
                            top: 4, right: 4,
                            child: GestureDetector(
                              onTap: () {
                                _removeImage(index);
                                Navigator.pop(context);
                                if (_selectedImages.isNotEmpty) _showImagePreview();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveRequest() {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        final existingPaths = widget.existingRequest!.imagePaths;
        final newPaths = _selectedImages.map((img) => img.path).toList();
        final allPaths = [...existingPaths, ...newPaths];

        final updatedRequest = widget.existingRequest!.copyWith(
          title: _titleController.text.trim(),
          type: _selectedType,
          budget: _budgetController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          imagePaths: allPaths,
        );

        final success = RequestsDatabase.updateRequest(updatedRequest);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request updated successfully!'),
              backgroundColor: Color(0xFF2D7A5E),
              duration: Duration(seconds: 2),
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update request.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        final newRequest = Request(
          id: 'req_${DateTime.now().millisecondsSinceEpoch}',
          title: _titleController.text.trim(),
          type: _selectedType,
          budget: _budgetController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          imagePaths: _selectedImages.map((img) => img.path).toList(),
          createdAt: DateTime.now(),
          userId: widget.user.id,
          userName: widget.user.name,
          userEmail: widget.user.email,
          userPhone: widget.user.phone,
          userGender: widget.user.gender,
          userBirthdate: widget.user.birthdate,
          userCity: widget.user.city,
          userBarangay: widget.user.barangay,
          userAddress: widget.user.address,
          status: 'pending',
        );

        RequestsDatabase.addRequest(newRequest);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request saved successfully!'),
            backgroundColor: Color(0xFF2D7A5E),
            duration: Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2D7A5E), width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'This field is required';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            icon: const Icon(Icons.keyboard_arrow_down),
            items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final existingPaths = widget.existingRequest?.imagePaths ?? [];
    final hasNewImages = _selectedImages.isNotEmpty;
    final hasExistingImages = existingPaths.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5F1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Request' : 'Request edit',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text('Fixit', style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(label: 'Title', controller: _titleController, hintText: 'e.g., Leaking Faucet sa KITCHEN'),
                const SizedBox(height: 20),
                _buildDropdown(label: 'Type', value: _selectedType, items: _serviceTypes, onChanged: (value) => setState(() => _selectedType = value!)),
                const SizedBox(height: 20),
                _buildTextField(label: 'Budget', controller: _budgetController, hintText: 'e.g., Pending or ₱500'),
                const SizedBox(height: 20),
                _buildTextField(label: 'Description', controller: _descriptionController, maxLines: 5, hintText: 'Describe the issue in detail...'),
                const SizedBox(height: 20),
                _buildDropdown(label: 'Priority', value: _selectedPriority, items: _priorities, onChanged: (value) => setState(() => _selectedPriority = value!)),
                const SizedBox(height: 20),
                const Text('Photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showImageOptions,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: (!hasNewImages && !hasExistingImages)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]),
                              const SizedBox(height: 8),
                              Text('Upload / Preview', style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                            ],
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: hasNewImages
                                      ? _displayImage(_selectedImages[0])
                                      : _displayImageFromPath(existingPaths[0]),
                                ),
                              ),
                              if ((hasNewImages ? _selectedImages.length : 0) + existingPaths.length > 1)
                                Positioned(
                                  top: 8, right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '+${(hasNewImages ? _selectedImages.length : 0) + existingPaths.length - 1} more',
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.photo_library, color: Colors.white, size: 32),
                                        SizedBox(height: 4),
                                        Text('Tap to add more images', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D7A5E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      _isEditing ? 'Save Changes' : 'Save Request',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
