import 'package:cucifikasi_laundry/ui/user/all/profile/profile_home.dart';
import 'package:cucifikasi_laundry/ui/user/customer/home_page_customer.dart';
import 'package:cucifikasi_laundry/ui/user/customer/transaction/transaction_page.dart';
import 'package:flutter/material.dart';

class MainPageCustomer extends StatefulWidget {
  const MainPageCustomer({super.key});

  @override
  State<MainPageCustomer> createState() => _MainPageCustomerState();
}

class _MainPageCustomerState extends State<MainPageCustomer> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    const CustomerHomePage(),
    const CustomerTransactionPage(),
    const AllProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
