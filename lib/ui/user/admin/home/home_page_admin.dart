import 'package:cucifikasi_laundry/ui/user/admin/transaction/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:cucifikasi_laundry/model/data/menu.dart';
import 'package:cucifikasi_laundry/ui/user/admin/category/category_home.dart';
import 'package:cucifikasi_laundry/ui/user/admin/transaction/transaction_home.dart';
import 'package:cucifikasi_laundry/ui/user/admin/user/user_admin.dart';
import 'package:cucifikasi_laundry/model/data/transaction.dart';
import 'package:cucifikasi_laundry/utils/utils.dart';
import 'package:intl/intl.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({Key? key}) : super(key: key);

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  final List<MenuItem> menuItems = [
    MenuItem(icon: Icons.calendar_today, text: 'Transactions'),
    MenuItem(icon: Icons.category, text: 'Categories'),
    MenuItem(icon: Icons.people, text: 'Customers'),
  ];

  static const primaryColor = Colors.teal;

  String selectedStatusFilter = 'Queue';
  double totalTransactionPrice = 0.0;
  List<TransactionData> transactions = [];
  bool isLoading = false;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendarAppBar(),
          const SizedBox(height: 16),
          _buildFilterDropdown(),
          const SizedBox(height: 16),
          _buildTransactionInfo(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildMenuSection(),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Center(
        child: Text(
          "CUCIFIKASI LAUNDRY",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      backgroundColor: primaryColor,
      elevation: 4.0,
    );
  }

  Widget _buildCalendarAppBar() {
    return CalendarAppBar(
      accent: primaryColor,
      backButton: false,
      onDateChanged: (value) {
        setState(() {
          selectedDate = value;
          _loadTransactions();
        });
      },
      firstDate: DateTime.now().subtract(const Duration(days: 140)),
      lastDate: DateTime.now(),
    );
  }

  Widget _buildFilterDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Filter by Status: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          width: 8,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            style: const TextStyle(
                color: Colors.black), // Add this line to set text color
            underline: Container(), // Remove the default underline
            icon: const Icon(Icons.arrow_drop_down,
                color: primaryColor), // Add an icon
            value: selectedStatusFilter,
            onChanged: (String? value) {
              setState(() {
                selectedStatusFilter = value!;
                _loadTransactions();
              });
            },
            items: ['Queue', 'In Progress', 'Completed']
                .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Text(value),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildTransactionInfo() {
    NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: MediaQuery.of(context).size.width * 1,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.payment, color: Colors.white, size: 36),
              const SizedBox(height: 8),
              const Text(
                "Total Revenue",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormatter.format(totalTransactionPrice),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: menuItems.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildMenuItem(menuItems[index]);
        },
      ),
    );
  }

  Widget _buildMenuItem(MenuItem menuItem) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          _navigateToScreen(menuItem);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(menuItem.icon, size: 36.0, color: primaryColor),
            const SizedBox(height: 8.0),
            Text(
              menuItem.text,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(MenuItem menuItem) {
    final navigationMap = {
      'Transactions': const AdminTransactionPage(),
      'Categories': const HomePageCategory(),
      'Customers': const AdminUserPage(),
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => navigationMap[menuItem.text]!,
      ),
    );
  }

  Future<void> _loadTransactions() async {
    try {
      setState(() {
        isLoading = true;
      });

      TransactionService transactionService = TransactionService();

      List<TransactionData> filteredTransactions =
          await transactionService.getTransactions(selectedStatusFilter);

      if (selectedDate != null) {
        filteredTransactions = filteredTransactions
            .where((transaction) =>
                _formatDateWithoutTime(transaction.orderDate) ==
                _formatDateWithoutTime(selectedDate!))
            .toList();
      }

      setState(() {
        transactions = filteredTransactions;
        _calculateTotalTransactionPrice();
        isLoading = false;
      });
    } catch (e) {
      UtilsLog().logError('Transaction Load', 'Error getting transactions: $e');

      setState(() {
        isLoading = false;
      });

      Utils(context).handleError('Failed to load transactions', e);
    }
  }

  void _calculateTotalTransactionPrice() {
    List<TransactionData> filteredTransactions = transactions
        .where((transaction) => transaction.status == selectedStatusFilter)
        .toList();

    double sum = 0.0;

    for (var transaction in filteredTransactions) {
      sum += transaction.totalPrice;
    }

    setState(() {
      totalTransactionPrice = sum;
    });
  }

  String _formatDateWithoutTime(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}
