import 'package:flutter/material.dart';
import '../models/registration_model.dart';
import '../services/registration_service.dart';
import '../services/auth_service.dart';

// Brand Colors
const Color kPrimaryBeige = Color(0xFFE8DDD4);
const Color kSecondaryBeige = Color(0xFFF4F0EC);
const Color kDarkBeige = Color(0xFFD4C4B0);
const Color kLightBrown = Color(0xFFB8A082);
const Color kMediumBrown = Color(0xFF8B7355);
const Color kDarkBrown = Color(0xFF6B5B47);
const Color kAccentBrown = Color(0xFF9B8066);
const Color kGoldAccent = Color(0xFFD4AF37);

class CateringScreen extends StatefulWidget {
  const CateringScreen({Key? key}) : super(key: key);

  @override
  State<CateringScreen> createState() => _CateringScreenState();
}

class _CateringScreenState extends State<CateringScreen> {
  final List<Map<String, String>> cateringOptions = [
    {
      'title': 'Signature Plated Menus',
      'desc': 'Individual plated meals ideal for weddings or formal events',
    },
    {
      'title': 'American Plated Style',
      'desc': 'Efficient served meals with generous portions and chef-curated presentation',
    },
    {
      'title': 'Buffet Spread',
      'desc': 'A diverse buffet selection to cater to different tastes and event sizes',
    },
    {
      'title': 'Food Stations',
      'desc': 'Themed interactive food zones (e.g., live cooking stations) for dynamic guest engagement',
    },
    {
      'title': 'Packed Meals',
      'desc': 'Individual boxed meals suited for corporate events, seminars, or health-compliant gatherings',
    },
    {
      'title': 'Tasting Sessions',
      'desc': 'Pre-event food tasting where clients can sample signature dishes and refine their menu choices.',
    },
  ];

  List<RegistrationModel> _userReservations = [];
  bool _loadingReservations = true;

  @override
  void initState() {
    super.initState();
    _fetchUserReservations();
  }

  Future<void> _fetchUserReservations() async {
    final user = AuthService().currentUser;
    if (user != null) {
      final reservations = await RegistrationService().getUserCateringReservations(user.uid);
      setState(() {
        _userReservations = reservations;
        _loadingReservations = false;
      });
    } else {
      setState(() {
        _userReservations = [];
        _loadingReservations = false;
      });
    }
  }

  void _showReservationForm(String cateringType) {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final dateController = TextEditingController();
    final locationController = TextEditingController();
    DateTime? selectedDate;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: kSecondaryBeige,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.restaurant_menu, color: kGoldAccent, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('Reserve $cateringType', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kDarkBrown)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Event Name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Please enter event name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Event Date',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          suffixIcon: const Icon(Icons.calendar_today_rounded, color: kMediumBrown),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            selectedDate = picked;
                            dateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}' ;
                          }
                        },
                        validator: (v) => v == null || v.isEmpty ? 'Please select a date' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: 'Event Location',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Please enter location' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGoldAccent,
                            foregroundColor: kDarkBrown,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate() && selectedDate != null) {
                                    setModalState(() => isLoading = true);
                                    final user = AuthService().currentUser;
                                    final registration = RegistrationModel(
                                      id: UniqueKey().toString(),
                                      userId: user?.uid ?? '',
                                      eventId: '',
                                      registrationDate: DateTime.now(),
                                      cateringServiceType: cateringType,
                                      eventName: nameController.text,
                                      eventDate: selectedDate!,
                                      eventLocation: locationController.text,
                                      status: 'pending',
                                    );
                                    try {
                                      await RegistrationService().addCateringReservation(registration);
                                      Navigator.pop(context);
                                      _fetchUserReservations();
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Reservation Submitted'),
                                          content: Text('You have reserved $cateringType for ${registration.eventName} on ${dateController.text} at ${registration.eventLocation}.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    } catch (e) {
                                      setModalState(() => isLoading = false);
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Error'),
                                          content: Text('Failed to submit reservation. Please try again.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kDarkBrown))
                              : const Text('Reserve Appointment'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: const BoxDecoration(
        color: kPrimaryBeige,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Catering Services', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kDarkBrown, letterSpacing: -0.5)),
          SizedBox(height: 8),
          Text('Choose from our premium catering options and reserve for your next event.', style: TextStyle(fontSize: 16, color: kMediumBrown)),
        ],
      ),
    );
  }

  Widget _buildReservationCard(RegistrationModel r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kMediumBrown.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.event_available, color: kGoldAccent, size: 32),
        title: Text(r.eventName, style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkBrown)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.cateringServiceType, style: const TextStyle(color: kMediumBrown)),
            const SizedBox(height: 2),
            Text('${r.eventDate.toLocal().toString().split(' ')[0]} at ${r.eventLocation}', style: const TextStyle(color: kLightBrown)),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.circle, size: 10, color: r.status == 'approved' ? Colors.green : r.status == 'declined' ? Colors.red : kGoldAccent),
                const SizedBox(width: 6),
                Text('Status: ${r.status[0].toUpperCase()}${r.status.substring(1)}', style: const TextStyle(fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCateringOptionCard(Map<String, String> option) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showReservationForm(option['title']!),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kGoldAccent.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.restaurant_menu, color: kGoldAccent, size: 28),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kDarkBrown)),
                    const SizedBox(height: 4),
                    Text(option['desc']!, style: const TextStyle(fontSize: 14, color: kMediumBrown)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: kLightBrown),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryBeige,
      body: Column(
        children: [
          _buildHeader(),
          if (_loadingReservations)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_userReservations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Catering Reservations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kDarkBrown)),
                  const SizedBox(height: 12),
                  ..._userReservations.map(_buildReservationCard),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              itemCount: cateringOptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) => _buildCateringOptionCard(cateringOptions[index]),
            ),
          ),
        ],
      ),
    );
  }
} 