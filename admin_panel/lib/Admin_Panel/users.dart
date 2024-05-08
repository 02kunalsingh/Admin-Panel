// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  List<DocumentSnapshot> userList = [];

  @override
  void initState() {
    super.initState();
    fetchUserList().then((users) {
      setState(() {
        userList = users!;
      });
    });
  }

  Future<List<DocumentSnapshot>?> fetchUserList() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('User').get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching user list: $e');
      return null;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('User').doc(userId).delete();
    } catch (e) {
      print('Error deleting user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent[400],
        title: const Text('Users'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: FutureBuilder<int>(
              future: getTotalUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Text(
                  'Total Users: ${snapshot.data}',
                  style: const TextStyle(fontSize: 16),
                );
              },
            ),
          ),
        ],
      ),
      body: userList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                var userData = userList[index].data() as Map<String, dynamic>?;

                var username = userData?['name'] ?? 'No Username';
                var number = userData?['mobile'] ?? 'No Number';
                var imageUrl = userData?['image'] ?? '';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  ),
                  title: Text(username),
                  subtitle: Text(number),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete User !!'),
                            content: const Text(
                              'Are you sure you want to delete this user?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  deleteUser(userList[index].id);
                                  setState(() {
                                    userList.removeAt(index);
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Future<int> getTotalUsers() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('User').get();
      return querySnapshot.size;
    } catch (e) {
      print('Error fetching total users: $e');
      return 0;
    }
  }
}
