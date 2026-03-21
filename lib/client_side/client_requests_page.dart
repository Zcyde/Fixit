import 'package:flutter/material.dart';
import '../users_data/user_model.dart';
import '../requests_data/request_model.dart';
import '../requests_data/requests_database.dart';
import 'client_request_details.dart';
import 'client_request_edit.dart';

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
  bool _isHistoryView = false;

  @override
  void initState() {
    super.initState();
    _isHistoryView = widget.isHistory;
    _loadRequests();
  }

  void _loadRequests() {
    final all = RequestsDatabase.getRequestsSortedByDate(widget.user.id);
    setState(() {
      _requests = _isHistoryView
          ? all.where((r) => r.status == 'completed' || r.status == 'cancelled').toList()
          : all.where((r) => r.status == 'pending' || r.status == 'in_progress').toList();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':      return const Color(0xFFFF9800);
      case 'in_progress':  return const Color(0xFF2196F3);
      case 'completed':    return const Color(0xFF2D7A5E);
      case 'cancelled':    return Colors.red;
      default:             return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':      return 'Pending';
      case 'in_progress':  return 'In Progress';
      case 'completed':    return 'Completed';
      case 'cancelled':    return 'Cancelled';
      default:             return status;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Widget _buildRequestCard(Request request) {
    final sc = _statusColor(request.status);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ClientRequestDetailsPage(
                  user: widget.user, request: request)),
        ).then((_) => _loadRequests()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.construction,
                        color: Color(0xFF2D7A5E), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        const SizedBox(height: 2),
                        Text(request.type,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: sc.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sc.withOpacity(0.4)),
                    ),
                    child: Text(_statusLabel(request.status),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: sc)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text('PHP ${request.budget}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  const Spacer(),
                  Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(_timeAgo(request.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ClientRequestDetailsPage(
                                user: widget.user, request: request)),
                      ).then((_) => _loadRequests()),
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('View', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2D7A5E),
                        side: const BorderSide(color: Color(0xFF2D7A5E)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  if (request.status == 'pending') ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ClientRequestEditPage(
                                  user: widget.user,
                                  serviceType: request.type,
                                  existingRequest: request)),
                        ).then((_) => _loadRequests()),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D7A5E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isHistoryView ? Icons.history_outlined : Icons.assignment_outlined,
              size: 72,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              _isHistoryView ? 'No completed requests yet' : 'No active requests',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              _isHistoryView
                  ? 'Your finished requests will show here.'
                  : 'Tap "Create Request" on the home screen to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
                ? [BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1))]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: active ? Colors.black87 : Colors.grey[600],
              ),
            ),
          ),
        ),
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
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('My Requests',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 17)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildTab('Active', !_isHistoryView, () {
                  setState(() => _isHistoryView = false);
                  _loadRequests();
                }),
                _buildTab('History', _isHistoryView, () {
                  setState(() => _isHistoryView = true);
                  _loadRequests();
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_requests.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                '${_requests.length} request${_requests.length == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
          Expanded(
            child: _requests.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                    itemCount: _requests.length,
                    itemBuilder: (_, i) => _buildRequestCard(_requests[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
