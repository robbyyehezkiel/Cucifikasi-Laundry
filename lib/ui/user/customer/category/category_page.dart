import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cucifikasi_laundry/model/data/category.dart';
import 'package:cucifikasi_laundry/ui/user/admin/category/category_repository.dart';
import 'package:cucifikasi_laundry/ui/user/admin/transaction/transaction_add.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerCategoryPage extends StatefulWidget {
  const CustomerCategoryPage({Key? key}) : super(key: key);

  @override
  State<CustomerCategoryPage> createState() => _CustomerCategoryPageState();
}

class _CustomerCategoryPageState extends State<CustomerCategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final CategoryRepository _categoryRepository = CategoryRepository();
  late Stream<QuerySnapshot> _categoryStream;
  CategoryFilter _selectedFilter = CategoryFilter.twoDay;

  @override
  void initState() {
    super.initState();
    _categoryStream = _categoryRepository.getCategoryStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Page'),
        actions: [
          _buildFilterDropdown(),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(child: _buildCategoryList()),
        ],
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: DropdownButton<CategoryFilter>(
        value: _selectedFilter,
        onChanged: (CategoryFilter? value) {
          if (value != null) {
            setState(() {
              _selectedFilter = value;
              _onFilterChanged();
            });
          }
        },
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        underline: Container(
          height: 1,
          color: Colors.white,
        ),
        elevation: 8,
        items: _buildFilterDropdownItems(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    );
  }

  List<DropdownMenuItem<CategoryFilter>> _buildFilterDropdownItems() {
    return [
      CategoryFilter.all,
      CategoryFilter.twoDay,
      CategoryFilter.oneDay,
      CategoryFilter.threeHour,
    ].map((filter) {
      return DropdownMenuItem(
        value: filter,
        child: Row(
          children: [
            _buildFilterIcon(filter),
            const SizedBox(width: 8.0),
            Text(
              _getFilterText(filter),
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildFilterIcon(CategoryFilter filter) {
    IconData iconData;
    Color iconColor;

    switch (filter) {
      case CategoryFilter.all:
        iconData = Icons.filter_list;
        iconColor = Colors.blue;
        break;
      case CategoryFilter.twoDay:
        iconData = Icons.access_time;
        iconColor = Colors.orange;
        break;
      case CategoryFilter.oneDay:
        iconData = Icons.access_time;
        iconColor = Colors.green;
        break;
      case CategoryFilter.threeHour:
        iconData = Icons.access_time;
        iconColor = Colors.red;
        break;
    }

    return Icon(iconData, color: iconColor);
  }

  String _getFilterText(CategoryFilter filter) {
    switch (filter) {
      case CategoryFilter.all:
        return 'All';
      case CategoryFilter.twoDay:
        return '2 Day';
      case CategoryFilter.oneDay:
        return '1 Day';
      case CategoryFilter.threeHour:
        return '3 Hour';
    }
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchTextChanged,
        decoration: InputDecoration(
          labelText: 'Search by category name',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchTextChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  void _onSearchTextChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _categoryStream = _categoryRepository.getCategoryStream();
      } else {
        _categoryStream =
            _categoryRepository.getCategoryStreamOrderedByName(query);
      }
    });
  }

  Widget _buildCategoryList() {
    return StreamBuilder(
      stream: _categoryStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            Category category = Category.fromFirestore(
              documents[index].data() as Map<String, dynamic>,
            );
            return _buildCategoryCard(category, documents[index].id);
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(Category category, String categoryId) {
    final NumberFormat rupiahFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  '${category.name} - ${category.day == 1 || category.day == 2 ? '${category.day} Day' : '${category.day} Hour'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  rupiahFormat.format(category.price),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black),
                ),
                const Text(
                  ' Kg/Item',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconButton(Icons.local_laundry_service, category),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Category category) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        _navigateToAddTransaction(category);
      },
    );
  }

  void _navigateToAddTransaction(Category selectedCategory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionForm(
          initialCategory: selectedCategory,
        ),
      ),
    );
  }

  void _onFilterChanged() {
    setState(() {
      switch (_selectedFilter) {
        case CategoryFilter.all:
          _categoryStream = _categoryRepository.getCategoryStream();
          break;
        case CategoryFilter.twoDay:
          _categoryStream = _categoryRepository.getCategoryStreamFiltered(2);
          break;
        case CategoryFilter.oneDay:
          _categoryStream = _categoryRepository.getCategoryStreamFiltered(1);
          break;
        case CategoryFilter.threeHour:
          _categoryStream = _categoryRepository.getCategoryStreamFiltered(3);
          break;
      }
    });
  }
}
