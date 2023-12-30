import 'package:cucifikasi_laundry/ui/auth/auth_helper.dart';
import 'package:cucifikasi_laundry/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllProfilePage extends StatefulWidget {
  const AllProfilePage({super.key});

  @override
  State<AllProfilePage> createState() => _AllProfilePageState();
}

class _AllProfilePageState extends State<AllProfilePage> {
  final AuthHelper _authHelper = AuthHelper();
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await _authHelper.userDataManager
            .getUserDataFromFirestore(user.uid);
        setState(() {
          _userData = userData;
        });
      }
    } catch (e) {
      Utils(context).handleError('Error loading user data', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_userData != null) ...[
                const CircleAvatar(
                  radius: 50,
                  // You can add an avatar image here if available
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text('Email: ${_userData!['email']}'),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('Name: ${_userData!['name']}'),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text('Address: ${_userData!['address']}'),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showLogoutConfirmationDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Change button color to red
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _logout();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _authHelper.setLoggedIn(false);

      // Navigate to your login or authentication page
      Navigator.pushReplacementNamed(context, authPageRoute);

      // Clear any previous routes
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      Utils(context).handleError('Error during logout', e);
    }
  }
}
