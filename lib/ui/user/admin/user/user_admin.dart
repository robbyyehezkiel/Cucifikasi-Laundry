import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cucifikasi_laundry/ui/user/all/chat/chat_home.dart';
import 'package:cucifikasi_laundry/ui/user/admin/user/user_detail.dart';
import 'package:flutter/material.dart';

class AdminUserPage extends StatefulWidget {
  const AdminUserPage({
    Key? key,
  }) : super(key: key);

  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _userStream;
  final TextEditingController searchController = TextEditingController();

  String selectedRole = 'All'; // Default to show all users

  @override
  void initState() {
    super.initState();
    _userStream = FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        actions: [
          _buildFilterButton(),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _userStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final users = snapshot.data?.docs;

                // Apply search filter based on lowercase name
                final filteredUsers = _applySearchFilter(users);

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final userData =
                        filteredUsers[index].data();

                    return _buildUserCard(userData, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        onChanged: _onSearchTextChanged,
        decoration: InputDecoration(
          labelText: 'Search by user name',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
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
        _updateUserStream();
      } else {
        _userStream = FirebaseFirestore.instance
            .collection('users')
            .where('lowercaseName', arrayContains: query.toLowerCase())
            .snapshots();
      }
    });
  }

  Widget _buildUserCard(Map<String, dynamic> userData, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to user detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailPage(userData),
          ),
        );
      },
      child: Card(
        elevation: 3.0,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              userData['name'][0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            userData['name'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            userData['email'],
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllChatPage(
                    senderId: 'admin', // Replace with the actual admin user ID
                    receiverId: userData['userId'],
                    receiverName: userData['name'],
                    isSenderAdmin: true,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        setState(() {
          selectedRole = result;
          _updateUserStream();
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'All',
          child: Text('Show All'),
        ),
        const PopupMenuItem<String>(
          value: 'Admin',
          child: Text('Admin'),
        ),
        const PopupMenuItem<String>(
          value: 'Customer',
          child: Text('Customer'),
        ),
      ],
    );
  }

  void _updateUserStream() {
    if (selectedRole == 'Admin') {
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .where('isAdmin', isEqualTo: 1)
          .snapshots();
    } else if (selectedRole == 'Customer') {
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .where('isAdmin', isEqualTo: 0)
          .snapshots();
    } else {
      _userStream = FirebaseFirestore.instance.collection('users').snapshots();
    }
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applySearchFilter(
      List<QueryDocumentSnapshot<Map<String, dynamic>>?>? users) {
    final String searchTerm = searchController.text.toLowerCase();

    if (users == null) {
      return [];
    }

    if (searchTerm.isEmpty) {
      return users
          .whereType<QueryDocumentSnapshot<Map<String, dynamic>>>()
          .toList();
    }

    return users
        .whereType<QueryDocumentSnapshot<Map<String, dynamic>>>()
        .where((user) {
      final String lowercaseName = user.data()['name'].toString().toLowerCase();
      return lowercaseName.contains(searchTerm);
    }).toList();
  }
}
