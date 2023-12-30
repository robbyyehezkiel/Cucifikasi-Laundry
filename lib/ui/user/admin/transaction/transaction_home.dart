import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cucifikasi_laundry/model/data/transaction.dart';
import 'package:cucifikasi_laundry/model/data/user.dart';
import 'package:cucifikasi_laundry/ui/user/admin/transaction/transaction_service.dart';
import 'package:cucifikasi_laundry/utils/utils.dart';

class AdminTransactionPage extends StatefulWidget {
  const AdminTransactionPage({Key? key}) : super(key: key);

  @override
  _AdminTransactionPageState createState() => _AdminTransactionPageState();
}

class _AdminTransactionPageState extends State<AdminTransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TransactionService _transactionService;
  late String activeStatus;
  late Map<String, UserData> usersMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _transactionService = TransactionService();

    activeStatus = getStatusByTabIndex(_tabController.index);
    _tabController.addListener(() {
      setState(() {
        activeStatus = getStatusByTabIndex(_tabController.index);
      });
    });

    _fetchUsersMap();
  }

  void _fetchUsersMap() async {
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
      case 0:
        return 'Queue';
      case 1:
        return 'In Progress';
      case 2:
        return 'Completed';
      default:
        return 'Queue';
    }
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
          final filteredTransactions = snapshot.data!;
          return ListView.builder(
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = filteredTransactions[index];
              final UserData? user = usersMap[transaction.name];
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Ordered by:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              user?.name ?? 'Unknown User',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 4),
                Text(
                  transaction.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  " - ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${transaction.weight} Kg',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDateTimeColumn(
                    'Order Date:', _formatDate(transaction.orderDate)),
                const SizedBox(width: 16),
                _buildDateTimeColumn(
                    'Pickup Date:', _formatDate(transaction.pickupDate)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              color: Colors.grey[800],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Total Price: ${_formatCurrency(transaction.totalPrice)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      _updateTransactionStatus(transaction.docId, activeStatus);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      _deleteTransaction(transaction.docId);
                    },
                  ),
                ],
              ),
            ),
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

  void _deleteTransaction(String? documentId) {
    if (documentId != null) {
      _transactionService.deleteTransaction(documentId).then((_) {
        _fetchUsersMap();
        Utils(context).showSnackbar('Transaction deleted successfully');
      }).catchError((error) {
        Utils(context).handleError('Error deleting transaction', error);
      });
    } else {
      Utils(context)
          .handleError('Document ID is null. Cannot delete transaction.', null);
    }
  }

  void _updateTransactionStatus(
      String? documentId, String currentStatus) async {
    if (documentId != null) {
      String newStatus =
          (currentStatus == 'Queue') ? 'In Progress' : 'Completed';

      UtilsLog().logInfo('Transaction Update',
          'Updating transaction status from $currentStatus to $newStatus');

      try {
        TransactionData? transaction =
            await _transactionService.getTransaction(documentId);

        if (transaction != null) {
          await _transactionService.updateTransactionStatus(
              documentId, newStatus);
          _fetchUsersMap();
          Utils(context)
              .showSnackbar('Transaction status updated successfully');
        } else {
          throw Exception('Transaction not found for document ID: $documentId');
        }
      } catch (error) {
        Utils(context).handleError('Error updating transaction status', error);
      }
    } else {
      Utils(context).handleError(
          'Document ID is null. Cannot update transaction status.', null);
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
          _buildTransactionList('Queue'),
          _buildTransactionList('In Progress'),
          _buildTransactionList('Completed'),
        ],
      ),
    );
  }
}
