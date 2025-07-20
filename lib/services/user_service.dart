import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<UserModel?> getUser(String uid) async {
    final doc = await usersCollection.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await usersCollection.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> updateProfileImage(String uid, String imageUrl) async {
    await usersCollection.doc(uid).update({'avatarUrl': imageUrl});
  }

  Future<void> joinEvent(String userId, String eventId) async {
    await usersCollection.doc(userId).update({
      'joinedEventIds': FieldValue.arrayUnion([eventId]),
    });
  }

  Future<List<UserModel>> getUsersByJoinedEvent(String eventId) async {
    final query = await usersCollection.where('joinedEventIds', arrayContains: eventId).get();
    return query.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
} 