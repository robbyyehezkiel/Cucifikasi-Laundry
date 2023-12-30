class TransactionData {
  final String name;
  final double weight;
  final String category;
  final DateTime orderDate;
  final DateTime pickupDate;
  final double totalPrice;
  final String status;
  String? docId;

  TransactionData({
    required this.name,
    required this.weight,
    required this.category,
    required this.orderDate,
    required this.pickupDate,
    required this.totalPrice,
    required this.status,
    this.docId, // Make the document ID field optional
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'weight': weight,
      'category': category,
      'orderDate': _formatDateWithoutTime(orderDate),
      'pickupDate': _formatDateWithoutTime(pickupDate),
      'totalPrice': totalPrice,
      'status': status,
    };
  }

  factory TransactionData.fromFirestore(
      String docId, Map<String, dynamic> data) {
    return TransactionData(
      name: data['name'],
      weight: data['weight'],
      category: data['category'],
      orderDate: _parseDateWithoutTime(data['orderDate']),
      pickupDate: _parseDateWithoutTime(data['pickupDate']),
      totalPrice: data['totalPrice'],
      status: data['status'],
      docId: docId,
    );
  }

  static String _formatDateWithoutTime(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  // Helper method to parse date without time
  static DateTime _parseDateWithoutTime(String dateString) {
    List<String> dateParts = dateString.split('-');
    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);
    return DateTime(year, month, day);
  }
}
