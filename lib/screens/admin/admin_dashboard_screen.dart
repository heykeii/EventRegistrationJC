import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../event/event_create_screen.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventService = EventService();
    final userService = UserService();
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, Colors.brown.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your platform stats and manage events',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _DashboardStat(
                      label: 'Total Users',
                      future: userService.getUserCount(),
                      icon: Icons.people,
                      color: Colors.blueAccent,
                    ),
                    _DashboardStat(
                      label: 'Total Events',
                      future: eventService.getEventCount(),
                      icon: Icons.event,
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: const [
                Icon(Icons.list_alt_rounded, color: Color(0xFF8B7355)),
                SizedBox(width: 8),
                Text(
                  'Event Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B5B47),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: StreamBuilder<List<EventModel>>(
                stream: eventService.getEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: \\${snapshot.error}'));
                  }
                  final events = snapshot.data ?? [];
                  if (events.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_note, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 24),
                          const Text('No events yet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          const Text('Create your first event to get started', style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const EventCreateScreen()),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Create Event'),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {},
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return _buildEventCard(context, event, eventService);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventCreateScreen()),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Event'),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event, EventService eventService) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.event, color: theme.colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(event.date.toLocal().toString(), style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.people_alt_rounded),
                    tooltip: 'View Joined Users',
                    onPressed: () async {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        isScrollControlled: true,
                        builder: (context) => _JoinedUsersSheet(eventId: event.id),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getEventStatusColor(event.date).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getEventStatus(event.date),
                      style: TextStyle(
                        color: _getEventStatusColor(event.date),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EventCreateScreen(event: event)),
                          );
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          foregroundColor: Colors.blue,
                        ),
                        tooltip: 'Edit event',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _showDeleteConfirmation(context, event, eventService),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          foregroundColor: Colors.red,
                        ),
                        tooltip: 'Delete event',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEventStatus(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    if (difference < 0) {
      return 'Past';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference <= 7) {
      return 'Upcoming';
    } else {
      return 'Future';
    }
  }

  Color _getEventStatusColor(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    if (difference < 0) {
      return Colors.grey;
    } else if (difference == 0) {
      return Colors.orange;
    } else if (difference <= 7) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  void _showDeleteConfirmation(BuildContext context, EventModel event, EventService eventService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Event'),
          content: Text('Are you sure you want to delete "${event.title}"? This action cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await eventService.deleteEvent(event.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Event "${event.title}" deleted'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardStat extends StatelessWidget {
  final String label;
  final Future<int> future;
  final IconData icon;
  final Color color;
  const _DashboardStat({required this.label, required this.future, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            FutureBuilder<int>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2));
                }
                return Text(
                  snapshot.data?.toString() ?? '-',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _JoinedUsersSheet extends StatelessWidget {
  final String eventId;
  const _JoinedUsersSheet({required this.eventId});
  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    return FutureBuilder<List<UserModel>>(
      future: userService.getUsersByJoinedEvent(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[800])),
                const SizedBox(height: 8),
                Text('Error: \\${snapshot.error}', style: TextStyle(color: Colors.grey[600], fontSize: 14), textAlign: TextAlign.center),
              ],
            ),
          );
        }
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_alt_rounded, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 24),
                 Text('No users have joined this event yet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Text(user.name.isNotEmpty ? user.name[0] : user.email[0], style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
            );
          },
        );
      },
    );
  }
} 