import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../requests_data/request_model.dart';
import '../requests_data/requests_database.dart';
import '../users_data/user_model.dart';
import 'MyJobDetailsPage.dart';

class WorkRequestDetailsPage extends StatelessWidget {
  final Request request;
  final User? worker;
  final VoidCallback? onAccept;

  const WorkRequestDetailsPage({
    Key? key,
    required this.request,
    this.worker,
    this.onAccept,
  }) : super(key: key);

  void _handleAccept(BuildContext context) {
    final updated = request.copyWith(status: 'in_progress');
    RequestsDatabase.updateRequest(updated);
    if (onAccept != null) onAccept!();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Offer Accepted! Job is now in progress.'),
        backgroundColor: const Color(0xFF2D7A5E),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MyJobDetailsPage(request: updated, worker: worker),
      ),
    );
  }

  void _showFullscreenImageViewer(BuildContext context) {
    if (request.imagePaths.isEmpty) return;

    final images = request.imagePaths;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _WorkerImageViewer(images: images)),
    );
  }

  Widget _buildRequestImage() {
    if (request.imagePaths.isEmpty) {
      return _imagePlaceholder();
    }

    final path = request.imagePaths.first;

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }

    if (kIsWeb || path.startsWith('http')) {
      return Image.network(
        path,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }

    return Image.file(
      File(path),
      width: double.infinity,
      height: 220,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 220,
      color: Colors.grey[300],
      child: const Icon(Icons.construction, color: Colors.white, size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F1),
      appBar: AppBar(
        title: const Text(
          'Request Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 220,
                                  child: _buildRequestImage(),
                                ),
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _showFullscreenImageViewer(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black87,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    icon: const Icon(Icons.fullscreen, size: 16),
                                    label: const Text(
                                      'View',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  request.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Jan 28',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'High',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Location Section
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              request.userAddress ?? 'Angeles City, Pampanga',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Budget Section
                      Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 20,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'PHP ${request.budget}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Payment Method Section (Newly Added)
                      Row(
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            size: 20,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Payment: ${request.paymentMethod ?? "Not specified"}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Description:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        request.description,
                        style: TextStyle(
                          color: Colors.grey[700],
                          height: 1.4,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                'Go Back',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleAccept(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D7A5E),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                'Accept Job',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkerImageViewer extends StatefulWidget {
  final List<String> images;

  const _WorkerImageViewer({required this.images});

  @override
  State<_WorkerImageViewer> createState() => _WorkerImageViewerState();
}

class _WorkerImageViewerState extends State<_WorkerImageViewer> {
  int currentIndex = 0;

  Widget _buildViewerImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.contain);
    }

    if (kIsWeb || path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.contain);
    }

    return Image.file(File(path), fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    final currentImage = widget.images[currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${currentIndex + 1}/${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: _buildViewerImage(currentImage),
                ),
              ),
            ),
            if (widget.images.length > 1)
              Container(
                height: 120,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    final path = widget.images[index];
                    final isSelected = index == currentIndex;

                    Widget thumb;
                    if (path.startsWith('assets/')) {
                      thumb = Image.asset(path, fit: BoxFit.cover);
                    } else if (kIsWeb || path.startsWith('http')) {
                      thumb = Image.network(path, fit: BoxFit.cover);
                    } else {
                      thumb = Image.file(File(path), fit: BoxFit.cover);
                    }

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      child: Container(
                        width: 90,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: thumb,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}