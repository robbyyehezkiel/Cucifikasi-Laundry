import 'package:cucifikasi_laundry/model/data/transaction.dart';
import 'package:cucifikasi_laundry/model/data/user.dart';
import 'package:cucifikasi_laundry/ui/auth/auth_helper.dart';
import 'package:cucifikasi_laundry/ui/user/admin/transaction/transaction_service.dart';
import 'package:cucifikasi_laundry/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerTransactionPage extends StatefulWidget {
  const CustomerTransactionPage({Key? key}) : super(key: key);

  @override
  State<CustomerTransactionPage> createState() =>
      _CustomerTransactionPageState();
}

class _CustomerTransactionPageState extends State<CustomerTransactionPage>
    with SingleTickerProviderStateMixin {
  final TransactionService _transactionService = TransactionService();
  late TabController _tabController;
  late String activeStatus;
  late Map<String, UserData?> usersMap = {};

  final AuthHelper _authHelper = AuthHelper();
  Map<String, dynamic>? _userData;

  static const int queueTabIndex = 0;
  static const int inProgressTabIndex = 1;
  static const int completedTabIndex = 2;

  static const String queueStatus = 'Queue';
  static const String inProgressStatus = 'In Progress';
  static const String completedStatus = 'Completed';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    activeStatus = getStatusByTabIndex(_tabController.index);

    _fetchUsersMap();
    _loadUserData();
  }

  void _handleTabChange() {
    setState(() {
      activeStatus = getStatusByTabIndex(_tabController.index);
    });
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsersMap() async {
    try {
      final map = await _transactionService.getUsersMap();
      setState(() {
        usersMap = map;
      });
    } catch (error) {
      Utils(context).handleError('Error fetching user data', error);
    }
  }

  String getStatusByTabIndex(int index) {
    switch (index) {
      case queueTabIndex:
        return queueStatus;
      case inProgressTabIndex:
        return inProgressStatus;
      case completedTabIndex:
        return completedStatus;
      default:
        return queueStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction List'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Queue'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(queueStatus),
          _buildTransactionList(inProgressStatus),
          _buildTransactionList(completedStatus),
        ],
      ),
    );
  }

  Widget _buildTransactionList(String status) {
    return FutureBuilder<List<TransactionData>>(
      future: _transactionService.getTransactions(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          Utils(context)
              .handleError('Error fetching transactions', snapshot.error);
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No transactions available.'),
          );
        } else {
          final filteredTransactions = snapshot.data!
              .where((transaction) =>
                  transaction.name == '${_userData?['userId']}')
              .toList();
          return ListView.builder(
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = filteredTransactions[index];
              final UserData? user = usersMap[transaction.name];

              if (user == null) {
                return Container(); // or any other placeholder widget
              }

              return _buildTransactionCard(transaction, user);
            },
          );
        }
      },
    );
  }

  Widget _buildTransactionCard(TransactionData transaction, UserData? user) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {},
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildIconAndTextRow(Icons.person, 'Ordered by:'),
            _buildTextRow(user?.name ?? 'Unknown User', FontWeight.bold, 18),
            const SizedBox(height: 12),
            _buildDivider(),
            const SizedBox(height: 12),
            _buildCategoryAndWeightRow(
                transaction.category, transaction.weight),
            const SizedBox(height: 12),
            _buildDateRow('Order Date:', transaction.orderDate),
            const SizedBox(height: 16),
            _buildTotalPriceRow(transaction.totalPrice),
          ],
        ),
      ),
    );
  }

  Widget _buildIconAndTextRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildTextRow(String text, FontWeight fontWeight, double fontSize) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: Colors.black,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildCategoryAndWeightRow(String category, double weight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTextRow(category, FontWeight.bold, 16),
        const Text(
          ' - ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        _buildTextRow('$weight Kg', FontWeight.bold, 16),
      ],
    );
  }

  Widget _buildDateRow(String label, DateTime date) {
    return Row(
      children: [
        _buildDateTimeColumn(label, _formatDate(date)),
        const SizedBox(width: 16),
        _buildDateTimeColumn('Pickup Date:', _formatDate(date)),
      ],
    );
  }

  Widget _buildTotalPriceRow(double totalPrice) {
    return Container(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Price: ${_formatCurrency(totalPrice)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Column _buildDateTimeColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMd().add_Hms().format(date);
  }
}
