import 'package:flutter/material.dart';
import 'package:jajan_jogja_mobile/widgets/header_app.dart';
import 'package:jajan_jogja_mobile/widgets/navbar.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:jajan_jogja_mobile/farrel/models/food_plan_model.dart';
import 'package:jajan_jogja_mobile/farrel/widgets/food_plan_card.dart';
import 'package:jajan_jogja_mobile/farrel/screens/food_plans.dart';

class FoodPlanList extends StatefulWidget {
  const FoodPlanList({Key? key}) : super(key: key);

  @override
  State<FoodPlanList> createState() => _FoodPlanListState();
}

class _FoodPlanListState extends State<FoodPlanList> {
  late Future<List<FoodPlan>> futureFoodPlans;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    futureFoodPlans = fetchFoodPlans(request);
  }

  Future<List<FoodPlan>> fetchFoodPlans(CookieRequest request) async {
    final response = await request.get(
        'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/food_plans/food_plan_json/');

    if (response != null) {
      List<FoodPlan> foodPlans = [];
      for (var d in response) {
        if (d != null) {
          foodPlans.add(FoodPlan.fromJson(d));
        }
      }
      return foodPlans;
    } else {
      throw Exception('Failed to load food plans');
    }
  }

  Future<String> createFoodPlan(CookieRequest request) async {
    final response = await request.post(
      'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/food_plans/food_plan_create_json/',
      {},
    );

    if (response != null && response['food_plan_id'] != null) {
      return response['food_plan_id'];
    } else {
      throw Exception('Failed to create food plan: Invalid response format');
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFEBE9E1),
      appBar: headerApp(context),
      bottomNavigationBar: navbar(context, 'food plans'),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Food Plan List',
              style: TextStyle(
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          // Add New Food Plan Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                // backgroundColor: const Color(0xFFEBE9E1),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: const Color(0xFFEBE9E1),
                minimumSize: const Size.fromHeight(40),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 2,
                ),
              ),
              onPressed: () async {
                try {
                  final pk = await createFoodPlan(request);
                  if (!mounted) return;

                  // Refresh food plans list
                  setState(() {
                    futureFoodPlans = fetchFoodPlans(request);
                  });

                  // Navigate to new food plan and await result
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodPlans(planId: pk),
                    ),
                  );

                  // If a food plan was deleted, refresh the list
                  if (result == true) {
                    setState(() {
                      futureFoodPlans = fetchFoodPlans(request);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Food Plan deleted successfully')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Add New Food Plan'),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<FoodPlan>>(
              future: futureFoodPlans,
              builder: (context, AsyncSnapshot<List<FoodPlan>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return FoodPlanCard(
                        title: snapshot.data![index].fields.nama,
                        onTap: () async {
                          // Navigate to FoodPlans and await result
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodPlans(
                                planId: snapshot.data![index].pk,
                              ),
                            ),
                          );

                          // If a food plan was deleted, refresh the list
                          if (result == true) {
                            setState(() {
                              futureFoodPlans = fetchFoodPlans(request);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Food Plan deleted successfully')),
                            );
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
