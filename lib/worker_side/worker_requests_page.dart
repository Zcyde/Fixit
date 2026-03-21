import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../requests_data/request_model.dart';
import '../requests_data/requests_database.dart';
import '../users_data/user_model.dart';
import 'MyJobDetailsPage.dart';

class WorkerRequestsPage extends StatefulWidget {
  final User worker;
  final Set<String> myJobIds;

  const WorkerRequestsPage({
    Key? key,
    required this.worker,
    required this.myJobIds,
  }) : super(key: key);

  @override
  State<WorkerRequestsPage> createState() => _WorkerRequestsPageState();
}

class _WorkerRequestsPageState extends State<WorkerRequestsPage> {
  bool _isHistoryView = false;

  @override
  void initState() {
    super.initState();
    // Sync DB so myJobIds is up to date
    final allJobs = RequestsDatabase.getAllRequests();
    for (final r in allJobs) {
      if (r.status == 'in_progress' || r.status == 'completed') {
        widget.myJobIds.add(r.id);
      }
    }
  }

  List<Request> get _activeJobs => RequestsDatabase.getAllRequests()
      .where((r) =>
          r.status == 'in_progress' && widget.myJobIds.contains(r.id))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Request> get _completedJobs => RequestsDatabase.getAllRequests()
      .where((r) =>
          (r.status == 'completed' || r.status == 'cancelled') &&
          widget.myJobIds.contains(r.id))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'in_progress': return const Color(0xFF2196F3);
      case 'completed':   return const Color(0xFF2D7A5E);
      case 'cancelled':   return Colors.red;
      default:            return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress': return 'In Progress';
      case 'completed':   return 'Completed';
      case 'cancelled':   return 'Cancelled';
      default:            return status;
    }
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) return _placeholder();
    if (kIsWeb || path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder());
    }
    return Image.file(File(path), fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder());
  }

  Widget _placeholder() => Container(
    color: Colors.grey[200],
    child: Center(child: Icon(Icons.construction, size: 32, color: Colors.grey[400])),
  );

  Widget _buildJobCard(Request request) {
    final sc = _statusColor(request.status);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (request.status == 'in_progress') {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyJobDetailsPage(
                  request: request,
                  worker: widget.worker,
                ),
              ),
            );
            if (result == true) setState(() {});
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44, height: 44,
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
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: sc.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sc.withOpacity(0.4)),
                    ),
                    child: Text(_statusLabel(request.status),
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600, color: sc)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(request.userName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const Spacer(),
                  Icon(Icons.attach_money, size: 14, color: Colors.grey[500]),
                  Text('PHP ${request.budget}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time, size: 13, color: Colors.grey[400]),
                  const SizedBox(width: 3),
                  Text(_timeAgo(request.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
              if (request.status == 'in_progress') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyJobDetailsPage(
                            request: request,
                            worker: widget.worker,
                          ),
                        ),
                      );
                      if (result == true) setState(() {});
                    },
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('View Job Details',
                        style: TextStyle(fontSize: 13)),
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
              _isHistoryView ? Icons.history_outlined : Icons.work_outline,
              size: 72, color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              _isHistoryView ? 'No completed jobs yet' : 'No active jobs',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              _isHistoryView
                  ? 'Your finished jobs will appear here.'
                  : 'Accept a job from the Home screen to get started.',
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
                    blurRadius: 4, offset: const Offset(0, 1))]
                : [],
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: active ? Colors.black87 : Colors.grey[600],
                )),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _isHistoryView ? _completedJobs : _activeJobs;
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5F1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Repair List',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
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
                }),
                _buildTab('History', _isHistoryView, () {
                  setState(() => _isHistoryView = true);
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (jobs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                '${jobs.length} job${jobs.length == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
          Expanded(
            child: jobs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                    itemCount: jobs.length,
                    itemBuilder: (_, i) => _buildJobCard(jobs[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
