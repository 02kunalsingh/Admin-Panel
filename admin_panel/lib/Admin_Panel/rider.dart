// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Rider extends StatefulWidget {
  const Rider({super.key});

  @override
  State<Rider> createState() => _RiderState();
}

class _RiderState extends State<Rider> {
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
          await FirebaseFirestore.instance.collection('Speedzo-User').get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching user list: $e');
      return null;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Speedzo-User')
          .doc(userId)
          .delete();
    } catch (e) {
      print('Error deleting user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent[400],
        title: const Text('Riders'),
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
                  'Total Riders: ${snapshot.data}',
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
                var number = userData?['number'] ?? 'No Number';
                var imageUrl = userData?['image'] ?? "";
                var Status = userData?['status'] ?? "offline";

                return ListTile(
                  leading: imageUrl.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                  title: Row(
                    children: [
                      Text(username),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        Status,
                        style: const TextStyle(fontSize: 14),
                      )
                    ],
                  ),
                  subtitle: Text(number),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              'Delete User',
                            ),
                            content: const Text(
                                'Are you sure you want to delete this Rider?'),
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
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
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
          await FirebaseFirestore.instance.collection('Speedzo-User').get();
      return querySnapshot.size;
    } catch (e) {
      print('Error fetching total users: $e');
      return 0;
    }
  }
}
