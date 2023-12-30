// auth_helper.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  static const String _loggedInKey = 'loggedIn';

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  AuthManager get authManager => AuthManager(_auth, _logger);
  UserDataManager get userDataManager => UserDataManager(_firestore, _logger);
  AdminManager get adminManager => AdminManager(_auth, _firestore, _logger);
}

class AuthManager {
  final FirebaseAuth _auth;
  final Logger _logger;

  AuthManager(this._auth, this._logger);

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Error during login: ${e.message}');
      rethrow;
    }
  }

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Error during registration: ${e.message}');
      rethrow;
    }
  }
}

class UserDataManager {
  final FirebaseFirestore _firestore;
  final Logger _logger;

  UserDataManager(this._firestore, this._logger);

  Future<Map<String, dynamic>?> getUserDataFromFirestore(String userId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(userId).get();
      return userDoc.data();
    } catch (e) {
      _logger.e('Error fetching user data from Firestore: $e');
      rethrow;
    }
  }

  Future<bool> doesEmailExist(String email) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking if email exists: $e');
      rethrow;
    }
  }

  Future<void> saveUserDataToFirestore(
      User user, String email, String name, String address) async {
    try {
      final Map<String, dynamic> userData = {
        'email': email,
        'name': name,
        'address': address,
        'isAdmin': 0,
        'lowercaseName': name.toLowerCase(),
        'userId': user.uid,
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
    } catch (e) {
      _logger.e('Error saving user data to Firestore: $e');
      throw Exception('Failed to save user data to Firestore: $e');
    }
  }
}

class AdminManager {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Logger _logger;

  AdminManager(this._auth, this._firestore, this._logger);

  Future<bool> isAdmin() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userData =
            await _firestore.collection('users').doc(user.uid).get();
        return userData['isAdmin'] == 1;
      }
      return false;
    } catch (e) {
      _logger.e('Error checking admin status: $e');
      rethrow;
    }
  }
}
