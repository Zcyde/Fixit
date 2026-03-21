import 'package:flutter/material.dart';
import '../requests_data/request_model.dart';
import '../requests_data/messages_database.dart';
import '../requests_data/requests_database.dart';
import '../users_data/user_model.dart';
import '../client_side/chat_conversation_page.dart';

class MyJobDetailsPage extends StatefulWidget {
  final Request request;
  final User? worker;

  const MyJobDetailsPage({Key? key, required this.request, this.worker})
    : super(key: key);

  @override
  State<MyJobDetailsPage> createState() => _MyJobDetailsPageState();
}

class _MyJobDetailsPageState extends State<MyJobDetailsPage> {
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.request.budget);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _openChat() {
    final worker = widget.worker;
    if (worker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open chat: worker info not available.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final conversation = MessagesDatabase.createOrGet(
      clientId: widget.request.userId,
      clientName: widget.request.userName,
      workerId: worker.id,
      workerName: worker.name,
      requestId: widget.request.id,
      requestTitle: widget.request.title,
      requestType: widget.request.type,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConversationPage(
          conversation: conversation,
          currentUser: worker,
        ),
      ),
    );
  }

  void _markAsDone() {
    final updated = widget.request.copyWith(status: 'completed');
    RequestsDatabase.updateRequest(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job marked as completed!'),
        backgroundColor: Color(0xFF2D7A5E),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F1),
      appBar: AppBar(
        title: const Text(
          'Job Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5F1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.request.type,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2D7A5E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'In Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.request.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Client: ${widget.request.userName}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  if (widget.request.userAddress != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.request.userAddress!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.request.description,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Quoted Price',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: 'PHP ',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF2D7A5E),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openChat,
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text(
                  'Message Client',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D7A5E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _markAsDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D7A5E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Mark as Done',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
