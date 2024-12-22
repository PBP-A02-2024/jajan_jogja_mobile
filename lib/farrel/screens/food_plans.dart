import "package:flutter/material.dart";
import "package:jajan_jogja_mobile/widgets/navbar.dart";
import 'package:jajan_jogja_mobile/widgets/header_app.dart';
import 'package:jajan_jogja_mobile/farrel/widgets/restaurant_card.dart';
import 'package:jajan_jogja_mobile/farrel/models/food_plan_model.dart';
import 'package:jajan_jogja_mobile/marco/models/makanan.dart';
import 'package:jajan_jogja_mobile/iyan/models/resto.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class FoodPlans extends StatefulWidget {
  final String planId;

  const FoodPlans({
    Key? key,
    required this.planId,
  }) : super(key: key);

  @override
  State<FoodPlans> createState() => _FoodPlansState();
}

class _FoodPlansState extends State<FoodPlans> {
  late Future<Map<String, dynamic>> futurePlanDetails;
  bool isEditingItems = false;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    futurePlanDetails = fetchAllData(request);
  }

  Future<Map<String, dynamic>> fetchAllData(CookieRequest request) async {
    try {
      final response = await request.get(
        'http://127.0.0.1:8000/food_plans/food_plan_detail_json/${widget.planId}/',
      );

      if (response is List && response.isNotEmpty) {
        final firstPlan = response[0];
        final restaurantIds =
            List<String>.from(firstPlan['fields']['tempat_kuliner']);
        final makananIds = List<String>.from(firstPlan['fields']['makanan']);

        // Fetch all restaurants and their foods
        List<TempatKuliner> restaurants = [];
        Map<String, List<Makanan>> restaurantFoods = {};

        for (String restaurantId in restaurantIds) {
          // Fetch restaurant details
          final restaurantResponse = await request.get(
            'http://127.0.0.1:8000/restaurant/get_restoran_json/$restaurantId/',
          );
          if (restaurantResponse is List && restaurantResponse.isNotEmpty) {
            restaurants.add(TempatKuliner.fromJson(restaurantResponse[0]));
          }

          // Fetch foods for this restaurant
          final foodResponse = await request.get(
            'http://127.0.0.1:8000/restaurant/get_makanan_json/$restaurantId/',
          );
          if (foodResponse != null) {
            List<Makanan> foods = [];
            for (var food in foodResponse) {
              if (makananIds.contains(food['pk'])) {
                foods.add(Makanan.fromJson(food));
              }
            }
            restaurantFoods[restaurantId] = foods;
          }
        }

        return {
          'foodPlan': DetailedFoodPlan(
            model: firstPlan['model'],
            pk: firstPlan['pk'],
            fields: DetailedFields(
              user: firstPlan['fields']['user'],
              nama: firstPlan['fields']['nama'],
              restaurants: restaurants,
            ),
          ),
          'restaurantFoods': restaurantFoods,
        };
      }
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<bool> updateTitle(CookieRequest request, String newTitle) async {
    final response = await request.post(
      'http://127.0.0.1:8000/food_plans/update_title/${widget.planId}/',
      jsonEncode({'new_title': newTitle}),
    );
    return response != null && response['success'] == "True";
  }

  Future<bool> deleteFoodItem(CookieRequest request, String foodPk) async {
    final response = await request.post(
      'http://127.0.0.1:8000/food_plans/remove_item/${widget.planId}/',
      jsonEncode({'food_item_id': foodPk}),
    );
    return response != null && response['success'] == "True";
  }

  Future<bool> deleteFoodPlan(CookieRequest request) async {
    final response = await request.post(
      'http://127.0.0.1:8000/food_plans/remove/${widget.planId}/',
      {},
    );
    return response != null && response['success'] == "True";
  }

  Future<bool> deleteRestaurant(
      CookieRequest request, String restaurantPk) async {
    final response = await request.post(
      'http://127.0.0.1:8000/food_plans/remove_restaurant/${widget.planId}/',
      jsonEncode({'restaurant_id': restaurantPk}),
    );
    return response != null && response['success'] == "True";
  }

  // Show popup for food details
  void showFoodDetails(Map<String, dynamic> food) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(food['name'] ?? 'Food Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description: ${food['description'] ?? 'N/A'}'),
              Text('Price: Rp ${food['price'] ?? 'N/A'}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Show popup for restaurant details
  void showRestaurantDetails(TempatKuliner restaurant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(restaurant.fields.nama ?? 'Restaurant Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Address: ${restaurant.fields.alamat ?? 'N/A'}'),
              // Add more details as needed
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Handle deleting a food item
  void handleDeleteFoodItem(String foodPk) async {
    final request = context.read<CookieRequest>();
    bool success = await deleteFoodItem(request, foodPk);
    if (success) {
      setState(() {
        futurePlanDetails = fetchAllData(request);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food item deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete food item')),
      );
    }
  }

  // Handle deleting a restaurant
  void handleDeleteRestaurant(String restaurantPk) async {
    final request = context.read<CookieRequest>();
    bool success = await deleteRestaurant(request, restaurantPk);
    if (success) {
      setState(() {
        futurePlanDetails = fetchAllData(request);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurant deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete restaurant')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBE9E1),
      appBar: headerApp(context),
      bottomNavigationBar: navbar(context, 'food plans'),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futurePlanDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final foodPlan = snapshot.data!['foodPlan'] as DetailedFoodPlan;
            final restaurantFoods =
                snapshot.data!['restaurantFoods'] as Map<String, List<Makanan>>;
            final request = context.read<CookieRequest>();

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Title with Edit Title and Toggle Item Editing Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        // Food Plan Title
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                foodPlan.fields.nama,
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Buttons Row: Edit Title and Toggle Item Editing
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFEBE9E1),
                                  foregroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    width: 2,
                                  ),
                                  minimumSize: const Size.fromHeight(40),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      String newTitle = foodPlan.fields.nama;
                                      return AlertDialog(
                                        title:
                                            const Text('Edit Food Plan Title'),
                                        content: TextField(
                                          autofocus: true,
                                          decoration: const InputDecoration(
                                            labelText: 'New Title',
                                          ),
                                          onChanged: (value) {
                                            newTitle = value;
                                          },
                                          controller: TextEditingController(
                                              text: foodPlan.fields.nama),
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                          TextButton(
                                            child: const Text('Save'),
                                            onPressed: () async {
                                              try {
                                                final success =
                                                    await updateTitle(
                                                        request, newTitle);
                                                if (!context.mounted) return;

                                                if (success) {
                                                  Navigator.of(context)
                                                      .pop(); // Close dialog
                                                  // Notify parent about the update if needed
                                                  setState(() {
                                                    futurePlanDetails =
                                                        fetchAllData(request);
                                                  });
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Title updated successfully')),
                                                  );
                                                } else {
                                                  Navigator.of(context)
                                                      .pop(); // Close dialog
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Failed to update title')),
                                                  );
                                                }
                                              } catch (e) {
                                                Navigator.of(context)
                                                    .pop(); // Close dialog
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content:
                                                          Text('Error: $e')),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text('Edit Title'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFEBE9E1),
                                  foregroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    width: 2,
                                  ),
                                  minimumSize: const Size.fromHeight(40),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isEditingItems = !isEditingItems;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isEditingItems
                                          ? 'Item Editing Enabled'
                                          : 'Item Editing Disabled'),
                                    ),
                                  );
                                },
                                child: const Text('Toggle Item Editing'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Delete Food Plan Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: const Color(0xFFEBE9E1),
                        side: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                        minimumSize: const Size.fromHeight(40),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Food Plan'),
                              content: const Text(
                                  'Are you sure you want to delete this food plan?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () async {
                                    Navigator.of(context).pop(); // Close dialog
                                    try {
                                      final success =
                                          await deleteFoodPlan(request);
                                      if (success) {
                                        Navigator.of(context).pop(
                                            true); // Pass back deletion status
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Food Plan deleted successfully')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Failed to delete Food Plan')),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Delete Food Plan'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // List of Restaurant Cards
                  if (foodPlan.fields.restaurants.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No restaurants added yet, go ahead and add some!',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  else
                    ...foodPlan.fields.restaurants.map((restaurant) {
                      final foods = restaurantFoods[restaurant.pk] ?? [];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: RestaurantCard(
                          restaurantPk: restaurant.pk,
                          restaurantName: restaurant.fields.nama,
                          address: restaurant.fields.alamat,
                          distance: 0.0,
                          foods: foods
                              .map((food) => {
                                    'pk': food.pk,
                                    'name': food.fields.nama,
                                    'description': food.fields.description,
                                    'price': food.fields.harga.toString(),
                                    'imageUrl': food.fields.fotoLink,
                                  })
                              .toList(),
                          isEditingItems: isEditingItems,
                          onFoodTap: (food) {
                            showFoodDetails(food);
                          },
                          onDeleteFood: (foodPk) {
                            handleDeleteFoodItem(foodPk);
                          },
                          onRestaurantTap: () {
                            showRestaurantDetails(restaurant);
                          },
                          onDeleteRestaurant: (restaurantPk) {
                            handleDeleteRestaurant(restaurantPk);
                          },
                        ),
                      );
                    }).toList(),
                ],
              ),
            );
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
}
