import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../users_data/user_model.dart';
import '../requests_data/request_model.dart';
import '../requests_data/requests_database.dart';
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

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF2D7A5E);
      case 'cancelled':
        return Colors.red[400]!;
      case 'in_progress':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Widget _buildRequestCard(Request request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(request.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(request.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2D7A5E),
                    side: const BorderSide(color: Color(0xFF2D7A5E)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5F1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          const Text('Fixit',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          const SizedBox(width: 24),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text('Resident',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[300], height: 1),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isHistoryView = false);
                      _loadRequests();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isHistoryView
                            ? const Color(0xFF2D7A5E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: !_isHistoryView
                              ? const Color(0xFF2D7A5E)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Active',
                          style: TextStyle(
                            color: !_isHistoryView
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isHistoryView = true);
                      _loadRequests();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isHistoryView
                            ? const Color(0xFF2D7A5E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: _isHistoryView
                              ? const Color(0xFF2D7A5E)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'History',
                          style: TextStyle(
                            color: _isHistoryView
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _requests.isEmpty
                ? Center(
                    child: Text(
                      'No requests',
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _requests.length,
                    itemBuilder: (_, i) =>
                        _buildRequestCard(_requests[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
