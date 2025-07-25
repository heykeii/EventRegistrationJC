import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/user_avatar.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../models/event_model.dart';

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
    debugPrint('[ProfileScreen] AuthService.currentUser: ' + (user?.uid ?? 'null'));
    if (user == null) return;
    final userModel = await UserService().getUser(user.uid);
    debugPrint('[ProfileScreen] UserService.getUser: ' + (userModel?.toMap().toString() ?? 'null'));
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
      avatarUrl: _avatarUrl,
    );
    
    await UserService().updateUser(updatedUser);
    AuthService().currentUser = updatedUser;
    
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
    final loggedInUser = AuthService().currentUser;
    debugPrint('[ProfileScreen] build: loggedInUser=' + (loggedInUser?.uid ?? 'null') + ', _user=' + (_user?.uid ?? 'null'));
    
    return Scaffold(
      backgroundColor: _secondaryBeige,
      body: SafeArea(
        child: loggedInUser == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: _mediumBrown.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person_off_rounded,
                        size: 64,
                        color: _mediumBrown,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _darkBrown,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please sign in to access your profile',
                      style: TextStyle(
                        fontSize: 16,
                        color: _mediumBrown,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          colors: [_lightBrown, _mediumBrown],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _mediumBrown.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : _user == null
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_mediumBrown),
                      strokeWidth: 3,
                    ),
                  )
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: Transform.translate(
                                offset: Offset(0, _slideAnimation.value),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 40),
                                    // Profile Avatar
                                    Stack(
                                      children: [
                                        _buildProfileAvatar(),
                                        if (_editing)
                                          Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: _mediumBrown,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _mediumBrown.withOpacity(0.3),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.camera_alt_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // User Name
                                    Text(
                                      _user?.name ?? 'Unknown User',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: _darkBrown,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // User Email
                                    Text(
                                      _user?.email ?? 'No email provided',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _mediumBrown,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: _mediumBrown.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _darkBrown,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildModernTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                                  animationDelay: 0,
                                ),
                                _buildModernTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => v == null || v.isEmpty ? 'Email is required' : null,
                                  enabled: false,
                                  animationDelay: 100,
                                ),
                                _buildModernDropdown(
                                  label: 'Gender',
                                  icon: Icons.wc_outlined,
                                  options: _genderOptions,
                                  value: _selectedGender,
                                  onChanged: (value) => setState(() => _selectedGender = value),
                                  validator: (v) => v == null || v.isEmpty ? 'Please select gender' : null,
                                  animationDelay: 200,
                                ),
                                _buildModernTextField(
                                  controller: _phoneController,
                                  label: 'Phone Number',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  animationDelay: 300,
                                ),
                                _buildModernTextField(
                                  controller: _ageController,
                                  label: 'Age',
                                  icon: Icons.cake_outlined,
                                  keyboardType: TextInputType.number,
                                  animationDelay: 400,
                                ),
                                _buildModernTextField(
                                  controller: _addressController,
                                  label: 'Address',
                                  icon: Icons.location_on_outlined,
                                  animationDelay: 500,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                colors: _editing 
                                    ? [_lightBrown, _mediumBrown]
                                    : [_accentBrown, _mediumBrown],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _mediumBrown.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _editing
                                  ? (_loading ? null : _saveProfile)
                                  : () {
                                      HapticFeedback.lightImpact();
                                      setState(() => _editing = true);
                                    },
                              icon: _loading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      _editing ? Icons.save_rounded : Icons.edit_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                              label: Text(
                                _editing ? 'Save Changes' : 'Edit Profile',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 20),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _JoinedEventsList extends StatelessWidget {
  final List<String> joinedEventIds;
  const _JoinedEventsList({required this.joinedEventIds});

  static const Color _mediumBrown = Color(0xFF8B7355);

  @override
  Widget build(BuildContext context) {
    final eventService = EventService();
    return StreamBuilder<List<EventModel>>(
      stream: eventService.getEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final allEvents = snapshot.data ?? [];
        final joinedEvents = allEvents.where((e) => joinedEventIds.contains(e.id)).toList();
        if (joinedEvents.isEmpty) {
          return Text('You have not joined any events yet.', style: TextStyle(color: _mediumBrown));
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: joinedEvents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final event = joinedEvents[i];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: ListTile(
                title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14),
                        const SizedBox(width: 4),
                        Text('${event.date.toLocal().toString().split(' ')[0]}'),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on_rounded, size: 14),
                        const SizedBox(width: 4),
                        Text(event.location),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class AdminUserProfileScreen extends StatefulWidget {
  final String userId;
  const AdminUserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AdminUserProfileScreen> createState() => _AdminUserProfileScreenState();
}

class _AdminUserProfileScreenState extends State<AdminUserProfileScreen> with TickerProviderStateMixin {
  UserModel? _user;
  bool _loading = true;
  late AnimationController _animationController;
  late AnimationController _avatarController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Modern Color Palette (reuse from ProfileScreen)
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
    final userModel = await UserService().getUser(widget.userId);
    if (userModel != null) {
      setState(() {
        _user = userModel;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _secondaryBeige,
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: _mediumBrown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _user == null
                ? Center(child: Text('User not found'))
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: Transform.translate(
                                offset: Offset(0, _slideAnimation.value),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 40),
                                    // Profile Avatar
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 48,
                                          backgroundColor: _mediumBrown,
                                          child: Text(
                                            _user!.name.isNotEmpty ? _user!.name[0] : _user!.email[0],
                                            style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // User Name
                                    Text(
                                      _user?.name ?? 'Unknown User',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: _darkBrown,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // User Email
                                    Text(
                                      _user?.email ?? 'No email provided',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _mediumBrown,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: _mediumBrown.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _darkBrown,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildReadOnlyField('Full Name', _user?.name ?? ''),
                                _buildReadOnlyField('Email Address', _user?.email ?? ''),
                                _buildReadOnlyField('Gender', _user?.gender ?? ''),
                                _buildReadOnlyField('Phone Number', _user?.phone ?? ''),
                                _buildReadOnlyField('Age', _user?.age?.toString() ?? ''),
                                _buildReadOnlyField('Address', _user?.address ?? ''),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: _mediumBrown.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Joined Events',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _darkBrown,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _user!.joinedEventIds.isEmpty
                                  ? Text('No joined events.', style: TextStyle(color: _mediumBrown))
                                  : _JoinedEventsList(joinedEventIds: _user!.joinedEventIds),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 20),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _mediumBrown,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: _secondaryBeige,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value.isNotEmpty ? value : '-',
              style: TextStyle(
                color: _darkBrown,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}