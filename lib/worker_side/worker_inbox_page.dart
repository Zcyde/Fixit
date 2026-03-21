import 'package:flutter/material.dart';
import '../requests_data/message_model.dart';
import '../requests_data/messages_database.dart';
import '../users_data/user_model.dart';
import '../sign_in_page.dart';
import '../client_side/chat_conversation_page.dart';
import 'worker_requests_page.dart';
import 'worker_profile.dart';

class WorkerInboxPage extends StatefulWidget {
  final User worker;

  const WorkerInboxPage({Key? key, required this.worker}) : super(key: key);

  @override
  State<WorkerInboxPage> createState() => _WorkerInboxPageState();
}

class _WorkerInboxPageState extends State<WorkerInboxPage> {
  List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _conversations = MessagesDatabase.getConversationsForUser(widget.worker.id)
          .where((c) => c.workerId == widget.worker.id)
          .toList();
    });
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
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const mo = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${mo[dt.month]} ${dt.day}';
  }

  Widget _buildCard(Conversation conv) {
    final unread = conv.unreadCountFor(widget.worker.id);
    final last = conv.lastMessage;

    String preview = '';
    if (last != null) {
      final senderLabel = last.senderId == widget.worker.id ? 'You' : last.senderName.split(' ').first;
      preview = '$senderLabel: ${last.content}';
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.push(context,
          MaterialPageRoute(
            builder: (_) => ChatConversationPage(conversation: conv, currentUser: widget.worker)));
        _load();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))]
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE8F5F1),
                child: Text(conv.clientName.isNotEmpty ? conv.clientName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Color(0xFF2D7A5E), fontWeight: FontWeight.bold, fontSize: 14))
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(conv.clientName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                  overflow: TextOverflow.ellipsis)
              ),
              if (last != null) ...[
                Text(_timeLabel(last.timestamp), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(width: 8)
              ],
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: unread > 0 ? const Color(0xFF2D7A5E) : Colors.grey[300],
                  shape: BoxShape.circle
                ),
                alignment: Alignment.center,
                child: Text('$unread',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                    color: unread > 0 ? Colors.white : Colors.grey[600]))
              )
            ]),
            if (conv.requestTitle != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.build_outlined, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text('${conv.requestTitle} \u2022 ${conv.requestType ?? ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis)
                )
              ])
            ],
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(preview,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: (unread > 0 && last != null && last.senderId != widget.worker.id)
                    ? FontWeight.w600 : FontWeight.normal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)
            ]
          ])
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final int unread = MessagesDatabase.totalUnreadFor(widget.worker.id);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5F1),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Inbox', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
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
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Messages', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 4),
            Text('Conversations with clients for your accepted jobs.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4))
          ])
        ),
        Expanded(
          child: _conversations.isEmpty
            ? Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.mark_chat_unread_outlined, size: 64, color: Colors.grey[350]),
                  const SizedBox(height: 16),
                  Text('No messages yet',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                  const SizedBox(height: 6),
                  Text('Accept a job and message the client\nto get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[400]))
                ])
              )
            : RefreshIndicator(
                onRefresh: () async => _load(),
                color: const Color(0xFF2D7A5E),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: _conversations.length,
                  itemBuilder: (_, i) => _buildCard(_conversations[i])
                )
              )
        )
      ]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF2D7A5E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 2,
        onTap: (index) async {
          if (index == 2) return;
          if (index == 0) { Navigator.popUntil(context, (route) => route.isFirst); return; }
          if (index == 1) {
            await Navigator.push(context,
              MaterialPageRoute(builder: (_) => WorkerRequestsPage(worker: widget.worker)));
            if (mounted) setState(() {});
            return;
          }
          if (index == 3) {
            await Navigator.push(context,
              MaterialPageRoute(builder: (_) => WorkerProfilePage(user: widget.worker)));
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