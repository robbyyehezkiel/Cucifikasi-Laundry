import 'package:cucifikasi_laundry/ui/auth/auth_page.dart';
import 'package:cucifikasi_laundry/ui/main/main_page_admin.dart';
import 'package:cucifikasi_laundry/ui/main/main_page_customer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Authentication',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        hintColor: Colors.grey,
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthPage(),
        '/admin_home': (context) => const MainPageAdmin(),
        '/customer_home': (context) => const MainPageCustomer(),
      },
    );
  }
}
