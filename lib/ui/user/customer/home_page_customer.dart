import 'package:cucifikasi_laundry/ui/user/customer/transaction/schedule_table.dart';
import 'package:cucifikasi_laundry/utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:cucifikasi_laundry/model/data/menu.dart';
import 'package:cucifikasi_laundry/ui/user/admin/transaction/transaction_add.dart';
import 'package:cucifikasi_laundry/ui/user/all/chat/chat_home.dart';
import 'package:cucifikasi_laundry/ui/user/customer/category/category_page.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({Key? key}) : super(key: key);

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  final List<MenuItem> menuItems = [
    MenuItem(icon: Icons.calendar_today, text: 'Transactions'),
    MenuItem(icon: Icons.category, text: 'Categories'),
    MenuItem(icon: Icons.contact_support, text: 'Contact Us'),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/laundry_banner.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Card on Top
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 122),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 8.0),
                            const Text(
                              "CUCIFIKASI LAUNDRY",
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            const Text(
                              "Your Garments, Our Care",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            const ScheduleTable(),
                            const SizedBox(height: 16.0),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    CustomButton(
                                      icon: Icons.category,
                                      label: 'Categories',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const CustomerCategoryPage()),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 16.0),
                                    CustomButton(
                                      icon: Icons.call,
                                      label: 'Contact Us',
                                      onTap: () {
                                        _navigateToChat();
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 16.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionForm(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              'Add Transaction',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToChat() {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllChatPage(
            senderId: userId,
            receiverId: 'admin',
            receiverName: "Admin",
            isSenderAdmin: false,
          ),
        ),
      );
    } else {
      _logger.e('No logged-in user found.');
    }
  }
}
