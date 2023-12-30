import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final UserRepository _instance = UserRepository._internal();

  factory UserRepository() {
    return _instance;
  }

  UserRepository._internal();

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection('users').snapshots();
  }

  Stream<QuerySnapshot> getUserStreamOrderedByName(String query) {
    return _firestore
        .collection('users')
        .orderBy('lowercaseName')
        .startAt([query.toLowerCase()]).endAt(
            ['${query.toLowerCase()}\uf8ff']).snapshots();
  }
}
