import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cucifikasi_laundry/model/data/category.dart';
import 'package:cucifikasi_laundry/ui/user/admin/category/category_repository.dart';
import 'package:cucifikasi_laundry/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePageCategory extends StatefulWidget {
  const HomePageCategory({Key? key}) : super(key: key);

  @override
  State<HomePageCategory> createState() => _HomePageCategoryState();
}

class _HomePageCategoryState extends State<HomePageCategory> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
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
              _buildIconButton(Icons.edit,
                  () => _showEditCategoryDialog(category, categoryId)),
              _buildIconButton(Icons.delete,
                  () => _showDeleteConfirmationDialog(categoryId)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      TextInputType inputType,
      {Function(String)? validator}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: labelText,
        errorText: validator != null ? validator(controller.text) : null,
      ),
    );
  }

  void _showAddCategoryDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(_nameController, 'Name', TextInputType.text),
                  _buildTextField(
                    _priceController,
                    'Price',
                    TextInputType.number,
                  ),
                  _buildTextField(
                    _dayController,
                    'Day',
                    TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addCategory,
                    child: const Text('Add Category'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _validateFields({bool isEditing = false}) {
    if (!isEditing) {
      if (_nameController.text.trim().isEmpty ||
          _priceController.text.trim().isEmpty ||
          _dayController.text.trim().isEmpty) {
        Utils(context).showSnackbar('Please fill in all fields');
        return false;
      }
    }
    return true;
  }

  void _addCategory() async {
    try {
      if (!_validateFields()) {
        return;
      }

      DateTime now = DateTime.now();
      Category newCategory = Category(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        dateTime: now,
        day: int.parse(_dayController.text.trim()),
      );

      await _categoryRepository.addCategory(newCategory);

      _clearFormInputs();

      Navigator.of(context).pop();
      Utils(context).showSnackbar(
        'Category added successfully',
      );
    } catch (e) {
      Utils(context).handleError('Error adding category', e);
    }
  }

  void _showEditCategoryDialog(Category category, String categoryId) {
    TextEditingController editNameController =
        TextEditingController(text: category.name);
    TextEditingController editPriceController =
        TextEditingController(text: category.price.toString());
    TextEditingController editDayController =
        TextEditingController(text: category.day.toString());

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      editNameController,
                      'Name',
                      TextInputType.text,
                    ),
                    _buildTextField(
                      editPriceController,
                      'Price',
                      TextInputType.number,
                    ),
                    _buildTextField(
                      editDayController,
                      'Day',
                      TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _updateCategory(
                        categoryId,
                        editNameController.text.trim(),
                        double.parse(editPriceController.text.trim()),
                        DateTime.now(),
                        int.parse(editDayController.text.trim()),
                      ),
                      child: const Text('Update Category'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateCategory(String categoryId, String newName, double newPrice,
      DateTime newDateTime, int newDay) async {
    try {
      if (!_validateFields(isEditing: true)) {
        return;
      }

      Category updatedCategory = Category(
        name: newName,
        price: newPrice,
        dateTime: newDateTime,
        day: newDay,
      );

      await _categoryRepository.updateCategory(categoryId, updatedCategory);

      _clearFormInputs();

      Navigator.of(context).pop();
      Utils(context).showSnackbar(
        'Category updated successfully',
      );
    } catch (e) {
      Utils(context).handleError('Error updating category', e);
    }
  }

  void _clearFormInputs() {
    _nameController.clear();
    _priceController.clear();
    _dayController.clear();
  }

  void _showDeleteConfirmationDialog(String categoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: const Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteCategory(categoryId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(String categoryId) async {
    try {
      await _categoryRepository.deleteCategory(categoryId);

      Utils(context).showSnackbar('Category deleted successfully');
    } catch (e) {
      Utils(context).handleError('Error deleting category', e);
    }
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
