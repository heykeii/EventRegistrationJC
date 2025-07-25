import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/user_service.dart';
import 'admin_event_list_screen.dart';
import '../../services/auth_service.dart';
import 'admin_user_list_screen.dart';
import '../event/event_create_screen.dart';
import 'admin_analytics_screen.dart';

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
                      icon: Icons.settings,
                      selected: _selectedIndex == 3,
                      onTap: () => setState(() => _selectedIndex = 3),
                      tooltip: 'Settings',
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
                        Center(child: Text('Settings Section Coming Soon', style: TextStyle(fontSize: 22, color: kMediumBrown))),
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