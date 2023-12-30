import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cucifikasi_laundry/model/data/category.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final CategoryRepository _instance = CategoryRepository._internal();

  factory CategoryRepository() {
    return _instance;
  }

  CategoryRepository._internal();

  Stream<QuerySnapshot<Map<String, dynamic>>> getCategoryStream() {
    return _firestore.collection('categories').snapshots();
  }

  Stream<QuerySnapshot> getCategoryStreamOrderedByName(String query) {
    return _firestore
        .collection('categories')
        .orderBy('lowercaseName')
        .startAt([query.toLowerCase()]).endAt(
            ['${query.toLowerCase()}\uf8ff']).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCategoryStreamFiltered(
      double filterValue) {
    if (filterValue == 0) {
      return _firestore.collection('categories').snapshots();
    } else {
      return _firestore
          .collection('categories')
          .where('day', isEqualTo: filterValue)
          .snapshots();
    }
  }

  Future<void> addCategory(Category newCategory) async {
    await _firestore.collection('categories').add(newCategory.toMap());
  }

  Future<void> updateCategory(
      String categoryId, Category updatedCategory) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .update(updatedCategory.toMap());
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .update({'lowercaseName': updatedCategory.name.toLowerCase()});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
  }
}
