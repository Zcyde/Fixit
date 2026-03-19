import 'package:flutter/material.dart';
import 'client_profile_page.dart';
import 'client_request_edit.dart';
import 'client_requests_page.dart';
import '../users_data/user_model.dart';
import '../sign_in_page.dart';
import '../users_data/users_database.dart';
import '../api/review_model.dart';
import '../api/review_api_service.dart';
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
  int unreadMessagesCount = 1;
  List<Review> _reviews = [];
  bool _isLoadingReviews = false;
  String? _reviewsError;

  final Map<int, bool?> _helpfulVotes = {};

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
      final results = await Future.wait([
        ReviewApiService.fetchReviews(),
        Future.delayed(const Duration(seconds: 3))
      ]);
      setState(() {
        _reviews = results[0] as List<Review>;
        _isLoadingReviews = false;
      });
    } catch (e) {
      await Future.delayed(const Duration(seconds: 3));
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
            borderRadius: BorderRadius.circular(12)
          ),
          title: const Text(
            'Action Restricted',
            style: TextStyle(fontWeight: FontWeight.bold)
          ),
          content: const Text(
            'You need to complete your profile before you can create a request.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
                backgroundColor: Colors.grey[200],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: const Text('Later', style: TextStyle(fontWeight: FontWeight.w700))
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage(user: currentUser))
                );
                if (mounted) _refreshUser();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6DBD8E),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: const Text(
                'Complete Profile',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700)
              )
            ),
          ],
        );
      },
    );
  }

  void _onNavItemTapped(int index) async {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
      return;
    }
    switch (index) {
      case 1:
        await Navigator.push(context, MaterialPageRoute(builder: (context) => ClientRequestsPage(user: currentUser)));
        break;
      case 2:
        setState(() { unreadMessagesCount = 0; });
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatPage(initialMessage: '', workerName: 'Worker Support')
          )
        );
        break;
      case 3:
        await Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(user: currentUser)));
        if (mounted) _refreshUser();
        break;
    }
    if (mounted) {
      setState(() => _selectedIndex = 0);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  int _helpfulCount(Review review) {
    final base = review.likes + (review.id * 11) % 80;
    final vote = _helpfulVotes[review.id];
    if (vote == true) return base + 1;
    return base;
  }

  void _onHelpfulVote(int reviewId, bool vote) {
    setState(() {
      if (_helpfulVotes[reviewId] == vote) {
        _helpfulVotes[reviewId] = null;
      } else {
        _helpfulVotes[reviewId] = vote;
      }
    });
  }

  Widget _serviceCard({
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
            MaterialPageRoute(builder: (_) => ClientRequestEditPage(user: currentUser, serviceType: serviceType))
          );
        }
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[300]!, width: 1)
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Image.asset(imagePath, fit: BoxFit.cover)
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, maxLines: 5, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[600]))
                ],
              )
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
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: const Icon(Icons.handyman, color: Color(0xFF2D7A5E))
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ratings and reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87)),
                                Text('Fixit - Resident', style: TextStyle(fontSize: 13, color: Colors.grey))
                              ],
                            )
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black54),
                            onPressed: () => Navigator.pop(context)
                          ),
                        ],
                      )
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: maxReviewsList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 32),
                        itemBuilder: (context, index) {
                          return _reviewItem(maxReviewsList[index], onVoteChanged: () => setModalState(() {}));
                        }
                      )
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _reviewItem(Review review, {VoidCallback? onVoteChanged}) {
    final currentVote = _helpfulVotes[review.id];
    final count = _helpfulCount(review);

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
                style: const TextStyle(color: Colors.white, fontSize: 14)
              )
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(review.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87))),
            const Icon(Icons.more_vert, size: 20, color: Colors.black54),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Row(
              children: List.generate(
                5,
                (index) => Icon(Icons.star, size: 14, color: index < review.rating ? const Color(0xFF01875F) : Colors.grey[300])
              )
            ),
            const SizedBox(width: 8),
            Text(_formatDate(review.reviewDate), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        Text(review.body, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
        const SizedBox(height: 16),
        Text('$count people found this review helpful', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Did you find this helpful?', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                _onHelpfulVote(review.id, true);
                onVoteChanged?.call();
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(50, 28),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: currentVote == true ? const Color(0xFFE8F5F1) : Colors.transparent,
                side: BorderSide(color: currentVote == true ? const Color(0xFF2D7A5E) : Colors.grey[300]!)
              ),
              child: Text(
                'Yes',
                style: TextStyle(
                  color: currentVote == true ? const Color(0xFF2D7A5E) : Colors.black87,
                  fontSize: 12,
                  fontWeight: currentVote == true ? FontWeight.bold : FontWeight.normal
                )
              )
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {
                _onHelpfulVote(review.id, false);
                onVoteChanged?.call();
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(50, 28),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: currentVote == false ? Colors.red[50] : Colors.transparent,
                side: BorderSide(color: currentVote == false ? Colors.red[300]! : Colors.grey[300]!)
              ),
              child: Text(
                'No',
                style: TextStyle(
                  color: currentVote == false ? Colors.red[400] : Colors.black87,
                  fontSize: 12,
                  fontWeight: currentVote == false ? FontWeight.bold : FontWeight.normal
                )
              )
            ),
          ],
        ),
      ],
    );
  }

  Widget _reviewsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFF2D7A5E), width: 5.0))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ratings and reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _reviews.isNotEmpty ? _showAllReviewsModal : null
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingReviews)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF01875F))
                )
              )
            )
          else if (_reviewsError != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!)
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Failed to load reviews. Please retry.', style: TextStyle(color: Colors.red[700]))),
                  TextButton(onPressed: _fetchReviews, child: const Text('Retry')),
                ],
              )
            )
          else if (_reviews.isNotEmpty)
            _reviewItem(_reviews.first)
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text('No reviews available', style: TextStyle(color: Colors.grey)))
            ),
        ],
      ),
    );
  }

  // 🔴 LOGOUT FUNCTION
  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                  (route) => false,
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
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
            const Text('Fixit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!)
              ),
              child: const Text('Resident', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500))
            ),
          ],
        ),
        actions: [
          // ✅ Use logout confirmation
          TextButton(
            onPressed: _logout,
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2)
              ),
              const SizedBox(height: 12),
              Text('Report repair problems fast and track updates in one place.', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              const SizedBox(height: 24),

              // ❌ SEARCH BAR REMOVED

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_checkProfileAndProceed()) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ClientRequestEditPage(user: currentUser)));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D7A5E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                      ),
                      child: const Text('Create Request', style: TextStyle(fontWeight: FontWeight.w600))
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ClientRequestsPage(user: currentUser)));
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                      ),
                      child: const Text('My Requests', style: TextStyle(fontWeight: FontWeight.w600))
                    )
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
                  _serviceCard(title: 'Carpenter', subtitle: 'Repairing, building, or installing doors and cabinets.', imagePath: 'assets/carpenter.jpg', serviceType: 'Carpentry'),
                  _serviceCard(title: 'Welding', subtitle: 'Skilled professionals for gates, fences, and metal work.', imagePath: 'assets/welding.jpg', serviceType: 'Welding'),
                  _serviceCard(title: 'Plumber', subtitle: 'Resolve broken pipes, leaky faucets, and water systems.', imagePath: 'assets/plumber.jpg', serviceType: 'Plumbing'),
                  _serviceCard(title: 'Electrician', subtitle: 'Safe repairs for wiring, switches, and outlets.', imagePath: 'assets/electrician.jpg', serviceType: 'Electrical'),
                  _serviceCard(title: 'Aircon Tech', subtitle: 'Cleaning and repair of aircon units.', imagePath: 'assets/aircontech.jpg', serviceType: 'Aircon'),
                  _serviceCard(title: 'Care Giver', subtitle: 'General and deep cleaning services.', imagePath: 'assets/caregiver.jpg', serviceType: 'Cleaning'),
                  _serviceCard(title: 'Appliance Repair', subtitle: 'Fix refrigerator, washing machine, etc.', imagePath: 'assets/applianceman.jpg', serviceType: 'Appliance'),
                  _serviceCard(title: 'Roof Repair', subtitle: 'Fix leaks and install roofing.', imagePath: 'assets/roofrepair.jpg', serviceType: 'Roofing'),
                ],
              ),

              const SizedBox(height: 32),
              _reviewsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2D7A5E),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))]
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
                child: const Icon(Icons.inbox)
              ),
              label: 'Inbox'
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
    
  }
}