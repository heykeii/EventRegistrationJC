import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../services/event_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/event/event_create_screen.dart';
import '../../services/user_service.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  const StatusChip({required this.status, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            status == 'Past'
                ? Icons.history_rounded
                : status == 'Today'
                    ? Icons.today_rounded
                    : status == 'Upcoming'
                        ? Icons.upcoming_rounded
                        : Icons.calendar_month_rounded,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class AdminEventListScreen extends StatelessWidget {
  const AdminEventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventService = EventService();
    return StreamBuilder<List<EventModel>>(
      stream: eventService.getEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4F8EFF)),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                const SizedBox(height: 24),
                Text('Oops! Something went wrong', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red[400])),
                const SizedBox(height: 12),
                Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.grey[600], fontSize: 15), textAlign: TextAlign.center),
              ],
            ),
          );
        }
        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note, size: 100, color: Color(0xFF4F8EFF).withOpacity(0.15)),
                const SizedBox(height: 32),
                Text('No events yet', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4F8EFF))),
                const SizedBox(height: 16),
                Text('Create your first event to get started', style: TextStyle(fontSize: 18, color: Colors.grey[500])),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Animate(
              effects: [FadeEffect(duration: 400.ms), SlideEffect(duration: 400.ms, begin: Offset(0, 0.1))],
              child: _buildEventCard(context, event),
            );
          },
        );
      },
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    return FutureBuilder<List<UserModel>>(
      future: UserService().getUsersByJoinedEvent(event.id),
      builder: (context, snapshot) {
        final joinedCount = snapshot.hasData ? snapshot.data!.length : null;
        return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.85), Colors.blue[50]!.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.blue[100]!, width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Cover Image or Placeholder
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: Colors.blue[100],
                    width: 72,
                    height: 72,
                    child: Icon(Icons.event, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 24),
                // Event Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(formatEventDate(event.date), style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StatusChip(status: getEventStatus(event.date), color: getEventStatusColor(event.date)),
                          const SizedBox(width: 12),
                          Icon(Icons.people, size: 16, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          FutureBuilder<List<UserModel>>(
                            future: UserService().getUsersByJoinedEvent(event.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.grey)));
                              }
                              final joinedCount = snapshot.data?.length ?? 0;
                              return Text('$joinedCount joined', style: TextStyle(color: Colors.grey[500], fontSize: 14));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventCreateScreen(event: event),
                          ),
                        );
                      },
                      tooltip: 'Edit event',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Event'),
                            content: const Text('Are you sure you want to delete this event?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final eventService = EventService();
                          await eventService.deleteEvent(event.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Event deleted')),
                          );
                        }
                      },
                      tooltip: 'Delete event',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}

String formatEventDate(DateTime date) {
  final now = DateTime.now();
  final difference = date.difference(now).inDays;
  if (difference == 0) {
    return 'Today at ${formatTime(date)}';
  } else if (difference == 1) {
    return 'Tomorrow at ${formatTime(date)}';
  } else if (difference == -1) {
    return 'Yesterday at ${formatTime(date)}';
  } else if (difference > 1 && difference <= 7) {
    return 'In $difference days';
  } else if (difference < -1 && difference >= -7) {
    return '${difference.abs()} days ago';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}

String formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String getEventStatus(DateTime date) {
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

Color getEventStatusColor(DateTime date) {
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