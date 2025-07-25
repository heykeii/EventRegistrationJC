import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/user_service.dart';
import 'admin_event_list_screen.dart';
import '../../services/auth_service.dart';
import 'admin_user_list_screen.dart';
import '../event/event_create_screen.dart';
import 'admin_analytics_screen.dart';
import '../../services/registration_service.dart';
import '../../models/registration_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Move brand colors to top-level so all widgets can access them
const Color kPrimaryBeige = Color(0xFFE8DDD4);
const Color kSecondaryBeige = Color(0xFFF4F0EC);
const Color kDarkBeige = Color(0xFFD4C4B0);
const Color kLightBrown = Color(0xFFB8A082);
const Color kMediumBrown = Color(0xFF8B7355);
const Color kDarkBrown = Color(0xFF6B5B47);
const Color kAccentBrown = Color(0xFF9B8066);
const Color kGoldAccent = Color(0xFFD4AF37);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final eventService = EventService();
  final userService = UserService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: kSecondaryBeige,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 80,
            decoration: BoxDecoration(
              color: kMediumBrown,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 32),
                    _SidebarIcon(
                      icon: Icons.event,
                      selected: _selectedIndex == 0,
                      onTap: () => setState(() => _selectedIndex = 0),
                      tooltip: 'Events',
                      selectedColor: kPrimaryBeige,
                      iconColor: kMediumBrown,
                    ),
                    const SizedBox(height: 16),
                    _SidebarIcon(
                      icon: Icons.people,
                      selected: _selectedIndex == 1,
                      onTap: () => setState(() => _selectedIndex = 1),
                      tooltip: 'Users',
                      selectedColor: kPrimaryBeige,
                      iconColor: kMediumBrown,
                    ),
                    const SizedBox(height: 16),
                    _SidebarIcon(
                      icon: Icons.analytics,
                      selected: _selectedIndex == 2,
                      onTap: () => setState(() => _selectedIndex = 2),
                      tooltip: 'Analytics',
                      selectedColor: kPrimaryBeige,
                      iconColor: kMediumBrown,
                    ),
                    const SizedBox(height: 16),
                    _SidebarIcon(
                      icon: Icons.restaurant,
                      selected: _selectedIndex == 3,
                      onTap: () => setState(() => _selectedIndex = 3),
                      tooltip: 'Catering Reservations',
                      selectedColor: kPrimaryBeige,
                      iconColor: kMediumBrown,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: kPrimaryBeige,
                        child: Icon(Icons.admin_panel_settings, color: kMediumBrown),
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        color: Colors.white,
                        tooltip: 'Logout',
                        onPressed: () async {
                          await AuthService().signOut();
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome, Admin', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kDarkBrown)),
                          const SizedBox(height: 4),
                          Text('Manage your events and users', style: TextStyle(fontSize: 16, color: kMediumBrown)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.brightness_6_rounded),
                            onPressed: () {},
                            tooltip: 'Toggle Dark Mode',
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: kPrimaryBeige,
                            child: Icon(Icons.account_circle, color: kMediumBrown, size: 32),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Summary Row
                  FutureBuilder<List<EventModel>>(
                    future: eventService.getEvents().first,
                    builder: (context, snapshot) {
                      final events = snapshot.data ?? [];
                      final totalEvents = events.length;
                      final upcoming = events.where((e) => e.date.isAfter(DateTime.now())).length;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _SummaryCard(
                              title: 'Total Events',
                              value: totalEvents.toString(),
                              icon: Icons.event,
                              color: kGoldAccent,
                            ),
                            const SizedBox(width: 20),
                            _SummaryCard(
                              title: 'Upcoming',
                              value: upcoming.toString(),
                              icon: Icons.upcoming_rounded,
                              color: kGoldAccent,
                            ),
                            const SizedBox(width: 20),
                            FutureBuilder<int>(
                              future: userService.getUserCount(),
                              builder: (context, userSnap) {
                                final users = userSnap.data ?? 0;
                                return _SummaryCard(
                                  title: 'Users',
                                  value: users.toString(),
                                  icon: Icons.people,
                                  color: kGoldAccent,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Main Content Switch
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: const [
                        AdminEventListScreen(),
                        AdminUserListScreen(),
                        AdminAnalyticsScreen(),
                        AdminCateringReservationsScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EventCreateScreen()),
                );
              },
              backgroundColor: kGoldAccent,
              child: const Icon(Icons.add, size: 32),
              tooltip: 'Add Event',
            )
          : null,
    );
  }
}

class _SidebarIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String tooltip;
  final Color selectedColor;
  final Color iconColor;
  const _SidebarIcon({required this.icon, required this.selected, required this.onTap, required this.tooltip, required this.selectedColor, required this.iconColor});
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: selected
              ? BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                )
              : null,
          child: Icon(icon, color: selected ? iconColor : Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    // Responsive width for summary cards
    double cardWidth = MediaQuery.of(context).size.width < 600 ? 130 : 160;
    return Container(
      width: cardWidth,
      height: 90,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kPrimaryBeige,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 2),
                Text(title, style: TextStyle(fontSize: 14, color: kMediumBrown), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminCateringReservationsScreen extends StatefulWidget {
  const AdminCateringReservationsScreen({Key? key}) : super(key: key);

  @override
  State<AdminCateringReservationsScreen> createState() => _AdminCateringReservationsScreenState();
}

class _AdminCateringReservationsScreenState extends State<AdminCateringReservationsScreen> {
  List<Map<String, dynamic>> _reservationDocs = [];
  bool _loading = true;
  String? _updatingId;

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'declined':
        return Colors.red;
      default:
        return kGoldAccent;
    }
  }

  Widget _buildReservationCard(Map<String, dynamic> r) {
    final dateVal = r['eventDate'];
    DateTime date;
    if (dateVal is Timestamp) {
      date = dateVal.toDate();
    } else if (dateVal is String) {
      date = DateTime.tryParse(dateVal) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }
    final isUpdating = _updatingId == r['id'];
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kMediumBrown.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kGoldAccent.withOpacity(0.13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.restaurant_menu, color: kGoldAccent, size: 28),
        ),
        title: Text(r['eventName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkBrown)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r['cateringServiceType'] ?? '', style: const TextStyle(color: kMediumBrown)),
            const SizedBox(height: 2),
            Text('${date.toLocal().toString().split(' ')[0]} at ${r['eventLocation'] ?? ''}', style: const TextStyle(color: kLightBrown)),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(r['status'] ?? 'pending').withOpacity(0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 10, color: _statusColor(r['status'] ?? 'pending')),
                      const SizedBox(width: 6),
                      Text(
                        (r['status'] ?? 'pending')[0].toUpperCase() + (r['status'] ?? 'pending').substring(1),
                        style: TextStyle(fontSize: 13, color: _statusColor(r['status'] ?? 'pending'), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                isUpdating
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : DropdownButton<String>(
                      value: r['status'] ?? 'pending',
                      items: const [
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'approved', child: Text('Approved')),
                        DropdownMenuItem(value: 'declined', child: Text('Declined')),
                      ],
                      onChanged: (val) {
                        if (val != null) _updateStatus(r['id'], val);
                      },
                      underline: const SizedBox(),
                      style: const TextStyle(fontWeight: FontWeight.w500, color: kDarkBrown),
                      dropdownColor: Colors.white,
                    ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, color: kMediumBrown, size: 20),
            Text(r['userId'] ?? '', style: const TextStyle(fontSize: 11, color: kLightBrown)),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    final query = await RegistrationService.db.collection('catering_reservations').get();
    setState(() {
      _reservationDocs = query.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      _loading = false;
    });
  }

  Future<void> _updateStatus(String docId, String status) async {
    setState(() { _updatingId = docId; });
    try {
      await RegistrationService().updateReservationStatus(docId, status);
      await _fetchReservations();
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to update status:\n\n${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    setState(() { _updatingId = null; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryBeige,
      appBar: AppBar(
        title: const Text('Catering Reservations', style: TextStyle(color: kDarkBrown)),
        backgroundColor: kPrimaryBeige,
        elevation: 0,
        iconTheme: const IconThemeData(color: kDarkBrown),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reservationDocs.isEmpty
              ? const Center(child: Text('No catering reservations found.', style: TextStyle(color: kMediumBrown)))
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text('All Catering Reservations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: kDarkBrown)),
                    ),
                    ..._reservationDocs.map(_buildReservationCard),
                  ],
                ),
    );
  }
} 