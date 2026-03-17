import 'package:flutter/material.dart';
import 'client_profile_page.dart';
import 'client_request_edit.dart';
import 'client_requests_page.dart';
import '../users_data/user_model.dart';
import '../sign_in_page.dart';
import '../users_data/users_database.dart';
import '../api/review_model.dart';
import '../api/review_api_service.dart';
// Ensure this path matches where your ChatPage is located
import '../worker_side/chat_page.dart';

class ClientHomePage extends StatefulWidget {
  final User user;
  
  const ClientHomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  int _selectedIndex = 0;
  late User currentUser;

  // Track unread messages. In a real app, this comes from a database.
  int unreadMessagesCount = 1;

  List<Review> _reviews = [];
  bool _isLoadingReviews = false;
  String? _reviewsError;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });

    try {
      final reviews = await ReviewApiService.fetchReviews();
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _reviewsError = e.toString();
        _isLoadingReviews = false;
      });
    }
  }

  void _refreshUser() {
    final updatedUser = UsersDatabase.getUserById(currentUser.id);
    if (updatedUser != null) {
      setState(() {
        currentUser = updatedUser;
      });
    }
  }

  bool _checkProfileAndProceed() {
    if (currentUser.isProfileComplete) {
      return true;
    } else {
      _showCompleteProfileRequirement();
      return false;
    }
  }

  void _showCompleteProfileRequirement() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          title: const Text(
            'Action Restricted',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'You need to complete your profile before you can create a request.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(user: currentUser),
                  ),
                );
                if (mounted) _refreshUser();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('Complete Profile'),
            ),
          ],
        );
      },
    );
  }

  void _onNavItemTapped(int index) async {
    // If we click Home, just update the index
    if (index == 0) {
      setState(() => _selectedIndex = 0);
      return;
    }

    // For other tabs, navigate to their respective pages
    switch (index) {
      case 1:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientRequestsPage(user: currentUser),
          ),
        );
        break;
      case 2: // INBOX LOGIC
        setState(() {
          unreadMessagesCount = 0; // Clear the badge when opened
        });
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatPage(
              initialMessage: '',
              workerName: 'Worker Support',
            ),
          ),
        );
        break;
      case 3:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(user: currentUser),
          ),
        );
        if (mounted) _refreshUser();
        break;
    }

    // Reset index back to Home (0) after returning from other pages
    if (mounted) {
      setState(() => _selectedIndex = 0);
    }
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required String serviceType,
  }) {
    return GestureDetector(
      onTap: () {
        if (_checkProfileAndProceed()) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClientRequestEditPage(
                user: currentUser,
                serviceType: serviceType,
              ),
            ),
          );
        }
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllReviewsModal() {
    final maxReviewsList = _reviews.take(20).toList();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.handyman, color: Color(0xFF2D7A5E)),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ratings and reviews',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
                            ),
                            Text(
                              'Fixit - Resident',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildPlayStoreChip('Most relevant', isActive: true),
                      const SizedBox(width: 8),
                      _buildPlayStoreChip('Star rating', isActive: false),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: maxReviewsList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 32),
                    itemBuilder: (context, index) {
                      return _buildPlayStoreReviewItem(maxReviewsList[index]);
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

  Widget _buildPlayStoreChip(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE8F5F1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? Colors.transparent : Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFF01875F) : Colors.grey[700],
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            size: 18,
            color: isActive ? const Color(0xFF01875F) : Colors.grey[700],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayStoreReviewItem(Review review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF607D8B),
              radius: 16,
              child: Text(
                review.name.isNotEmpty ? review.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                review.name,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
              ),
            ),
            const Icon(Icons.more_vert, size: 20, color: Colors.black54),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Row(
              children: List.generate(5, (index) => Icon(
                Icons.star,
                size: 14,
                color: index < 4 ? const Color(0xFF01875F) : Colors.grey[300],
              )),
            ),
            const SizedBox(width: 8),
            Text(
              'December 2, 2025',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          review.body,
          style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
        ),
        const SizedBox(height: 16),
        Text(
          '175 people found this review helpful',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Did you find this helpful?', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(50, 28),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: const Text('Yes', style: TextStyle(color: Colors.black87, fontSize: 12)),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(50, 28),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: const Text('No', style: TextStyle(color: Colors.black87, fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFF2D7A5E),
            width: 5.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ratings and reviews',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _reviews.isNotEmpty ? _showAllReviewsModal : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingReviews)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF01875F)),
                ),
              ),
            )
          else if (_reviewsError != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Failed to load reviews. Please retry.',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  TextButton(
                    onPressed: _fetchReviews,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_reviews.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlayStoreReviewItem(_reviews.first),
              ],
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text('No reviews available', style: TextStyle(color: Colors.grey)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5F1),
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Fixit',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Text(
                'Resident',
                style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInPage()),
                (route) => false,
              );
            },
            child: const Text('Log out', style: TextStyle(color: Colors.black, fontSize: 14)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Get help from talented people\nin your area',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
              ),
              const SizedBox(height: 12),
              Text(
                'Report repair problems fast and track updates in one place.',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),

              // Search Bar UI
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Padding(padding: EdgeInsets.all(12.0), child: Icon(Icons.search, color: Colors.grey)),
                    const Expanded(child: SizedBox()),
                    Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: const Text('Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_checkProfileAndProceed()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClientRequestEditPage(user: currentUser),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D7A5E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Create Request', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientRequestsPage(user: currentUser),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('My Requests', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const Text('Popular Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.80,
                children: [
                  _buildServiceCard(
                    title: 'Carpenter',
                    subtitle: 'Repairing, building, or installing doors and cabinets.',
                    imagePath: 'assets/carpenter.jpg',
                    serviceType: 'Carpentry',
                  ),
                  _buildServiceCard(
                    title: 'Welding',
                    subtitle: 'Skilled professionals for gates, fences, and metal work.',
                    imagePath: 'assets/welding.jpg',
                    serviceType: 'Welding',
                  ),
                  _buildServiceCard(
                    title: 'Plumber',
                    subtitle: 'Resolve broken pipes, leaky faucets, and water systems.',
                    imagePath: 'assets/plumber.jpg',
                    serviceType: 'Plumbing',
                  ),
                  _buildServiceCard(
                    title: 'Electrician',
                    subtitle: 'Safe repairs for wiring, switches, and outlets.',
                    imagePath: 'assets/electrician.jpg',
                    serviceType: 'Electrical',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Reviews Section
              _buildReviewsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2D7A5E),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF2D7A5E),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: _selectedIndex,
          onTap: _onNavItemTapped,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Requests'),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text('$unreadMessagesCount'),
                isLabelVisible: unreadMessagesCount > 0,
                backgroundColor: Colors.red,
                child: const Icon(Icons.inbox),
              ),
              label: 'Inbox',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
