import 'package:flutter/material.dart';
import '../../widgets/event_card.dart';
import '../../services/event_service.dart';
import '../../models/event_model.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/user_avatar.dart';

// Juan Carlo Brand Colors
const Color _primaryBeige = Color(0xFFE8DDD4);
const Color _secondaryBeige = Color(0xFFF4F0EC);
const Color _darkBeige = Color(0xFFD4C4B0);
const Color _lightBrown = Color(0xFFB8A082);
const Color _mediumBrown = Color(0xFF8B7355);
const Color _darkBrown = Color(0xFF6B5B47);
const Color _accentBrown = Color(0xFF9B8066);
const Color _goldAccent = Color(0xFFD4AF37);

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final EventService eventService = EventService();
  final UserService userService = UserService();
  final AuthService authService = AuthService();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = authService.currentUser;
    return Scaffold(
      backgroundColor: _secondaryBeige,
      appBar: AppBar(
        title: const Text(
          'Discover Events',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: _darkBrown,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: _darkBrown),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.tune_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _mediumBrown,
                elevation: 2,
                shadowColor: Colors.black12,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search events by title or location...',
                prefixIcon: const Icon(Icons.search, color: _mediumBrown),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                hintStyle: const TextStyle(color: _lightBrown),
              ),
              style: const TextStyle(color: _darkBrown),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<EventModel>>(
              stream: eventService.getEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading events...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error:  ${snapshot.error}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                final events = (snapshot.data ?? []).where((event) {
                  return event.title.toLowerCase().contains(searchQuery) ||
                      event.location.toLowerCase().contains(searchQuery);
                }).toList();
                if (events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: _primaryBeige,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.event_busy_rounded,
                            size: 64,
                            color: _lightBrown.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No events found',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _darkBrown,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or check back later.',
                          style: TextStyle(
                            color: _mediumBrown,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return _EventListWithJoin(
                  events: events,
                  currentUser: currentUser,
                  userService: userService,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Modern event card list with join button and organizer info
class _EventListWithJoin extends StatefulWidget {
  final List<EventModel> events;
  final dynamic currentUser;
  final UserService userService;
  const _EventListWithJoin({required this.events, required this.currentUser, required this.userService});

  @override
  State<_EventListWithJoin> createState() => _EventListWithJoinState();
}

class _EventListWithJoinState extends State<_EventListWithJoin> {
  late List<String> joinedEventIds;
  bool joining = false;

  @override
  void initState() {
    super.initState();
    joinedEventIds = List<String>.from(widget.currentUser?.joinedEventIds ?? []);
  }

  void _handleJoin(String eventId) async {
    setState(() {
      joining = true;
    });
    try {
      await widget.userService.joinEvent(widget.currentUser.uid, eventId);
      setState(() {
        joinedEventIds.add(eventId);
        joining = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Joined event!'),
          backgroundColor: const Color(0xFF10B981),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() {
        joining = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.events.length,
      itemBuilder: (context, i) {
        final event = widget.events[i];
        final alreadyJoined = joinedEventIds.contains(event.id);
        final spotsLeft = event.capacity;
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Card(
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: _primaryBeige,
                width: 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.pushNamed(context, '/event-detail', arguments: event);
              },
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UserAvatar(name: 'Organizer'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: _darkBrown,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 16, color: _goldAccent),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${event.date.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _goldAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.location_on_rounded, size: 16, color: _mediumBrown),
                                  const SizedBox(width: 6),
                                  Text(
                                    event.location,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _mediumBrown,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (alreadyJoined)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: _goldAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event.description.length > 120
                          ? event.description.substring(0, 120) + '...'
                          : event.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: _lightBrown,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _goldAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.people_alt_rounded, size: 16, color: _goldAccent),
                              const SizedBox(width: 4),
                              Text(
                                'Spots left: $spotsLeft',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _goldAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _mediumBrown.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: _mediumBrown),
                              const SizedBox(width: 4),
                              Text(
                                'Organizer',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _mediumBrown,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: alreadyJoined || joining
                                  ? null
                                  : () => _handleJoin(event.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: alreadyJoined
                                    ? _goldAccent
                                    : _mediumBrown,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                disabledBackgroundColor: _primaryBeige,
                                disabledForegroundColor: _lightBrown,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    alreadyJoined
                                        ? Icons.check_circle_rounded
                                        : Icons.add_rounded,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    alreadyJoined
                                        ? 'Joined'
                                        : joining
                                            ? 'Joining...'
                                            : 'Join Event',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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