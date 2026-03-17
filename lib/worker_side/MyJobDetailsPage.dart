import 'package:flutter/material.dart';
import '../requests_data/request_model.dart';
import '../worker_side/chat_page.dart'; // Make sure this is the correct path to your ChatPage

class MyJobDetailsPage extends StatefulWidget {
  final Request request;
  const MyJobDetailsPage({Key? key, required this.request}) : super(key: key);

  @override
  State<MyJobDetailsPage> createState() => _MyJobDetailsPageState();
}

class _MyJobDetailsPageState extends State<MyJobDetailsPage> {
  late TextEditingController priceController;
  late TextEditingController messageController;

  @override
  void initState() {
    super.initState();
    priceController = TextEditingController(text: '${widget.request.budget}');
    messageController = TextEditingController();
  }

  @override
  void dispose() {
    priceController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please type a message before sending')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message sent: "$message"')),
    );

    messageController.clear();
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job title
            Text(widget.request.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 12),

            // Description
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(widget.request.description,
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 20),

            // Your Price
            const Text('Your Price:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'PHP ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),

            // Message Client TextField
            const Text('Message Client:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type your message to the worker...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),

            // Send Button
           Center(
  child: ElevatedButton.icon(
    onPressed: () {
      if (messageController.text.trim().isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage( // <-- Capital C
              initialMessage: messageController.text.trim(),
              workerName: widget.request.workerName ?? 'Worker'
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a message before sending.')),
        );
      }
    },
    icon: const Icon(Icons.message),
    label: const Text('Message Client'),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2D7A5E),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
),
          ],
        ),
      ),
    );
  }
}