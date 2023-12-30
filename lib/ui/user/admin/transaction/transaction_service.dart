import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cucifikasi_laundry/model/data/transaction.dart';
import 'package:cucifikasi_laundry/model/data/user.dart';
import 'package:cucifikasi_laundry/utils/utils.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UtilsLog _utilsLog = UtilsLog();

  Future<TransactionData?> getTransaction(String documentId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection('transactions').doc(documentId).get();

      if (docSnapshot.exists) {
        return TransactionData.fromFirestore(
          docSnapshot.id,
          docSnapshot.data() ?? const {},
        );
      } else {
        return null;
      }
    } catch (e) {
      _utilsLog.logError('TransactionService', 'Error getting transaction: $e');
      throw Exception('Failed to get transaction: $e');
    }
  }

  Future<List<TransactionData>> getTransactions(String status) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('transactions')
          .where('status', isEqualTo: status)
          .get();

      List<TransactionData> transactions = [];
      for (var doc in querySnapshot.docs) {
        final transactionData =
            TransactionData.fromFirestore(doc.id, doc.data());
        transactions.add(transactionData);
      }

      return transactions;
    } catch (e) {
      _utilsLog.logError(
          'TransactionService', 'Error getting transactions: $e');
      throw Exception('Failed to get transactions: $e');
    }
  }

  Future<void> deleteTransaction(String documentId) async {
    try {
      await _firestore.collection('transactions').doc(documentId).delete();
    } catch (e) {
      _utilsLog.logError(
          'TransactionService', 'Error deleting transaction: $e');
      throw Exception('Failed to delete transaction: $e');
    }
  }

  Future<Map<String, UserData>> getUsersMap() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firestore.collection('users').get();

      Map<String, UserData> users = {};
      for (var doc in querySnapshot.docs) {
        final userData = UserData.fromFirestore(doc.id, doc.data());
        users[doc.id] = userData;
      }

      return users;
    } catch (e) {
      _utilsLog.logError('TransactionService', 'Error fetching user data: $e');
      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<void> updateTransactionStatus(
      String documentId, String newStatus) async {
    try {
      await _firestore.collection('transactions').doc(documentId).update({
        'status': newStatus,
      });
    } catch (e) {
      _utilsLog.logError(
          'TransactionService', 'Error updating transaction status: $e');
      throw Exception('Failed to update transaction status: $e');
    }
  }

  Future<String?> getUserNameFromTransactionId(String transactionId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection('transactions').doc(transactionId).get();

      if (docSnapshot.exists) {
        return docSnapshot.data()?['name'];
      } else {
        return null;
      }
    } catch (e) {
      _utilsLog.logError('TransactionService', 'Error getting user name: $e');
      throw Exception('Failed to get user name: $e');
    }
  }
}
