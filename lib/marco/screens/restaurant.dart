import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jajan_jogja_mobile/marco/models/makanan.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../farrel/models/food_plan_model.dart';
import '../../farrel/screens/food_plan_list.dart';
import '../../iyan/models/resto.dart';
import '../../widgets/navbar.dart';
import 'package:jajan_jogja_mobile/vander/widgets/review_list_widget.dart';
import 'package:jajan_jogja_mobile/vander/screens/review_form.dart';

import 'food_card.dart';

class FoodPlanService {
  final CookieRequest request;

  FoodPlanService({required this.request});

  // Fetch food plan
  Future<List<FoodPlan>> fetchFoodPlans() async {
    final response = await request.get(
        'http://127.0.0.1:8000/restaurant/get_food_plans_json');

    if (response != null) {
      String jsonString = json.encode(response);
      return foodPlanFromJson(jsonString);
    } else {
      throw Exception('Failed to load food plans');
    }
  }

  // Save to food plan
  Future<void> saveToFoodPlan({
    required String currentResto,
    required String makananId,
    required List<Map<String, dynamic>> foodPlansData,
  }) async {
    try {
      Map<String, dynamic> postData = {
        'currentResto': currentResto,
        'makanan_id': makananId,
        'foodPlansData': jsonEncode(foodPlansData),
      };

      // POST data
      final response = await request.post(
        'http://127.0.0.1:8000/restaurant/save_food_plan_flutter',
        postData,
      );

      if (response['message'] != null) {
        print(response['message']);
      } else if (response['error'] != null) {
        throw Exception(response['er  ror']);
      } else {
        throw Exception('Unexpected response from the server.');
      }
    } catch (e) {
      throw Exception('Failed to save food plan');
    }
  }
}


class RestaurantPage extends StatefulWidget {
  final String idTempatKuliner;

  const RestaurantPage({required this.idTempatKuliner, super.key});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  // Tambahkan state variables untuk menyimpan data yang diambil dari API
  TempatKuliner? restaurant;
  List<Makanan> makananList = [];
  String? tempatKulinerNama;
  bool isLoading = true;
  String? errorMessage;
  List<FoodPlan> foodPlans = [];

  // FoodPlanService instance
  late FoodPlanService foodPlanService;
  bool _isServiceInitialized = false;
  late String tempatKulinerId;

  @override
  void initState() {
      super.initState();
      tempatKulinerId = widget.idTempatKuliner;
  }


  // Fungsi untuk mengambil kedua data secara bersamaan
  Future<Map<String, dynamic>> fetchAllData(CookieRequest request) async {
    try {
      final responses = await Future.wait([
        fetchMakanan(request),
        fetchTempatKuliner(request),
      ]);

      return {
        'makananList': responses[0],
        'restaurant': responses[1],

      };
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<Makanan>> fetchMakanan(CookieRequest request) async {
    final responseMakanan = await request.get('http://127.0.0.1:8000/restaurant/get_makanan_json/${widget.idTempatKuliner}/');

    // Melakukan decode response menjadi bentuk json
    var dataMakanan = responseMakanan;

    // Melakukan konversi data json menjadi object
    List<Makanan> listProduct = [];
    for (var d in dataMakanan) {
      if (d != null) {
        listProduct.add(Makanan.fromJson(d));
      }
    }
    return listProduct;
  }

  Future<TempatKuliner> fetchTempatKuliner(CookieRequest request) async {
    final responseRestaurant = await request.get('http://127.0.0.1:8000/restaurant/get_restoran_json/${widget.idTempatKuliner}/');

    // Melakukan decode response menjadi bentuk json
    var dataRestaurant = responseRestaurant;

    // Melakukan konversi data json menjadi object
    // Asumsikan responseRestaurant adalah List<dynamic> dengan satu objek TempatKuliner
    List<TempatKuliner> listProduct = [];
    for (var d in dataRestaurant) {
      if (d != null) {
        listProduct.add(TempatKuliner.fromJson(d));
      }
    }

    if (listProduct.isNotEmpty) {
      return listProduct.first;
    } else {
      throw Exception('No restaurant data found');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isServiceInitialized) {
      final request = context.read<CookieRequest>();
      foodPlanService = FoodPlanService(request: request);
      _isServiceInitialized = true;
      fetchAllData(request); // Fetch data after initializing the service
    }
  }
  int _reviewListKey = 0;

  void _goToAddReview() async {
    // Navigate to ReviewEntryFormPage and wait for the result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewEntryFormPage(
          tempatKulinerId: tempatKulinerId,
          tempatKulinerNama: tempatKulinerNama ?? 'No name',
        ),
      ),
    );

    // If a new review was added, trigger a refresh
    if (result == true) {
      setState(() {
        // Increment a key or trigger a rebuild in another way
        _reviewListKey++;
      });
    }

  }

  void _showFoodPlanModal(Makanan makanan) async {
    try {
      // Fetch the latest Food Plans
      List<FoodPlan> fetchedFoodPlans = await foodPlanService.fetchFoodPlans();

      if (fetchedFoodPlans.isEmpty) {
        // Jika Food Plans kosong, tampilkan dialog khusus
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "No Food Plans Found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No Food Plan Available :( \nPlease add Food Plan first!",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Redirect ke halaman Food Plan
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FoodPlanList()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          "Go to Food Plans",
                          style: TextStyle(
                            color: Color(0xFFEBE9E1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        return;
      }

      // Jika Food Plans tidak kosong, tampilkan dialog utama
      List<Map<String, dynamic>> foodPlansData = fetchedFoodPlans.map((plan) {
        return {
          'id': plan.pk,
          'checked': plan.fields.makanan.contains(makanan.pk),
        };
      }).toList();

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  width: 300,
                  height: (fetchedFoodPlans.length * 60.0 + 100).clamp(200.0, 500.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Add to Food Plan",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: fetchedFoodPlans.length,
                          itemBuilder: (context, index) {
                            final plan = fetchedFoodPlans[index];
                            final isChecked = foodPlansData[index]['checked'] as bool;

                            return CheckboxListTile(
                              title: Text(plan.fields.nama),
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  foodPlansData[index]['checked'] = value ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await foodPlanService.saveToFoodPlan(
                                currentResto: widget.idTempatKuliner,
                                makananId: makanan.pk,
                                foodPlansData: foodPlansData,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Food plan updated successfully!')),
                              );
                              Navigator.of(context).pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to update food plan: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              color: Color(0xFFEBE9E1),
                            ),
                          ),

                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching food plans: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFEBE9E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBE9E1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0401)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Restaurant',
          style: TextStyle(color: Color(0xFF0F0401)),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchAllData(request),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Tampilkan loading indicator saat data sedang diambil
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Tampilkan error message jika ada
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          } else if (!snapshot.hasData) {
            // Tampilkan pesan jika tidak ada data
            return const Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            );
          } else {
            // Ambil data dari snapshot
            restaurant = snapshot.data!['restaurant'] as TempatKuliner;
            makananList = snapshot.data!['makananList'] as List<Makanan>;

            if (tempatKulinerNama == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  tempatKulinerNama = restaurant?.fields.nama;
                });
              });
            }


            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto restoran
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD6536D), width: 4),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        restaurant?.fields.fotoLink ?? '',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Text('Image not available'));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nama restoran
                  Text(
                    restaurant?.fields.nama ?? 'Nama Restaurant',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C1D05),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Alamat restoran
                  Text(
                    restaurant?.fields.alamat ?? 'Alamat tidak tersedia',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF0F0401),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Restaurant Description
                  Text(
                    restaurant?.fields.description ?? 'Deskripsi tidak tersedia',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF0F0401),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Jam buka tutup restoran
                  Text(
                    'Open: ${restaurant?.fields.jamBuka ?? 'N/A'} - ${restaurant?.fields.jamTutup ?? 'N/A'} WIB',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF0F0401),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Rating dan Reviews
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD6536D), width: 2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reviews',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD6536D),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${restaurant?.fields.rating ?? 'N/A'}/5',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD6536D),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFD401),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // == List Makanan ==
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C1D05),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tampilkan list makanan
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: makananList.length,
                    itemBuilder: (context, index) {
                      final food = makananList[index];
                      return FoodCard(
                        food: food,
                        onAddToPlan: () {
                          _showFoodPlanModal(food);
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  // Reviews Placeholder
                  const Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C1D05),
                    ),
                  ),
                  IconButton(
                    onPressed: _goToAddReview,
                    icon: const Icon(Icons.add_comment),
                    color: const Color(0xFFD6536D),
                    tooltip: "Add Review",
                  ),
                  const SizedBox(height: 16),
                  ReviewsListWidget(
                    theKey: ValueKey(_reviewListKey),
                    tempatKulinerId: tempatKulinerId,
                  ),
                ],
              ),
            );
          }
        },
      ),

      bottomNavigationBar: navbar(context, ""),
    );
  }
}
