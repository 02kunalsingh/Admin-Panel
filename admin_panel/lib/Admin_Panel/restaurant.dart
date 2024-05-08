// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Define a Restaurant class to represent restaurant data
class Restaurant {
  final String name;
  final String imageUrl;
  final double rating;

  Restaurant({
    required this.name,
    required this.imageUrl,
    required this.rating,
  });
}

// Define a stateful widget for the restaurant list screen
class RestaurantList extends StatefulWidget {
  const RestaurantList({super.key});

  @override
  State<RestaurantList> createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {
  late Future<List<Restaurant>> _restaurantsFuture;

  @override
  void initState() {
    super.initState();
    _restaurantsFuture = fetchRestaurants();
  }

  // Function to fetch restaurant data from Firebase
  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Restaurants').get();
      List<Restaurant> restaurants = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Restaurant(
          name: data['restaurant'] ?? '',
          imageUrl: data['image'] ?? '',
          rating: double.tryParse(data['rating'] ?? '0.0') ?? 0.0,
        );
      }).toList();
      return restaurants;
    } catch (e) {
      print('Error fetching restaurants: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent[400],
        title: const Text('Restaurant List'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: FutureBuilder<int>(
              future: getTotalRestaurants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Text(
                  'Total : ${snapshot.data}',
                  style: const TextStyle(fontSize: 16),
                );
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: _restaurantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No restaurants found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Restaurant restaurant = snapshot.data![index];
                return ListTile(
                  leading: Container(
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(restaurant.imageUrl),
                        ),
                        shape: BoxShape.rectangle,
                        color: Colors.greenAccent),
                  ),
                  title: Text(restaurant.name),
                  subtitle:
                      Text('Rating: ${restaurant.rating.toStringAsFixed(1)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Restaurant'),
                            content: const Text(
                                'Are you sure you want to delete this restaurant?'),
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
                                  deleteRestaurant(restaurant.name);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
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
            );
          }
        },
      ),
    );
  }

  Future<void> deleteRestaurant(String restaurantName) async {
    try {
      await FirebaseFirestore.instance
          .collection('Restaurants')
          .where('restaurant', isEqualTo: restaurantName)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
    } catch (e) {
      print('Error deleting restaurant: $e');
    }
  }

  Future<int> getTotalRestaurants() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Restaurants').get();
      return querySnapshot.size;
    } catch (e) {
      print('Error fetching Total : $e');
      return 0;
    }
  }
}
