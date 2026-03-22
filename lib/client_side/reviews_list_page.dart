import 'package:flutter/material.dart';
import '../api/review_model.dart';
import '../api/review_api_service.dart';
import '../users_data/user_model.dart';

class ReviewsListPage extends StatefulWidget {
  final User currentUser;
  const ReviewsListPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<ReviewsListPage> createState() => _ReviewsListPageState();
}

class _ReviewsListPageState extends State<ReviewsListPage> {
  List<Review> _apiReviews = [];
  bool _isLoading = false;
  String? _error;
  final Map<int, bool?> _helpfulVotes = {};

  List<Review> get _allReviews => [...ReviewLocalStore.all, ..._apiReviews];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final reviews = await ReviewApiService.fetchReviews(limit: 20);
      if (mounted) setState(() { _apiReviews = reviews; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _onHelpfulVote(int reviewId, bool vote) {
    setState(() => _helpfulVotes[reviewId] = _helpfulVotes[reviewId] == vote ? null : vote);
  }

  String _formatDate(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

 int _helpfulCount(Review review) {
  final base = review.ownerId != null ? review.likes : review.likes + (review.id * 11) % 80;
  return _helpfulVotes[review.id] == true ? base + 1 : base;
}

  Color _avatarColor(int index) {
    const colors = [Color(0xFF2D7A5E), Color(0xFF607D8B), Color(0xFF795548), Color(0xFF5C6BC0), Color(0xFF00897B)];
    return colors[index % colors.length];
  }

  void _showReviewDialog({Review? existing}) {
    final bodyCtrl = TextEditingController(text: existing?.body ?? '');
    int rating = existing?.rating ?? 5;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            existing == null ? 'Write a Review' : 'Edit Review',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your rating', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setDialog(() => rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.star_rounded,
                      size: 34,
                      color: i < rating ? const Color(0xFF2D7A5E) : Colors.grey[300],
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 16),
              const Text('Your review', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: bodyCtrl,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2D7A5E), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = bodyCtrl.text.trim();
                if (text.isEmpty) return;
                if (existing != null) {
                  ReviewLocalStore.update(existing.copyWith(body: text, manualRating: rating));
                } else {
                  ReviewLocalStore.add(Review(
                    id: DateTime.now().millisecondsSinceEpoch,
                    name: widget.currentUser.name,
                    username: widget.currentUser.email,
                    body: text,
                    likes: 0,
                    ownerId: widget.currentUser.id,
                    manualRating: rating,
                    manualDate: DateTime.now(),
                  ));
                }
                Navigator.pop(ctx);
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D7A5E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                existing == null ? 'Post' : 'Save',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Review review) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Review', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete your review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ReviewLocalStore.delete(review.id);
              Navigator.pop(ctx);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D7A5E))),
          SizedBox(height: 16),
          Text('Loading reviews...', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Failed to load reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)),
            const SizedBox(height: 8),
            Text('Check your internet connection and try again.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchReviews,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D7A5E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review, int index) {
    final isOwn = review.ownerId == widget.currentUser.id;
    final vote = _helpfulVotes[review.id];
    final count = _helpfulCount(review);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: isOwn ? const Color(0xFF2D7A5E) : _avatarColor(index),
                radius: 20,
                child: Text(
                  review.name.isNotEmpty ? review.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(review.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                  Text(
                    isOwn ? 'Your review' : '@${review.username}',
                    style: TextStyle(fontSize: 12, color: isOwn ? const Color(0xFF2D7A5E) : Colors.grey[500]),
                  ),
                ]),
              ),
              if (isOwn) Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey[600]),
                  onPressed: () => _showReviewDialog(existing: review),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                  onPressed: () => _confirmDelete(review),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ]) else const Icon(Icons.more_vert, size: 18, color: Colors.black38),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, size: 16, color: i < review.rating ? const Color(0xFF2D7A5E) : Colors.grey[300]))),
              const SizedBox(width: 8),
              Text(_formatDate(review.reviewDate), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ]),
            const SizedBox(height: 10),
            Text(review.body, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 10),
            Text('$count people found this review helpful', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 8),
            Row(children: [
              Text('Helpful?', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(width: 10),
              _voteButton(label: 'Yes', isSelected: vote == true, selectedColor: const Color(0xFF2D7A5E), onTap: () => _onHelpfulVote(review.id, true)),
              const SizedBox(width: 8),
              _voteButton(label: 'No', isSelected: vote == false, selectedColor: Colors.red, onTap: () => _onHelpfulVote(review.id, false)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _voteButton({required String label, required bool isSelected, required Color selectedColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? selectedColor : Colors.grey[300]!),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? selectedColor : Colors.black87)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allReviews = _allReviews;
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5F1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Ratings & Reviews', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          if (!_isLoading) IconButton(icon: const Icon(Icons.refresh, color: Colors.black54), onPressed: _fetchReviews, tooltip: 'Refresh'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReviewDialog(),
        backgroundColor: const Color(0xFF2D7A5E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Write Review', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: _isLoading && allReviews.isEmpty
        ? _buildLoadingState()
        : _error != null && allReviews.isEmpty
          ? _buildErrorState()
          : allReviews.isEmpty
            ? const Center(child: Text('No reviews available.', style: TextStyle(color: Colors.grey)))
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(left: BorderSide(color: Color(0xFF2D7A5E), width: 4)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.star_rounded, color: Color(0xFF2D7A5E), size: 20),
                    const SizedBox(width: 8),
                    Text('${allReviews.length} reviews from the community', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
                  ]),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: allReviews.length,
                    itemBuilder: (context, index) => _buildReviewCard(allReviews[index], index),
                  ),
                ),
              ]),
    );
  }
}