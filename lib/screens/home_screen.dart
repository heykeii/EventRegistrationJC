import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/user_avatar.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import '../services/auth_service.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const EventsScreen(),
    const ServicesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF8B7355),
          unselectedItemColor: const Color(0xFFB8A082),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_rounded),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_rounded),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Juan Carlo Brand Colors
  static const Color _primaryBeige = Color(0xFFE8DDD4);
  static const Color _secondaryBeige = Color(0xFFF4F0EC);
  static const Color _darkBeige = Color(0xFFD4C4B0);
  static const Color _lightBrown = Color(0xFFB8A082);
  static const Color _mediumBrown = Color(0xFF8B7355);
  static const Color _darkBrown = Color(0xFF6B5B47);
  static const Color _accentBrown = Color(0xFF9B8066);
  static const Color _goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _secondaryBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCustomAppBar(),
              _buildHeroSection(),
              _buildAboutSection(),
              _buildCallToAction(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: _mediumBrown,
        unselectedItemColor: _lightBrown,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_rounded),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_rounded),
            label: 'Logout',
          ),
        ],
        onTap: (index) async {
          if (index == 0) {
            Navigator.pushNamed(context, '/event-list');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/profile');
          } else if (index == 2) {
            await AuthService().signOut();
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [_mediumBrown, _goldAccent],
            ).createShader(bounds),
            child: const Text(
              'Juan Carlo',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _darkBrown,
            _mediumBrown,
            _lightBrown,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _mediumBrown.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _goldAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _goldAccent.withOpacity(0.3)),
            ),
            child: Text(
              'Premier Catering Services',
              style: TextStyle(
                color: _goldAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Crafting Unforgettable\nCelebrations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'From intimate gatherings to grand celebrations,\nwe transform your dreams into reality.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _mediumBrown.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Juan Carlo',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _darkBrown,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Juan Carlo is the premier catering and events specialist in the Philippines, trusted by celebrities and top companies. We craft unforgettable celebrations with world-class cuisine, elegant styling, and seamless service.',
            style: TextStyle(
              fontSize: 15,
              color: _mediumBrown,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToAction() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _goldAccent,
            _mediumBrown,
            _darkBrown,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _mediumBrown.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Ready to Create Magic?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Let us transform your special occasion into an unforgettable celebration with our signature catering services.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/event-list');
              },
              icon: Icon(Icons.event_available_rounded, color: _mediumBrown),
              label: Text(
                'Book Now',
                style: TextStyle(
                  color: _mediumBrown,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Additional Screens for Navigation
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  static const Color _secondaryBeige = Color(0xFFF4F0EC);
  static const Color _darkBrown = Color(0xFF6B5B47);
  static const Color _mediumBrown = Color(0xFF8B7355);
  static const Color _lightBrown = Color(0xFFB8A082);
  static const Color _goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final events = [
      {
        'title': 'Wedding of Mark & Anna',
        'date': 'June 15, 2024',
        'location': 'Tagaytay Highlands',
        'status': 'Upcoming',
      },
      {
        'title': 'Corporate Gala Night',
        'date': 'July 2, 2024',
        'location': 'Grand Ballroom, Makati',
        'status': 'Upcoming',
      },
      {
        'title': 'Birthday Bash: Sophia',
        'date': 'May 28, 2024',
        'location': 'Private Residence',
        'status': 'Completed',
      },
    ];
    return Scaffold(
      backgroundColor: _secondaryBeige,
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: _secondaryBeige,
        elevation: 0,
        foregroundColor: _darkBrown,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Events',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _darkBrown,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A showcase of your upcoming and past celebrations.',
              style: TextStyle(
                fontSize: 16,
                color: _mediumBrown,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: Text(
                        'No events yet. Book your first celebration!',
                        style: TextStyle(
                          color: _lightBrown,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 18),
                      itemBuilder: (context, i) {
                        final event = events[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: _mediumBrown.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: _goldAccent.withOpacity(0.15),
                              child: Icon(
                                event['status'] == 'Upcoming' ? Icons.event_available_rounded : Icons.celebration_rounded,
                                color: event['status'] == 'Upcoming' ? _goldAccent : _mediumBrown,
                                size: 28,
                              ),
                            ),
                            title: Text(
                              event['title']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: _darkBrown,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, size: 16, color: _mediumBrown),
                                    const SizedBox(width: 6),
                                    Text(event['date']!, style: TextStyle(color: _mediumBrown, fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_rounded, size: 16, color: _mediumBrown),
                                    const SizedBox(width: 6),
                                    Text(event['location']!, style: TextStyle(color: _mediumBrown, fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: event['status'] == 'Upcoming' ? _goldAccent.withOpacity(0.15) : _lightBrown.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                event['status']!,
                                style: TextStyle(
                                  color: event['status'] == 'Upcoming' ? _goldAccent : _mediumBrown,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.add_rounded, color: _mediumBrown),
                label: Text(
                  'Book New Event',
                  style: TextStyle(
                    color: _mediumBrown,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0EC),
      appBar: AppBar(
        title: const Text('Services'),
        backgroundColor: const Color(0xFFF4F0EC),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Services Screen\nComing Soon!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF6B5B47),
          ),
        ),
      ),
    );
  }
}

// Custom Pattern Painter for Decorative Backgrounds
class PatternPainter extends CustomPainter {
  final Color? color;

  PatternPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Create a decorative dot pattern
    const spacing = 30.0;
    const dotSize = 2.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Original ProfileScreen (Unchanged)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderOptions = const ['Male', 'Female', 'Other'];
  String? _selectedGender;
  String? _avatarUrl;
  XFile? _pickedImage;
  bool _loading = false;
  bool _editing = false;
  UserModel? _user;
  late AnimationController _animationController;
  late AnimationController _avatarController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Modern Color Palette
  static const Color _primaryBeige = Color(0xFFE8DDD4);
  static const Color _secondaryBeige = Color(0xFFF4F0EC);
  static const Color _darkBeige = Color(0xFFD4C4B0);
  static const Color _lightBrown = Color(0xFFB8A082);
  static const Color _mediumBrown = Color(0xFF8B7355);
  static const Color _darkBrown = Color(0xFF6B5B47);
  static const Color _accentBrown = Color(0xFF9B8066);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _loadUser();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = AuthService().currentUser;
    if (user == null) return;
    final userModel = await UserService().getUser(user.uid);
    if (userModel != null) {
      setState(() {
        _user = userModel;
        _nameController.text = userModel.name;
        _emailController.text = userModel.email;
        _phoneController.text = userModel.phone ?? '';
        _addressController.text = userModel.address ?? '';
        _ageController.text = userModel.age?.toString() ?? '';
        _avatarUrl = userModel.toMap()['avatarUrl'] ?? null;
        _selectedGender = userModel.gender;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    
    final user = AuthService().currentUser;
    if (user == null) return;
    
    final updatedUser = UserModel(
      uid: user.uid,
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _user?.password ?? '',
      createdAt: _user?.createdAt,
      address: _addressController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      gender: _selectedGender,
    );
    
    await UserService().updateUser(updatedUser);
    
    setState(() {
      _loading = false;
      _editing = false;
    });
    
    HapticFeedback.mediumImpact();
    _showSuccessSnackBar();
    _loadUser();
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Profile updated successfully!',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: _mediumBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        elevation: 8,
      ),
    );
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
    int animationDelay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + animationDelay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
                enabled: enabled && _editing,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _darkBrown,
                ),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    color: _editing ? _mediumBrown : _lightBrown,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(left: 16, right: 12),
                    child: Icon(
                      icon,
                      color: _editing ? _mediumBrown : _lightBrown,
                      size: 22,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 50),
                  filled: true,
                  fillColor: _editing ? Colors.white : _secondaryBeige,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: _darkBeige,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: _mediumBrown,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xFFD32F2F),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required IconData icon,
    required List<String> options,
    String? value,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
    int animationDelay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + animationDelay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animValue)),
          child: Opacity(
            opacity: animValue,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: DropdownButtonFormField<String>(
                value: value,
                validator: validator,
                items: options
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(
                            option,
                            style: TextStyle(
                              color: _darkBrown,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: _editing ? onChanged : null,
                style: TextStyle(
                  fontSize: 16,
                  color: _darkBrown,
                ),
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    color: _editing ? _mediumBrown : _lightBrown,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(left: 16, right: 12),
                    child: Icon(
                      icon,
                      color: _editing ? _mediumBrown : _lightBrown,
                      size: 22,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 50),
                  filled: true,
                  fillColor: _editing ? Colors.white : _secondaryBeige,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: _darkBeige,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: _mediumBrown,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: _editing ? _pickImage : null,
              onTapDown: (_) => _avatarController.forward(),
              onTapUp: (_) => _avatarController.reverse(),
              onTapCancel: () => _avatarController.reverse(),
              child: AnimatedBuilder(
                animation: _avatarController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 - (_avatarController.value * 0.05),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _lightBrown,
                            _mediumBrown,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _mediumBrown.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                              ? Image.network(
                                  _avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildDefaultAvatar(),
                                )
                              : _buildDefaultAvatar(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryBeige,
            _darkBeige,
          ],
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        size: 60,
        color: _mediumBrown,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}