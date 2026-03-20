import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../requests_data/requests_database.dart';
import '../requests_data/request_model.dart';
import '../requests_data/messages_database.dart';
import '../users_data/user_model.dart';
import '../sign_in_page.dart';
import '../client_side/inbox_page.dart';
import 'WorkRequestDetailsPage.dart';
import 'worker_profile.dart';

class WorkerHomePage extends StatefulWidget {
  final User? user;

  const WorkerHomePage({Key? key, this.user}) : super(key: key);

  @override
  State<WorkerHomePage> createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends State<WorkerHomePage> {
  int _selectedIndex = 0;
  String _selectedTab = 'available';
  final Set<String> _myJobs = {};

  static const List<Map<String, String>> _serviceCategories = [
    {'label': 'Carpenter', 'image': 'assets/carpenter.jpg'},
    {'label': 'Welding', 'image': 'assets/welding.jpg'},
    {'label': 'Plumber', 'image': 'assets/plumber.jpg'},
    {'label': 'Electrician', 'image': 'assets/electrician.jpg'},
    {'label': 'Aircon Tech', 'image': 'assets/aircontech.jpg'},
    {'label': 'Care Giver', 'image': 'assets/caregiver.jpg'},
    {'label': 'Appliance Repair', 'image': 'assets/applianceman.jpg'},
    {'label': 'Roof Repair', 'image': 'assets/roofrepair.jpg'},
  ];

  int get _unreadCount {
    if (widget.user == null) return 0;
    return MessagesDatabase.totalUnreadFor(widget.user!.id);
  }

  List<Request> get _availableJobs => RequestsDatabase.getAllRequests()
      .where((r) => r.status == 'pending' && !_myJobs.contains(r.id))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Request> get _workerJobs => RequestsDatabase.getAllRequests()
      .where((r) => r.status == 'in_progress' && _myJobs.contains(r.id))
      .toList();

  void _offerSubmission(Request request) {
    final updated = request.copyWith(status: 'in_progress');
    RequestsDatabase.updateRequest(updated);
    setState(() => _myJobs.add(request.id));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Offer submitted for "${request.title}"!'),
      backgroundColor: const Color(0xFF2D7A5E),
    ));
  }

  void _onNavItemTapped(int index) async {
    if (index == 0) { setState(() => _selectedIndex = 0); return; }
    switch (index) {
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Repair List coming soon!'),
          backgroundColor: Color(0xFF2D7A5E),
          duration: Duration(seconds: 1),
        ));
        break;
      case 2:
        if (widget.user != null) {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => InboxPage(user: widget.user!)));
          setState(() {}); // refresh unread badge
        }
        break;
      case 3:
        if (widget.user != null) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => WorkerProfilePage(user: widget.user!)));
        }
        break;
    }
    setState(() => _selectedIndex = 0);
  }

  Widget _imageContent(String path) {
    if (kIsWeb) {
      return Image.network(path, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder());
    }
    return Image.file(File(path), fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder());
  }

  Widget _placeholder() => Container(
        color: Colors.grey[300],
        child: Center(child: Icon(Icons.image, size: 40, color: Colors.grey[500])),
      );

  String _dateStr(DateTime dt) {
    const m = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[dt.month]} ${dt.day}';
  }

  String _timeStr(DateTime dt) {
    if (dt.hour < 12) return 'Morning';
    if (dt.hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _helloCard() => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8F5F1),
                border: Border.all(color: const Color(0xFF2D7A5E), width: 2),
              ),
              child: const Icon(Icons.person, size: 26, color: Color(0xFF2D7A5E)),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Welcome!',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 2),
              Text('Here are the available jobs for you.',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
          ]),
        ),
      );

  Widget _categoriesRow() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Service Categories',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _serviceCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final cat = _serviceCategories[i];
                return SizedBox(
                  width: 130,
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 105,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.asset(cat['image']!, fit: BoxFit.cover),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.white,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(cat['label']!,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );

  Widget _jobCard(Request request, {bool isMyJob = false}) {
    final hasImage = request.imagePaths.isNotEmpty;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => WorkRequestDetailsPage(
              request: request,
              worker: widget.user,
              onAccept: () => setState(() => _myJobs.add(request.id)),
            ),
          ));
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: double.infinity, height: 140,
            child: hasImage
                ? _imageContent(request.imagePaths[0])
                : Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.construction, size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 6),
                        Text(request.type,
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ]),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(request.title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(request.userCity ?? 'Nearby',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                Text('PHP ${request.budget}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(_dateStr(request.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                Text(_timeStr(request.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              ]),
              const SizedBox(height: 10),
              Center(
                child: isMyJob
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Text('Job Accepted',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700])),
                      )
                    : GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _offerSubmission(request),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 8),
                          decoration: BoxDecoration(
                              color: const Color(0xFF2D7A5E),
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text('Submit Offer',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _emptyState(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(msg,
                style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                textAlign: TextAlign.center),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final jobs = _selectedTab == 'available' ? _availableJobs : _workerJobs;
    final unread = _unreadCount;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5F1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const SignInPage()),
              (route) => false),
        ),
        title: const Text('Home Page',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const SignInPage()),
                  (route) => false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Logout', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 12),
                _helloCard(),
                const SizedBox(height: 16),
                _categoriesRow(),
                const SizedBox(height: 16),

                // Tab switcher
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 'available'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 'available'
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTab == 'available'
                                ? [BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1))]
                                : [],
                          ),
                          child: Center(
                            child: Text('Available',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedTab == 'available'
                                        ? Colors.black
                                        : Colors.grey[600])),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 'myjobs'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 'myjobs'
                                ? const Color(0xFF3A3A3A)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text('My Jobs',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedTab == 'myjobs'
                                        ? Colors.white
                                        : Colors.grey[600])),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 16),
                if (jobs.isEmpty)
                  _emptyState(_selectedTab == 'available'
                      ? 'No available jobs right now.\nCheck back when clients post requests.'
                      : "You haven't taken any jobs yet.")
                else
                  ...jobs.map((r) => _jobCard(r, isMyJob: _selectedTab == 'myjobs')),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ),
      ]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2D7A5E),
          boxShadow: [BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
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
            const BottomNavigationBarItem(
                icon: Icon(Icons.assignment), label: 'Requests'),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text('$unread'),
                isLabelVisible: unread > 0,
                backgroundColor: Colors.red,
                child: const Icon(Icons.inbox),
              ),
              label: 'Inbox',
            ),
            const BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
