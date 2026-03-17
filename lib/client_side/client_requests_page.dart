import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../users_data/user_model.dart';
import '../requests_data/request_model.dart';
import '../requests_data/requests_database.dart';
import 'client_home_page.dart';
import 'client_profile_page.dart';
import 'client_request_details.dart';

class ClientRequestsPage extends StatefulWidget {
  final User user;
  final bool isHistory;

  const ClientRequestsPage({
    Key? key,
    required this.user,
    this.isHistory = false,
  }) : super(key: key);

  @override
  State<ClientRequestsPage> createState() => _ClientRequestsPageState();
}

class _ClientRequestsPageState extends State<ClientRequestsPage> {
  List<Request> _requests = [];
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1;

  bool _isHistoryView = false;

  @override
  void initState() {
    super.initState();
    _isHistoryView = widget.isHistory;
    _loadRequests();
  }

  void _loadRequests() {
    final allRequests =
        RequestsDatabase.getRequestsSortedByDate(widget.user.id);

    setState(() {
      if (_isHistoryView) {
        _requests = allRequests
            .where((r) =>
                r.status == 'completed' || r.status == 'cancelled')
            .toList();
      } else {
        _requests = allRequests
            .where((r) =>
                r.status == 'pending' || r.status == 'in_progress')
            .toList();
      }
    });
  }

  Widget _buildRequestCard(Request request) {
    bool isHistory =
        request.status == 'completed' || request.status == 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(request.title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text("Status: ${request.status.toUpperCase()}"),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClientRequestDetailsPage(
                          user: widget.user,
                          request: request,
                        ),
                      ),
                    ).then((_) => _loadRequests());
                  },
                  child: const Text("View"),
                ),
              ),
              const SizedBox(width: 8),
              if (!isHistory)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text("Edit"),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F1),
      appBar: AppBar(
        title: Text(_isHistoryView ? 'Request History' : 'My Requests'),
        backgroundColor: const Color(0xFFE8F5F1),
        elevation: 0,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _isHistoryView = false);
                    _loadRequests();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: !_isHistoryView ? Colors.black : Colors.white,
                    child: Center(
                      child: Text('Active',
                          style: TextStyle(
                              color: !_isHistoryView
                                  ? Colors.white
                                  : Colors.black)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _isHistoryView = true);
                    _loadRequests();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: _isHistoryView ? Colors.black : Colors.white,
                    child: Center(
                      child: Text('History',
                          style: TextStyle(
                              color: _isHistoryView
                                  ? Colors.white
                                  : Colors.black)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: _requests.isEmpty
                ? const Center(child: Text("No requests"))
                : ListView.builder(
                    itemCount: _requests.length,
                    itemBuilder: (_, i) =>
                        _buildRequestCard(_requests[i]),
                  ),
          )
        ],
      ),
    );
  }
}