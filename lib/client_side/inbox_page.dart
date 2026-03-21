import 'package:flutter/material.dart';
import '../requests_data/message_model.dart';
import '../requests_data/messages_database.dart';
import '../users_data/user_model.dart';
import '../sign_in_page.dart';
import 'chat_conversation_page.dart';
import 'client_home_page.dart';
import 'client_profile_page.dart';
import 'client_requests_page.dart';

class InboxPage extends StatefulWidget {
  final User user;

  const InboxPage({Key? key, required this.user}) : super(key: key);

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  List<Conversation> _conversations = [];
  final int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _conversations = MessagesDatabase.getConversationsForUser(widget.user.id);
    });
  }

  int get _unreadCount => MessagesDatabase.totalUnreadFor(widget.user.id);

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const SignInPage()), (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onNavItemTapped(int index) async {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => ClientHomePage(user: widget.user)),
            (route) => false);
        break;
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => ClientRequestsPage(user: widget.user)));
        break;
      case 3:
        await Navigator.push(context,
            MaterialPageRoute(builder: (_) => ProfilePage(user: widget.user)));
        if (mounted) setState(() {});
        break;
    }
  }

  String _timeLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 24) {
      final h = dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      final p = h >= 12 ? 'PM' : 'AM';
      final d = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$d:$m $p';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    const mo = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${mo[dt.month]} ${dt.day}';
  }

  Widget _buildCard(Conversation conv) {
    final unread = conv.unreadCountFor(widget.user.id);
    final last = conv.lastMessage;

    String preview = '';
    if (last != null) {
      final senderLabel = last.senderId == widget.user.id ? 'You' : last.senderName.split(' ').first;
      preview = '$senderLabel: ${last.content}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Text(
                conv.displayNameFor(widget.user.id),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (last != null) ...[
              Text(_timeLabel(last.timestamp), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(width: 8),
            ],
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: unread > 0 ? const Color(0xFF2D7A5E) : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text('$unread',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: unread > 0 ? Colors.white : Colors.grey[600])),
            ),
          ]),
          if (conv.requestTitle != null) ...[
            const SizedBox(height: 4),
            Text(
              'Related: ${conv.requestTitle} \u2022 ${conv.requestType ?? ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              preview,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: (unread > 0 && last != null && last.senderId != widget.user.id)
                      ? FontWeight.w600
                      : FontWeight.normal),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              await Navigator.push(context,
                MaterialPageRoute(builder: (_) => ChatConversationPage(conversation: conv, currentUser: widget.user)),
              );
              _load();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey[350]!),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Tap to open chat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = _unreadCount;
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F1),
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
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text('Inbox', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: _logout,
            child: const Text('Log out', style: TextStyle(color: Colors.black, fontSize: 14)),
          ),
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Messages',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 4),
            Text(
              'For coordination between resident and assigned repairman (prototype chat).',
              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
            ),
          ]),
        ),
        Expanded(
          child: _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mark_chat_unread_outlined, size: 64, color: Colors.grey[350]),
                      const SizedBox(height: 16),
                      Text('No messages yet',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                      const SizedBox(height: 6),
                      Text('Your conversations will appear here',
                          style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _load(),
                  color: const Color(0xFF2D7A5E),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _conversations.length,
                    itemBuilder: (_, i) => _buildCard(_conversations[i]),
                  ),
                ),
        ),
      ]),
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
                label: Text('$unread'),
                isLabelVisible: unread > 0,
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
