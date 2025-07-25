import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/event_service.dart';
import '../../services/user_service.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final EventService _eventService = EventService();
  final UserService _userService = UserService();
  List<EventModel> _events = [];
  List<UserModel> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final events = await _eventService.getEvents().first;
    final users = await _userService.getAllUsers();
    setState(() {
      _events = events;
      _users = users;
      _loading = false;
    });
  }

  int get totalEvents => _events.length;
  int get totalUsers => _users.length;
  int get upcomingEvents => _events.where((e) => e.date.isAfter(DateTime.now())).length;
  int get pastEvents => _events.where((e) => e.date.isBefore(DateTime.now())).length;
  int get avgParticipants {
    if (_events.isEmpty) return 0;
    int total = 0;
    for (final event in _events) {
      total += _users.where((u) => u.joinedEventIds.contains(event.id)).length;
    }
    return total ~/ _events.length;
  }
  int get newUsersThisMonth => _users.where((u) => u.createdAt != null && u.createdAt!.month == DateTime.now().month && u.createdAt!.year == DateTime.now().year).length;

  List<MapEntry<String, int>> get topLocations {
    final Map<String, int> locationCounts = {};
    for (final event in _events) {
      locationCounts[event.location] = (locationCounts[event.location] ?? 0) + 1;
    }
    final sorted = locationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  List<EventModel> get topEventsByParticipants {
    final eventCounts = <EventModel, int>{};
    for (final event in _events) {
      eventCounts[event] = _users.where((u) => u.joinedEventIds.contains(event.id)).length;
    }
    final sorted = eventCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) => e.key).toList();
  }

  List<UserModel> get topUsersByParticipation {
    final sorted = List<UserModel>.from(_users)
      ..sort((a, b) => (b.joinedEventIds.length).compareTo(a.joinedEventIds.length));
    return sorted.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Analytics Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats Cards
            _buildStatsGrid(context),
            const SizedBox(height: 32),
            
            // Charts Section
            _buildChartsSection(context),
            const SizedBox(height: 32),
            
            // Lists Section
            _buildListsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isMobile = screenWidth <= 600;
    
    final stats = [
      {'label': 'Total Events', 'value': totalEvents, 'icon': Icons.event, 'color': Colors.blue},
      {'label': 'Total Users', 'value': totalUsers, 'icon': Icons.people, 'color': Colors.green},
      {'label': 'Avg. Participants', 'value': avgParticipants, 'icon': Icons.group, 'color': Colors.orange},
      {'label': 'New Users', 'value': newUsersThisMonth, 'icon': Icons.person_add, 'color': Colors.purple},
    ];

    if (isMobile) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) => _statCard(
          stats[index]['label'] as String,
          stats[index]['value'] as int,
          stats[index]['icon'] as IconData,
          stats[index]['color'] as Color,
        ),
      );
    } else {
      return Row(
        children: stats.map((stat) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _statCard(
              stat['label'] as String,
              stat['value'] as int,
              stat['icon'] as IconData,
              stat['color'] as Color,
            ),
          ),
        )).toList(),
      );
    }
  }

  Widget _buildChartsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;

    if (isDesktop) {
      return Column(
        children: [
          // First row: Line chart and pie chart
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _chartCard(
                  'Events Over Time',
                  _eventsOverTimeChart(),
                  height: 300,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _chartCard(
                  'Upcoming vs Past Events',
                  _eventStatusPieChart(),
                  height: 300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Second row: Bar chart
          _chartCard(
            'Top Locations',
            _topLocationsBarChart(),
            height: 300,
          ),
        ],
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _chartCard(
                  'Events Over Time',
                  _eventsOverTimeChart(),
                  height: 250,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _chartCard(
                  'Upcoming vs Past Events',
                  _eventStatusPieChart(),
                  height: 250,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _chartCard(
            'Top Locations',
            _topLocationsBarChart(),
            height: 250,
          ),
        ],
      );
    } else {
      // Mobile layout - stack vertically
      return Column(
        children: [
          _chartCard(
            'Events Over Time',
            _eventsOverTimeChart(),
            height: 200,
          ),
          const SizedBox(height: 16),
          _chartCard(
            'Upcoming vs Past Events',
            _eventStatusPieChart(),
            height: 200,
          ),
          const SizedBox(height: 16),
          _chartCard(
            'Top Locations',
            _topLocationsBarChart(),
            height: 200,
          ),
        ],
      );
    }
  }

  Widget _buildListsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _listCard(
              'Top Events by Participants',
              _topEventsList(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _listCard(
              'Top Users by Participation',
              _topUsersList(),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _listCard(
            'Top Events by Participants',
            _topEventsList(),
          ),
          const SizedBox(height: 16),
          _listCard(
            'Top Users by Participation',
            _topUsersList(),
          ),
        ],
      );
    }
  }

  Widget _chartCard(String title, Widget chart, {double height = 250}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(height: height, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _listCard(String title, Widget content) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventsOverTimeChart() {
    // Group events by month
    final Map<String, int> eventsPerMonth = {};
    for (final event in _events) {
      final key = '${event.date.year}-${event.date.month.toString().padLeft(2, '0')}';
      eventsPerMonth[key] = (eventsPerMonth[key] ?? 0) + 1;
    }
    final sortedKeys = eventsPerMonth.keys.toList()..sort();
    
    if (sortedKeys.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= sortedKeys.length) return const SizedBox();
                  return Text(
                    sortedKeys[idx].substring(2),
                    style: const TextStyle(fontSize: 9),
                  );
                },
                interval: 1,
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          minX: 0,
          maxX: (sortedKeys.length - 1).toDouble(),
          minY: 0,
          maxY: (eventsPerMonth.values.isEmpty ? 1 : eventsPerMonth.values.reduce((a, b) => a > b ? a : b)).toDouble() + 1,
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (int i = 0; i < sortedKeys.length; i++)
                  FlSpot(i.toDouble(), eventsPerMonth[sortedKeys[i]]!.toDouble()),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventStatusPieChart() {
    final upcoming = upcomingEvents;
    final past = pastEvents;
    
    if (upcoming == 0 && past == 0) {
      return const Center(child: Text('No events data'));
    }
    
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: upcoming.toDouble(),
            color: Colors.green,
            title: 'Upcoming\n$upcoming',
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            radius: 80,
          ),
          PieChartSectionData(
            value: past.toDouble(),
            color: Colors.grey,
            title: 'Past\n$past',
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            radius: 80,
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _topLocationsBarChart() {
    final data = topLocations;
    
    if (data.isEmpty) {
      return const Center(child: Text('No location data'));
    }
    
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox();
                  return Text(
                    data[idx].key.length > 8 
                        ? '${data[idx].key.substring(0, 8)}...'
                        : data[idx].key,
                    style: const TextStyle(fontSize: 9),
                  );
                },
                interval: 1,
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          minY: 0,
          maxY: (data.isEmpty ? 1 : data.first.value).toDouble() + 1,
          barGroups: [
            for (int i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].value.toDouble(),
                    color: Colors.orange,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _topEventsList() {
    final events = topEventsByParticipants;
    
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No events data'),
      );
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final event = events[index];
        final participantCount = _users.where((u) => u.joinedEventIds.contains(event.id)).length;
        
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('$participantCount participants'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 12),
        );
      },
    );
  }

  Widget _topUsersList() {
    final users = topUsersByParticipation;
    
    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No users data'),
      );
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = users[index];
        
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.1),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('${user.joinedEventIds.length} events joined'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 12),
        );
      },
    );
  }
}