import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  Future<void> addEvent(EventModel event) async {
    await eventsCollection.add(event.toMap());
  }

  Future<void> updateEvent(EventModel event) async {
    await eventsCollection.doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String id) async {
    await eventsCollection.doc(id).delete();
  }

  Stream<List<EventModel>> getEvents() {
    return eventsCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => EventModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  Future<int> getEventCount() async {
    final query = await eventsCollection.get();
    return query.size;
  }
} 