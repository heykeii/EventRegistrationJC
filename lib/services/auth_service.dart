import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;

  Stream<UserModel?> get authStateChanges async* {
    yield _currentUser;
  }

  UserModel? get currentUser => _currentUser;

  Future<UserModel?> signIn(String email, String password) async {
    // Query Firestore for user with matching email and password
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final user = UserModel.fromMap(query.docs.first.data());
      _currentUser = user;
      return user;
    }
    throw Exception('Invalid email or password');
  }

  Future<UserModel?> signUp(String email, String password, String name, {String? phone}) async {
    // Check if email already exists
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      throw Exception('Email already registered');
    }
    final user = UserModel(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      phone: phone,
      password: password,
      createdAt: DateTime.now(),
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());
    _currentUser = user;
    return user;
  }

  Future<void> signOut() async {
    _currentUser = null;
  }
} 