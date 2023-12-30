import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String name;
  final double price;
  final DateTime dateTime;
  final int day;

  Category({
    required this.name,
    required this.price,
    required this.dateTime,
    required this.day,
  });

  Category.fromFirestore(Map<String, dynamic> data)
      : name = data['name'],
        price = data['price'],
        dateTime = (data['dateTime'] as Timestamp).toDate(),
        day = data['day'];

  Category.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        price = map['price'],
        dateTime = (map['dateTime'] as Timestamp).toDate(),
        day = map['day'];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'dateTime': dateTime,
      'day': day,
      'lowercaseName': name.toLowerCase(),
    };
  }
}

enum CategoryFilter { all, twoDay, oneDay, threeHour }
