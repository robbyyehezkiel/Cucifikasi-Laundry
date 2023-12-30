import 'package:cucifikasi_laundry/model/data/category.dart';
import 'package:cucifikasi_laundry/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cucifikasi_laundry/model/data/transaction.dart';
import 'package:cucifikasi_laundry/ui/user/admin/category/category_repository.dart';

class TransactionForm extends StatefulWidget {
  final Category? initialCategory;

  const TransactionForm({Key? key, this.initialCategory}) : super(key: key);

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _totalPriceController = TextEditingController();
  final TextEditingController _orderDateController = TextEditingController();
  DateTime _selectedOrderDate = DateTime.now();

  String? _selectedCategory;
  late User _currentUser;
  late UtilsLog _utilsLog;
  late List<Category> _categories = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _utilsLog = UtilsLog();
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _loadCategories();

    if (widget.initialCategory != null) {
      setState(() {
        _selectedCategory = widget.initialCategory!.name;
        _setPriceAndDay();
      });
    }

    setState(() {
      _selectedOrderDate = DateTime.now();
      _orderDateController.text = _formatDate(_selectedOrderDate);
      _updatePickupDate();
    });

    _weightController.addListener(_updateTotalPrice);
    _currentUser = FirebaseAuth.instance.currentUser!;
    setState(() {
      _initialized = true;
    });
  }

  Future<void> _loadCategories() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await CategoryRepository().getCategoryStream().first;

      setState(() {
        _categories = snapshot.docs
            .map((doc) => Category.fromFirestore(doc.data()))
            .toList();
      });

      _utilsLog.logInfo(
          'TransactionForm', 'Categories loaded successfully: $_categories');
    } catch (e) {
      Utils(context).handleError('Error loading categories', e);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  void _updateTotalPrice() {
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    double price = double.tryParse(_priceController.text) ?? 0.0;

    double totalPrice = weight * price;

    _totalPriceController.text = totalPrice.toStringAsFixed(2);
  }

  Widget _buildReadOnlyFormField(
    String labelText,
    String? value,
    TextEditingController? controller,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      initialValue: value,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildOutlineFormField(
    String labelText,
    TextEditingController controller,
    FormFieldValidator<String?> validator,
  ) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdownFormField() {
    List<String> categoryNames =
        _categories.map((category) => category.name).toList();

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: categoryNames.map((categoryName) {
        return DropdownMenuItem<String>(
          value: categoryName,
          child: Text(categoryName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
            _setPriceAndDay();
            _updatePickupDate();
          });
        }
      },
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  void _setPriceAndDay() {
    if (_selectedCategory != null) {
      Category selectedCategory = _categories.firstWhere(
        (category) => category.name == _selectedCategory!,
      );

      setState(() {
        _priceController.text = selectedCategory.price.toString();
        _dayController.text = selectedCategory.day.toString();
        _updateTotalPrice();
      });
    }
  }

  Widget _buildElevatedButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          _addTransactionToFirestore();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        elevation: 3,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: const Text('Add Transaction'),
    );
  }

  Future<void> _addTransactionToFirestore() async {
    try {
      if (_selectedCategory != null) {
        TransactionData transaction = _buildTransaction();

        DocumentReference documentReference =
            await FirebaseFirestore.instance.collection('transactions').add(
                  transaction.toMap(),
                );

        String documentId = documentReference.id;
        await documentReference.update({'docId': documentId});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction added successfully!'),
            duration: Duration(seconds: 3),
          ),
        );

        _utilsLog.logInfo(
            'TransactionForm', 'Transaction added successfully: $transaction');

        _resetForm();
      }
    } catch (e) {
      Utils(context).handleError('Error adding transaction', e);
    }
  }

  void _updatePickupDate() {
    if (_selectedCategory != null) {
      Category selectedCategory = _categories.firstWhere(
        (category) => category.name == _selectedCategory!,
      );

      DateTime orderDate = DateTime.now();

      DateTime pickupDate;
      if (selectedCategory.day == 3) {
        pickupDate = orderDate.add(const Duration(hours: 3));
      } else {
        pickupDate = orderDate.add(Duration(days: selectedCategory.day));
      }

      setState(() {
        _selectedOrderDate = orderDate;
        _pickupDateController.text = _formatDate(pickupDate);
      });
    }
  }

  TransactionData _buildTransaction() {
    Category selectedCategory = _categories.firstWhere(
      (category) => category.name == _selectedCategory!,
    );

    DateTime orderDate = _selectedOrderDate;

    DateTime pickupDate;
    if (selectedCategory.day == 3) {
      pickupDate = orderDate.add(const Duration(hours: 3));
    } else {
      pickupDate = orderDate.add(Duration(days: selectedCategory.day));
    }

    double totalPrice = double.parse(_priceController.text) *
        double.parse(_weightController.text);

    return TransactionData(
      name: _currentUser.uid,
      weight: double.parse(_weightController.text),
      category: _selectedCategory!,
      orderDate: orderDate,
      pickupDate: pickupDate,
      totalPrice: totalPrice,
      status: 'Queue',
    );
  }

  void _resetForm() {
    setState(() {
      _weightController.text = '';
      _priceController.text = '';
      _dayController.text = '';
      _totalPriceController.text = '';
      _selectedCategory = null;
      _selectedOrderDate = DateTime.now();
      _orderDateController.text = _formatDate(_selectedOrderDate);
      _pickupDateController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: _initialized
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReadOnlyFormField(
                      'Order Name',
                      _currentUser.uid,
                      null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownFormField(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildReadOnlyFormField(
                            'Price',
                            null,
                            _priceController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildReadOnlyFormField(
                            'Day',
                            null,
                            _dayController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildReadOnlyFormField(
                            'Order Date',
                            null,
                            _orderDateController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildReadOnlyFormField(
                            'Pickup Date',
                            null,
                            _pickupDateController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildOutlineFormField(
                      'Weight',
                      _weightController,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Weight is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildReadOnlyFormField(
                      'Total Price',
                      null,
                      _totalPriceController,
                    ),
                    const SizedBox(height: 16),
                    _buildElevatedButton(),
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
