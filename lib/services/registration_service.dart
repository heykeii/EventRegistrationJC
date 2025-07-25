import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/registration_model.dart';

class RegistrationService {
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  Future<void> addCateringReservation(RegistrationModel reservation) async {
    final docRef = await RegistrationService.db.collection('catering_reservations').add(reservation.toMap());
    await docRef.update({'id': docRef.id});
  }

  Future<List<RegistrationModel>> getUserCateringReservations(String userId) async {
    final query = await RegistrationService.db.collection('catering_reservations').where('userId', isEqualTo: userId).get();
    return query.docs.map((doc) => RegistrationModel.fromMap(doc.data())).toList();
  }

  Future<List<RegistrationModel>> getAllCateringReservations() async {
    final query = await RegistrationService.db.collection('catering_reservations').get();
    return query.docs.map((doc) => RegistrationModel.fromMap(doc.data())).toList();
  }

  Future<void> updateReservationStatus(String docId, String status) async {
    await RegistrationService.db.collection('catering_reservations').doc(docId).update({'status': status});
  }
} 